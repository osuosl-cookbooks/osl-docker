require_relative '../../spec_helper'

describe 'osl-docker::client' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run.docker_service('default')).to do_nothing
      end
      it do
        expect(chef_run).to_not add_magic_shell_environment('DOCKER_HOST')
      end
      it do
        expect(chef_run).to create_directory('/etc/docker')
      end
      it do
        expect(chef_run).to_not create_template('/etc/docker/daemon.json')
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
        expect(chef_run.cron('docker_prune_volumes')).to do_nothing
      end
      it do
        expect(chef_run.cron('docker_prune_images')).to do_nothing
      end
      it do
        expect(chef_run).to disable_service('docker')
      end
      it do
        expect(chef_run).to stop_service('docker')
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
