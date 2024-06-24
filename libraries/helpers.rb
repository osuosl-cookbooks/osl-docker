module OslDocker
  module Cookbook
    module Helpers
      def osl_docker_version
        '18.09.2'
      end

      def osl_docker_release
        '3.el7'
      end

      def osl_docker_package_name
        'docker-ce'
      end

      def osl_docker_cli_package_name
        'docker-ce-cli'
      end

      def osl_docker_package_version_string
        case node['platform_family']
        when 'rhel'
          "3:#{osl_docker_version}-#{osl_docker_release}"
        when 'debian'
          "5:#{osl_docker_version}~3-0~debian-#{node['lsb']['codename']}"
        end
      end

      def osl_docker_setup_repo?
        # have the docker resource setup the docker repos?

        # standard repo not available for PowerLE or s390x
        return false if %w(ppc64le s390x).include? node['kernel']['machine']

        # only use standard repo on Deb / C7 -- standard repo not available for C8
        platform_family?('debian') || (platform_family?('rhel') && node['platform_version'].to_i == 7)
      end

      def osl_dockercompose_running?
        cmd = shell_out(
          'docker compose ls -q',
          cwd: new_resource.directory
        )

        if cmd.exitstatus != 0
          Chef::Log.fatal('Failed executing: docker compose ls -q')
          Chef::Log.fatal(cmd.stderr)
        else
          cmd.stdout.chomp == new_resource.name
        end
      end

      def ghcr_io_credentials
        data_bag_item('docker', 'ghcr-io')
      rescue Net::HTTPServerException => e
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
