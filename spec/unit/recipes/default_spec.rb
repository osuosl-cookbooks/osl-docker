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
      context 'DOCKER_HOST set' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(p) do |node|
            node.set['osl-docker']['service']['host'] = 'tcp://127.0.0.1:2375'
          end.converge(described_recipe)
        end
        it do
          expect(chef_run).to add_magic_shell_environment('DOCKER_HOST').with(value: 'tcp://127.0.0.1:2375')
        end
      end
      case p
      when CENTOS_7
        it do
          expect(chef_run).to create_docker_installation_package('default').with(version: '17.09.0.ce')
        end
        context 'ppc64le' do
          cached(:chef_run) do
            ChefSpec::SoloRunner.new(p) do |node|
              node.automatic['kernel']['machine'] = 'ppc64le'
            end.converge(described_recipe)
          end
          it do
            expect(chef_run).to create_yum_repository('docker-main')
              .with(
                baseurl: 'http://ftp.unicamp.br/pub/ppc64el/rhel/7/docker-ppc64el/',
                gpgcheck: false
              )
          end
        end
        it do
          expect(chef_run).to create_yum_repository('docker-main')
            .with(
              baseurl: 'https://download.docker.com/linux/centos/7/x86_64/stable/',
              gpgkey: 'https://download.docker.com/linux/centos/gpg'
            )
        end
        it do
          expect(chef_run).to include_recipe('yum-docker')
        end
        it do
          expect(chef_run).to add_yum_version_lock('docker-ce')
            .with(
              version: '17.09.0.ce',
              release: '1.el7.centos'
            )
        end
        it do
          expect(chef_run.yum_version_lock('docker-ce')).to \
            notify('yum_repository[docker-main]').to(:makecache).immediately
        end
        it do
          expect(chef_run).to_not add_apt_repository('docker-main')
        end
        it do
          expect(chef_run).to_not add_apt_preference('docker-ce')
        end
        it do
          expect(chef_run).to_not install_package('dirmgr')
        end
      when DEBIAN_8
        it do
          expect(chef_run).to create_docker_installation_package('default').with(version: '17.09.0')
        end
        it do
          expect(chef_run).to add_apt_repository('docker-main')
            .with(
              uri: 'https://download.docker.com/linux/debian',
              components: %w(stable),
              distribution: 'jessie',
              keyserver: 'hkp://p80.pool.sks-keyservers.net:80',
              key: '0EBFCD88'
            )
        end
        it do
          expect(chef_run).to add_apt_preference('docker-ce')
            .with(
              pin: 'version 17.09.0*',
              pin_priority: '1001'
            )
        end
        it do
          expect(chef_run).to_not include_recipe('yum-docker')
        end
        it do
          expect(chef_run).to_not add_yum_version_lock('docker-engine')
        end
      end
    end
  end
end
