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
      it do
        expect(chef_run).to create_docker_service('default').with(install_method: 'none')
      end
      it do
        expect(chef_run).to start_docker_service('default')
      end
      it do
        expect(chef_run).to_not add_magic_shell_environment('DOCKER_HOST')
      end
      it do
        expect(chef_run).to create_directory('/etc/docker')
      end
      it do
        expect(chef_run).to create_template('/etc/docker/daemon.json')
          .with(
            variables: {
              config: {
                'metrics-addr' => '0.0.0.0:9323',
                'experimental' => true,
              },
            }
          )
      end
      it do
        expect(chef_run).to render_file('/etc/docker/daemon.json')
          .with_content('{
  "metrics-addr": "0.0.0.0:9323",
  "experimental": true
}')
      end
      it do
        expect(chef_run.template('/etc/docker/daemon.json')).to notify('docker_service[default]').to(:restart)
      end
      it do
        expect(chef_run).to_not create_directory('/etc/docker/ssl')
      end
      it do
        expect(chef_run).to_not create_certificate_manage('server-fauxhai-local')
      end
      it do
        expect(chef_run).to_not create_certificate_manage('client-fauxhai-local')
      end
      it do
        expect(chef_run).to_not add_magic_shell_environment('DOCKER_TLS_VERIFY').with(value: '1')
      end
      it do
        expect(chef_run).to_not add_magic_shell_environment('DOCKER_CERT_PATH').with(value: '/etc/docker/ssl')
      end
      it do
        expect(chef_run).to create_cron('docker_prune_volumes')
          .with(
            minute: '15',
            environment: {},
            command: '/usr/bin/docker system prune --volumes -f  > /dev/null'
          )
      end
      it do
        expect(chef_run).to create_cron('docker_prune_images')
          .with(
            minute: '45',
            hour: '2',
            weekday: '0',
            environment: {},
            command: '/usr/bin/docker system prune -a -f  > /dev/null'
          )
      end
      context 'DOCKER_HOST set' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(p) do |node|
            node.normal['osl-docker']['host'] = 'tcp://127.0.0.1:2375'
          end.converge(described_recipe)
        end
        it do
          expect(chef_run).to add_magic_shell_environment('DOCKER_HOST').with(value: 'tcp://127.0.0.1:2375')
        end
        it do
          expect(chef_run).to create_cron('docker_prune_volumes')
            .with(
              minute: '15',
              command: '/usr/bin/docker system prune --volumes -f  > /dev/null'
            )
        end
        it do
          expect(chef_run).to create_cron('docker_prune_images')
            .with(
              minute: '45',
              hour: '2',
              weekday: '0',
              command: '/usr/bin/docker system prune -a -f  > /dev/null'
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
          expect(chef_run).to create_directory('/etc/docker/ssl')
            .with(
              owner: 'root',
              group: 'docker',
              mode: '0750',
              recursive: true
            )
        end
        it do
          expect(chef_run).to create_certificate_manage('server-fauxhai-local')
            .with(
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
        it do
          expect(chef_run.certificate_manage('server-fauxhai-local')).to notify('docker_service[default]').to(:restart)
        end
        it do
          expect(chef_run).to create_certificate_manage('client-fauxhai-local')
            .with(
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
          expect(chef_run).to add_magic_shell_environment('DOCKER_HOST').with(value: 'tcp://127.0.0.1:2376')
        end
        it do
          expect(chef_run).to add_magic_shell_environment('DOCKER_TLS_VERIFY').with(value: '1')
        end
        it do
          expect(chef_run).to add_magic_shell_environment('DOCKER_CERT_PATH').with(value: '/etc/docker/ssl')
        end
        it do
          expect(chef_run).to create_docker_service('default')
            .with(
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
      case p
      when CENTOS_7
        it do
          expect(chef_run).to create_docker_installation_package('default').with(version: '18.09.2')
        end
        context 'ppc64le' do
          cached(:chef_run) do
            ChefSpec::SoloRunner.new(p) do |node|
              node.automatic['kernel']['machine'] = 'ppc64le'
            end.converge(described_recipe)
          end
          it do
            expect(chef_run).to create_yum_repository('Docker')
              .with(
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
            expect(chef_run).to create_yum_repository('Docker')
              .with(
                baseurl: 'https://ftp.osuosl.org/pub/osl/repos/yum/$releasever/docker-stable/$basearch',
                gpgkey: 'https://ftp.osuosl.org/pub/osl/repos/yum/RPM-GPG-KEY-osuosl',
                description: 'Docker Stable repository',
                gpgcheck: true,
                enabled: true
              )
          end
        end
        it do
          expect(chef_run).to include_recipe('yum-plugin-versionlock')
        end
        %w(
          docker-main
          docker-stable
          docker-edge
          docker-test
        ).each do |r|
          it do
            expect(chef_run).to delete_yum_repository(r)
          end
        end
        it do
          expect(chef_run).to add_yum_version_lock('docker-ce')
            .with(
              version: '18.09.2',
              release: '3.el7'
            )
        end
        it do
          expect(chef_run).to add_yum_version_lock('docker-ce-cli')
            .with(
              version: '18.09.2',
              release: '3.el7'
            )
        end
        it do
          expect(chef_run).to_not install_package('dirmgr')
        end
      when DEBIAN_9
        it do
          expect(chef_run).to create_docker_installation_package('default').with(version: '5:18.09.2')
        end
        it do
          expect(chef_run).to install_package('dirmngr')
        end
        %w(
          docker-main
          docker-stable
          docker-edge
          docker-test
        ).each do |r|
          it do
            expect(chef_run).to remove_apt_repository(r)
          end
        end
        it do
          expect(chef_run).to add_apt_preference('docker-ce')
            .with(
              pin: 'version 5:18.09.2*',
              pin_priority: '1001'
            )
        end
        it do
          expect(chef_run).to add_apt_preference('docker-ce-cli')
            .with(
              pin: 'version 5:18.09.2*',
              pin_priority: '1001'
            )
        end
      end
    end
  end
end
