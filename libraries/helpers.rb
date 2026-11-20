module OslDocker
  module Cookbook
    module Helpers
      def osl_docker_package_name
        if !osl_docker_setup_repo? && debian?
          'docker.io'
        else
          'docker-ce'
        end
      end

      def osl_docker_service_manager
        # s390x only needs its repo managed by us; the service stays cookbook-managed
        if osl_docker_setup_repo? || osl_docker_s390x_rhel?
          'auto'
        else
          'none'
        end
      end

      def osl_docker_setup_repo?
        # have the docker resource setup the docker repos?
        if %w(riscv64 ppc64le).include?(node['kernel']['machine']) || osl_docker_s390x_rhel?
          false
        else
          node['osl-docker']['setup_repo']
        end
      end

      # The docker cookbook maps AlmaLinux to the upstream "centos" repo, which
      # carries no s390x packages; only the "rhel" repo does. Manage the repo
      # ourselves on those nodes until this is fixed upstream.
      def osl_docker_s390x_rhel?
        node['kernel']['machine'] == 's390x' && rhel?
      end

      def osl_docker_repo_baseurl
        if osl_docker_s390x_rhel?
          'https://download.docker.com/linux/rhel/$releasever/$basearch/stable'
        else
          'https://ftp.osuosl.org/pub/osl/repos/yum/$releasever/docker-stable/$basearch'
        end
      end

      def osl_docker_repo_gpgkey
        if osl_docker_s390x_rhel?
          'https://download.docker.com/linux/rhel/gpg'
        else
          osl_gpg_key
        end
      end

      def osl_dockercompose_running?
        compose_cmd = "docker compose -p #{new_resource.name} #{new_resource.config_files.map { |f| "-f #{f}" }.join(' ')}"

        # Check if all containers in the compose project are running
        cmd = shell_out("#{compose_cmd} ps -a --format json", cwd: new_resource.directory)

        if cmd.exitstatus != 0
          # If the command fails, the project likely doesn't exist yet
          Chef::Log.debug("docker compose ps failed for #{new_resource.name}, assuming not running")
          return false
        end

        # Parse JSON output - each line is a separate JSON object
        containers = cmd.stdout.split(/\r?\n/).map(&:chomp).reject(&:empty?).map do |line|
          JSON.parse(line)
        end

        # If no containers are defined or found, consider it as not running
        return false if containers.empty?

        # `ps` cannot report a container that no longer exists, so a service whose
        # container was removed outright looks identical to a project that never
        # defined it. That is not hypothetical: the docker_prune_containers cron
        # reaps any container that has been stopped for 4h, so a service that
        # crashes overnight silently disappears here. Ask the compose file what is
        # supposed to be running instead of trusting what happens to be left.
        config = shell_out("#{compose_cmd} config --format json", cwd: new_resource.directory)

        if config.exitstatus != 0
          Chef::Log.debug("docker compose config failed for #{new_resource.name}, assuming not running")
          return false
        end

        # One-shot services (restart "no", e.g. a migration gate) are expected to
        # exit, and their stopped containers get pruned; `up --wait` already
        # enforces their success through depends_on conditions. Only services
        # meant to stay up count toward the running check.
        defined_services = JSON.parse(config.stdout)['services'].to_h.reject { |_, svc| svc['restart'] == 'no' }.keys
        return false if defined_services.empty?

        # Group by service so that a scaled service still counts as down when only
        # some of its replicas are up. Containers belonging to a service the file
        # no longer defines are ignored: `up` does not reap orphans, so failing on
        # them would re-run the compose command on every converge forever.
        containers_by_service = containers.group_by { |container| container['Service'] }

        defined_services.all? do |service|
          instances = containers_by_service[service].to_a
          instances.any? && instances.all? { |container| container['State'] == 'running' }
        end
      end

      # Pulls the stack's images, then reports whether any running container is on an image other
      # than the one its tag now points at. Comparing what runs (not the tag before and after) also
      # heals a stack left stale by a failed rebuild or a manual pull. Pull failures only warn.
      def osl_dockercompose_stale?
        compose_cmd = "docker compose -p #{new_resource.name} #{new_resource.config_files.map { |f| "-f #{f}" }.join(' ')}"
        dir = new_resource.directory

        # --ignore-pull-failures exits 0 when an image fails; the failure shows only as an
        # " Image <ref> Error ..." line on stderr, among the Pulling/Pulled progress lines
        pull = shell_out("#{compose_cmd} pull --quiet --ignore-buildable --ignore-pull-failures", cwd: dir)
        failed = pull.stderr.to_s.lines.grep(/^\s*Image \S+ Error/).map(&:strip)
        unless pull.exitstatus == 0 && failed.empty?
          Chef::Log.warn("osl_dockercompose[#{new_resource.name}]: pulling images failed, " \
                         "keeping what runs until the next converge: #{failed.empty? ? pull.stderr.to_s.strip : failed.join('; ')}")
        end

        config = shell_out("#{compose_cmd} config --format json", cwd: dir)
        return false unless config.exitstatus == 0

        # Locally built images have no registry tag to fall behind
        tags = JSON.parse(config.stdout)['services'].to_h.reject { |_, svc| svc['build'] }.transform_values { |svc| svc['image'] }

        # Running containers only: an exited one-shot or a `run --rm` job is never compared
        ps = shell_out("#{compose_cmd} ps --format json", cwd: dir)
        return false unless ps.exitstatus == 0

        ps.stdout.split(/\r?\n/).map(&:strip).reject(&:empty?).any? do |line|
          container = JSON.parse(line)
          tag = tags[container['Service']]
          next false unless tag

          running = shell_out("docker inspect -f '{{.Image}}' #{container['ID']}")
          wanted = shell_out("docker image inspect -f '{{.Id}}' #{tag}")
          running.exitstatus == 0 && wanted.exitstatus == 0 && running.stdout.strip != wanted.stdout.strip
        end
      end

      # True when the kernel handles RAs on iface. NetworkManager and networkd set accept_ra=0 when they run RA.
      def osl_docker_kernel_ra?(iface)
        path = "/proc/sys/net/ipv6/conf/#{iface}/accept_ra"
        ::File.exist?(path) && ::File.read(path).strip != '0'
      end

      def osl_dockerd_path
        if platform?('debian')
          '/usr/sbin/dockerd'
        else
          '/usr/bin/dockerd'
        end
      end

      def ghcr_io_credentials
        data_bag_item('docker', 'ghcr-io')
      rescue Net::HTTPClientException => e
        if e.response.code == '404'
          Chef::Log.warn("Could not find databag 'docker:ghcr-io'; falling back to default attributes.")
          node['docker']['ghcr_io']
        else
          Chef::Log.fatal("Unable to load databag 'docker:ghcr-io'; exiting. Please fix the databag and try again.")
          raise
        end
      end

      # Units that load the host firewall, for docker.service's boot ordering
      def osl_docker_firewall_units
        osl_firewall_nftables? ? 'osl-firewall.service' : 'iptables.service ip6tables.service'
      end

      # Without our iptables DOCKER-USER accept, Docker's FORWARD drop would block
      # other routed traffic; distro docker.io may predate the opt-out
      def osl_docker_ip_forward_no_drop?
        osl_firewall_nftables? && osl_docker_package_name == 'docker-ce'
      end
    end
  end
end

Chef::DSL::Recipe.include ::OslDocker::Cookbook::Helpers
Chef::Resource.include ::OslDocker::Cookbook::Helpers
