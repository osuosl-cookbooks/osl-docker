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
        expect(chef_run).to create_docker_service('default')
      end
      it do
        expect(chef_run).to start_docker_service('default')
      end
      it do
        expect(chef_run).to_not add_magic_shell_environment('DOCKER_HOST')
      end
      it do
        expect(chef_run).to_not create_group('docker')
      end
      it do
        expect(chef_run).to_not create_docker_installation_tarball('default')
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
          expect(chef_run).to create_docker_installation_package('default').with(version: '18.06.1.ce')
        end
        context 'ppc64le' do
          cached(:chef_run) do
            ChefSpec::SoloRunner.new(p) do |node|
              node.automatic['kernel']['machine'] = 'ppc64le'
            end.converge(described_recipe)
          end
          it do
            expect(chef_run).to_not create_yum_repository('docker-stable')
          end
          %w(yum-docker yum-plugin-versionlock).each do |r|
            it do
              expect(chef_run).to_not include_recipe(r)
            end
          end
          it do
            expect(chef_run).to_not add_yum_version_lock('docker-ce')
          end
          it do
            expect(chef_run).to delete_docker_installation_package('default')
          end
          it do
            expect(chef_run).to create_docker_installation_tarball('default')
              .with(
                version: '18.06.1',
                checksum: '479083ac0b2bae839782ea53870809b8590f440db5f0bdf1294eac95e1a2ec3b',
                source: 'https://download.docker.com/linux/static/stable/ppc64le/docker-18.06.1-ce.tgz'
              )
          end
          it do
            expect(chef_run).to create_group('docker').with(system: true)
          end
        end
        context 's390x' do
          cached(:chef_run) do
            ChefSpec::SoloRunner.new(p) do |node|
              node.automatic['kernel']['machine'] = 's390x'
            end.converge(described_recipe)
          end
          it do
            expect(chef_run).to_not create_yum_repository('docker-stable')
          end
          %w(yum-docker yum-plugin-versionlock).each do |r|
            it do
              expect(chef_run).to_not include_recipe(r)
            end
          end
          it do
            expect(chef_run).to_not add_yum_version_lock('docker-ce')
          end
          it do
            expect(chef_run).to delete_docker_installation_package('default')
          end
          it do
            expect(chef_run).to create_docker_installation_tarball('default')
              .with(
                version: '18.06.1',
                checksum: '4042fc5a00baf9ceb3724b8f1a285bbdda714b0360b4a406fd316ecc6142dee3',
                source: 'https://download.docker.com/linux/static/stable/s390x/docker-18.06.1-ce.tgz'
              )
          end
          it do
            expect(chef_run).to create_group('docker').with(system: true)
          end
        end
        it do
          expect(chef_run).to create_yum_repository('docker-stable')
            .with(
              baseurl: 'https://download.docker.com/linux/centos/7/x86_64/stable',
              gpgkey: 'https://download.docker.com/linux/centos/gpg'
            )
        end
        %w(chef-yum-docker yum-plugin-versionlock).each do |r|
          it do
            expect(chef_run).to include_recipe(r)
          end
        end
        it do
          expect(chef_run).to delete_yum_repository('docker-main')
        end
        it do
          expect(chef_run).to add_yum_version_lock('docker-ce')
            .with(
              version: '18.06.1.ce',
              release: '3.el7'
            )
        end
        it do
          expect(chef_run.yum_version_lock('docker-ce')).to \
            notify('yum_repository[docker-stable]').to(:makecache).immediately
        end
        it do
          expect(chef_run).to_not add_apt_repository('docker-stable')
        end
        it do
          expect(chef_run).to_not add_apt_preference('docker-ce')
        end
        it do
          expect(chef_run).to_not install_package('dirmgr')
        end
      when DEBIAN_8
        it do
          expect(chef_run).to create_docker_installation_package('default').with(version: '18.06.1')
        end
        it do
          expect(chef_run).to_not install_package('dirmngr')
        end
        it do
          expect(chef_run).to include_recipe('chef-apt-docker')
        end
        it do
          expect(chef_run).to add_apt_repository('docker-stable')
        end
        it do
          expect(chef_run).to remove_apt_repository('docker-main')
        end
        it do
          expect(chef_run).to add_apt_preference('docker-ce')
            .with(
              pin: 'version 18.06.1*',
              pin_priority: '1001'
            )
        end
        it do
          expect(chef_run).to_not include_recipe('chef-yum-docker')
        end
        it do
          expect(chef_run).to_not add_yum_version_lock('docker-engine')
        end
      when DEBIAN_9
        it do
          expect(chef_run).to create_docker_installation_package('default').with(version: '18.06.1')
        end
        it do
          expect(chef_run).to install_package('dirmngr')
        end
        it do
          expect(chef_run).to include_recipe('chef-apt-docker')
        end
        it do
          expect(chef_run).to add_apt_repository('docker-stable')
        end
        it do
          expect(chef_run).to remove_apt_repository('docker-main')
        end
        it do
          expect(chef_run).to add_apt_preference('docker-ce')
            .with(
              pin: 'version 18.06.1*',
              pin_priority: '1001'
            )
        end
        it do
          expect(chef_run).to_not include_recipe('chef-yum-docker')
        end
        it do
          expect(chef_run).to_not add_yum_version_lock('docker-engine')
        end
      end
    end
  end
end
