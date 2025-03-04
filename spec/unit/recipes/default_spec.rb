require_relative '../../spec_helper'

describe 'osl-docker::default' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end

      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end

      it { expect(chef_run).to accept_osl_firewall_docker('osl-docker') }

      it do
        expect(chef_run).to accept_osl_firewall_port('docker_exporter').with(
          service_name: 'prometheus',
          ports: %w(9323)
        )
      end

      it { expect(chef_run).to create_directory('/etc/docker') }

      it do
        expect(chef_run).to create_template('/etc/docker/daemon.json').with(
          variables: {
            config: {
              'metrics-addr' => '0.0.0.0:9323',
              'experimental' => true,
              'ip6tables' => true,
              'log-opts' => {
                'max-size' => '100m',
                'max-file' => '10',
              },
              'registry-mirrors' => %w(https://registry.osuosl.org),
            },
          }
        )
      end
      it { expect(chef_run.template('/etc/docker/daemon.json')).to notify('docker_service[default]').to(:restart) }
      it { expect(chef_run).to_not create_directory('/etc/docker/ssl') }
      it { expect(chef_run).to_not create_certificate_manage('server-fauxhai-local') }
      it { expect(chef_run).to_not create_certificate_manage('client-fauxhai-local') }
      it { expect(chef_run).to_not add_osl_shell_environment('DOCKER_TLS_VERIFY') }
      it { expect(chef_run).to_not add_osl_shell_environment('DOCKER_CERT_PATH') }
      it { expect(chef_run).to_not add_osl_shell_environment('DOCKER_HOST') }

      it do
        expect(chef_run).to create_docker_service('default').with(
          setup_docker_repo: true,
          package_name: 'docker-ce',
          service_manager: 'auto',
          host: %w(unix:///var/run/docker.sock),
          misc_opts: '--live-restore'
        )
      end

      context 'riscv64' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(p) do |node|
            node.automatic['kernel']['machine'] = 'riscv64'
          end.converge(described_recipe)
        end
        dockerd_path =
          if p[:platform] == 'debian'
            '/usr/sbin/dockerd'
          else
            '/usr/bin/dockerd'
          end

        it do
          expect(chef_run).to create_docker_service('default').with(
            setup_docker_repo: false,
            package_name: 'docker.io',
            service_manager: 'none',
            host: %w(unix:///var/run/docker.sock),
            misc_opts: '--live-restore'
          )
        end
        it do
          expect(chef_run).to create_osl_systemd_unit_drop_in('misc-opts').with(
            unit_name: 'docker.service',
            content: <<~EOC
              [Service]
              ExecStart=
              ExecStart=#{dockerd_path} -H fd:// --containerd=/run/containerd/containerd.sock --live-restore
            EOC
          )
        end
      end

      it do
        expect(chef_run).to create_cron('docker_prune_volumes').with(
          minute: '15',
          command: '/usr/bin/docker system prune --volumes -f  > /dev/null'
        )
      end
      it do
        expect(chef_run).to create_cron('docker_prune_images').with(
          minute: '45',
          hour: '2',
          weekday: '0',
          command: '/usr/bin/docker system prune -a -f  > /dev/null'
        )
      end

      it do
        expect(chef_run).to create_cron('docker_prune_volumes').with(
          minute: '15',
          command: '/usr/bin/docker system prune --volumes -f  > /dev/null'
        )
      end

      it do
        expect(chef_run).to create_cron('docker_prune_images').with(
          minute: '45',
          hour: '2',
          weekday: '0',
          command: '/usr/bin/docker system prune -a -f  > /dev/null'
        )
      end

      it { expect(chef_run).to install_cron_package('osl-docker') }
      it { expect(chef_run).to enable_cron_service('osl-docker') }
      it { expect(chef_run).to start_cron_service('osl-docker') }

      case p
      when *ALL_RHEL
        it do
          expect(chef_run).to include_recipe('osl-selinux')
        end
      end

      context 'DOCKER_HOST set' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(p) do |node|
            node.normal['osl-docker']['host'] = 'tcp://127.0.0.1:2375'
          end.converge(described_recipe)
        end

        it do
          expect(chef_run).to add_osl_shell_environment('DOCKER_HOST').with(
            value: 'tcp://127.0.0.1:2375'
          )
        end
      end

      context 'Enable TLS' do
        before do
          allow(File).to receive(:exist?).and_call_original
          allow(File).to receive(:exist?).with('/etc/docker/ssl/key.pem').and_return(true)
        end

        cached(:chef_run) do
          ChefSpec::SoloRunner.new(p) do |node|
            node.normal['osl-docker']['tls'] = true
          end.converge(described_recipe)
        end

        it do
          expect(chef_run).to create_directory('/etc/docker/ssl').with(
            owner: 'root',
            group: 'docker',
            mode: '0750',
            recursive: true
          )
        end
        it { expect(chef_run.directory('/etc/docker/ssl')).to notify('docker_service[default]').to(:restart) }

        it do
          expect(chef_run).to create_certificate_manage('server-fauxhai-local').with(
            data_bag: 'docker',
            cert_path: '/etc/docker/ssl',
            chain_file: 'ca.pem',
            cert_file: 'server.pem',
            key_file: 'server-key.pem',
            owner: 'root',
            group: 'docker',
            create_subfolders: false
          )
        end
        it { expect(chef_run.certificate_manage('server-fauxhai-local')).to notify('docker_service[default]').to(:restart) }

        it do
          expect(chef_run).to create_certificate_manage('client-fauxhai-local').with(
            data_bag: 'docker',
            cert_path: '/etc/docker/ssl',
            chain_file: 'ca.pem',
            cert_file: 'cert.pem',
            key_file: 'key.pem',
            owner: 'root',
            group: 'docker',
            create_subfolders: false
          )
        end
        it { expect(chef_run.certificate_manage('client-fauxhai-local')).to notify('docker_service[default]').to(:restart) }

        it do
          expect(chef_run).to add_osl_shell_environment('DOCKER_HOST').with(
            value: 'tcp://127.0.0.1:2376'
          )
        end

        it do
          expect(chef_run).to add_osl_shell_environment('DOCKER_TLS_VERIFY').with(
            value: '1'
          )
        end

        it do
          expect(chef_run).to add_osl_shell_environment('DOCKER_CERT_PATH').with(
            value: '/etc/docker/ssl'
          )
        end

        it do
          expect(chef_run).to create_docker_service('default').with(
            tls_verify: true,
            tls_ca_cert: '/etc/docker/ssl/ca.pem',
            tls_server_cert: '/etc/docker/ssl/server.pem',
            tls_server_key: '/etc/docker/ssl/server-key.pem',
            tls_client_cert: '/etc/docker/ssl/cert.pem',
            tls_client_key: '/etc/docker/ssl/key.pem'
          )
        end

        it do
          expect(chef_run).to create_osl_systemd_unit_drop_in('iptables-fix').with(
            unit_name: 'docker.service',
            content: {
              'Unit' => {
                'PartOf' => 'iptables.service',
              },
            }
          )
        end
      end
    end
  end
end
