require_relative '../../spec_helper'

describe 'osl-docker::default' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end
      docker_version = '1.13.1'
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to create_docker_installation_package('default').with(version: docker_version)
      end
      it do
        expect(chef_run).to create_docker_service('default')
      end
      it do
        expect(chef_run).to start_docker_service('default')
      end
      case p
      when CENTOS_6, CENTOS_7
        it do
          expect(chef_run).to include_recipe('yum-docker')
        end
        it do
          expect(chef_run).to add_yum_version_lock('docker-engine')
            .with(
              version: docker_version,
              release: '1.el7.centos'
            )
        end
        it do
          expect(chef_run.yum_version_lock('docker-engine')).to \
            notify('yum_repository[docker-main]').to(:makecache).immediately
        end
        it do
          expect(chef_run).to_not include_recipe('apt-docker')
        end
      when DEBIAN_8
        it do
          expect(chef_run).to include_recipe('apt-docker')
        end
        it do
          expect(chef_run).to add_apt_preference('docker-engine')
            .with(
              pin: "version #{docker_version}*",
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
