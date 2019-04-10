require_relative '../../spec_helper'

describe 'osl-docker::nvidia' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      case p
      when CENTOS_7
        %w(
          yum-epel
          yum-nvidia
          build-essential
          osl-docker
          yum-plugin-versionlock
        ).each do |r|
          it do
            expect(chef_run).to include_recipe(r)
          end
        end

        %w(
          dkms-nvidia
          nvidia-driver
          nvidia-driver-cuda-libs
          nvidia-driver-libs
        ).each do |pkg|
          it do
            expect(chef_run).to add_yum_version_lock(pkg)
              .with(
                version: '410.104',
                release: '1.el7',
                epoch: 3
              )
          end
        end

        it do
          expect(chef_run).to add_yum_version_lock('nvidia-docker2')
            .with(
              version: '2.0.3',
              release: '1.docker18.09.2.ce'
            )
        end

        it do
          expect(chef_run).to install_package('nvidia-driver').with(version: '410.104-1.el7')
        end

        it do
          expect(chef_run).to install_package('nvidia-docker2').with(version: '2.0.3-1.docker18.09.2.ce')
        end
        it do
          expect(chef_run).to create_template('/etc/docker/daemon.json')
            .with(
              variables: {
                config: {
                  'runtimes' => {
                    'nvidia' => {
                      'path' => 'nvidia-container-runtime',
                      'runtimeArgs' => [],
                    },
                  },
                },
              }
            )
        end
      when DEBIAN_8, DEBIAN_9
        %w(
          yum-epel
          yum-nvidia
          build-essential
          osl-docker
          yum-plugin-versionlock
        ).each do |r|
          it do
            expect(chef_run).to_not include_recipe(r)
          end
        end

        %w(
          dkms-nvidia
          nvidia-driver
          nvidia-driver-cuda-libs
          nvidia-driver-libs
        ).each do |pkg|
          it do
            expect(chef_run).to_not add_yum_version_lock(pkg)
          end
        end

        it do
          expect(chef_run).to_not install_package('nvidia-driver')
        end

        it do
          expect(chef_run).to_not install_package('nvidia-docker2')
        end
      end
    end
  end
end
