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
        if osl_docker_setup_repo?
          'auto'
        else
          'none'
        end
      end

      def osl_docker_setup_repo?
        # have the docker resource setup the docker repos?
        if %w(riscv64 ppc64le).include? node['kernel']['machine']
          false
        else
          node['osl-docker']['setup_repo']
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
        services = shell_out("#{compose_cmd} config --services", cwd: new_resource.directory)

        if services.exitstatus != 0
          Chef::Log.debug("docker compose config failed for #{new_resource.name}, assuming not running")
          return false
        end

        defined_services = services.stdout.split(/\r?\n/).map(&:strip).reject(&:empty?)
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
    end
  end
end

Chef::DSL::Recipe.include ::OslDocker::Cookbook::Helpers
Chef::Resource.include ::OslDocker::Cookbook::Helpers
