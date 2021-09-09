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
      it { expect(chef_run).to create_docker_service('default') }

      it do
        expect(chef_run).to start_docker_service('default').with(
          host: %w(unix:///var/run/docker.sock),
          misc_opts: '--live-restore',
          install_method: 'none'
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

      case p
      when CENTOS_7, CENTOS_8
        it do
          expect(chef_run).to include_recipe('osl-selinux')
        end

        it { expect(chef_run).to include_recipe('yum-plugin-versionlock') }

        it do
          expect(chef_run).to remove_yum_version_lock('docker-ce').with(
            version: '18.09.2',
            release: '3.el7'
          )
        end
        it do
          expect(chef_run).to remove_yum_version_lock('docker-ce-cli').with(
            version: '18.09.2',
            release: '3.el7'
          )
        end
      when DEBIAN_10
        it do
          expect(chef_run).to remove_apt_preference('docker-ce').with(
            pin: 'version 5:18.09.2~3-0~debian-buster',
            pin_priority: '1001'
          )
        end

        it do
          expect(chef_run).to remove_apt_preference('docker-ce-cli').with(
            pin: 'version 5:18.09.2~3-0~debian-buster',
            pin_priority: '1001'
          )
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
          expect(chef_run).to start_docker_service('default').with(
            install_method: 'none',
            tls_verify: true,
            tls_ca_cert: '/etc/docker/ssl/ca.pem',
            tls_server_cert: '/etc/docker/ssl/server.pem',
            tls_server_key: '/etc/docker/ssl/server-key.pem',
            tls_client_cert: '/etc/docker/ssl/cert.pem',
            tls_client_key: '/etc/docker/ssl/key.pem'
          )
        end
      end
    end
  end
end
