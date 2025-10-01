module OslDocker
  module Cookbook
    module Helpers
      def osl_docker_package_name
        if osl_docker_setup_repo?
          'docker-ce'
        else
          'docker.io'
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
        cmd = shell_out(
          'docker compose ls -q',
          cwd: new_resource.directory
        )

        if cmd.exitstatus != 0
          Chef::Log.fatal('Failed executing: docker compose ls -q')
          Chef::Log.fatal(cmd.stderr)
        else
          cmd.stdout.split(/\r?\n/).any? { |n| n.chomp == new_resource.name }
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
