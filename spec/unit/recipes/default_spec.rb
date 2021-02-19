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

      it { expect(chef_run).to include_recipe('firewall::docker') }
      it { expect(chef_run).to include_recipe('firewall::prometheus') }

      it do
        expect(chef_run).to create_firewall_prometheus('docker_exporter').with(
          port: 9323
        )
      end

      it { expect(chef_run).to create_directory('/etc/docker') }

      it do
        expect(chef_run).to create_template('/etc/docker/daemon.json').with(
          variables: {
            config: {
              'metrics-addr' => '0.0.0.0:9323',
              'experimental' => true,
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

      it do
        expect(chef_run).to create_docker_service('default').with(
          install_method: 'none'
        )
      end
      it { expect(chef_run).to start_docker_service('default') }

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

        it { expect(chef_run).to include_recipe('yum-plugin-versionlock') }

        it do
          expect(chef_run).to add_yum_version_lock('docker-ce').with(
            version: '18.09.2',
            release: '3.el7'
          )
        end
        it do
          expect(chef_run).to add_yum_version_lock('docker-ce-cli').with(
            version: '18.09.2',
            release: '3.el7'
          )
        end

        it { expect(chef_run).to_not install_package('dirmgr') }

        if p == CENTOS_8
          it do
            expect(chef_run).to create_yum_repository('Docker').with(
              baseurl: 'https://download.docker.com/linux/centos/7/x86_64/stable',
              gpgkey: 'https://download.docker.com/linux/centos/gpg',
              description: 'Docker Stable repository',
              gpgcheck: true,
              enabled: true,
              options: { module_hotfixes: true }
            )
          end
        end

        it do
          expect(chef_run).to create_docker_installation_package('default').with(
            package_version: '18.09.2-3.el7',
            package_name: 'docker-ce',
            setup_docker_repo: (p == CENTOS_7)
          )
        end

        context 'ppc64le' do
          cached(:chef_run) do
            ChefSpec::SoloRunner.new(p) do |node|
              node.automatic['kernel']['machine'] = 'ppc64le'
            end.converge(described_recipe)
          end

          it do
            expect(chef_run).to create_yum_repository('Docker').with(
              baseurl: 'https://ftp.osuosl.org/pub/osl/repos/yum/$releasever/docker-stable/$basearch',
              gpgkey: 'https://ftp.osuosl.org/pub/osl/repos/yum/RPM-GPG-KEY-osuosl',
              description: 'Docker Stable repository',
              gpgcheck: true,
              enabled: true
            )
          end
        end

        context 's390x' do
          cached(:chef_run) do
            ChefSpec::SoloRunner.new(p) do |node|
              node.automatic['kernel']['machine'] = 's390x'
            end.converge(described_recipe)
          end

          it do
            expect(chef_run).to create_yum_repository('Docker').with(
              baseurl: 'https://ftp.osuosl.org/pub/osl/repos/yum/$releasever/docker-stable/$basearch',
              gpgkey: 'https://ftp.osuosl.org/pub/osl/repos/yum/RPM-GPG-KEY-osuosl',
              description: 'Docker Stable repository',
              gpgcheck: true,
              enabled: true
            )
          end
        end

      when DEBIAN_10
        it { expect(chef_run).to install_package('dirmngr') }
        it do
          expect(chef_run).to add_apt_preference('docker-ce').with(
            pin: 'version 5:18.09.2~3-0~debian-buster',
            pin_priority: '1001'
          )
        end

        it do
          expect(chef_run).to add_apt_preference('docker-ce-cli').with(
            pin: 'version 5:18.09.2~3-0~debian-buster',
            pin_priority: '1001'
          )
        end

        it do
          expect(chef_run).to create_docker_installation_package('default').with(
            package_version: '5:18.09.2~3-0~debian-buster',
            package_name: 'docker-ce',
            setup_docker_repo: true
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
          expect(chef_run).to create_docker_service('default').with(
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
