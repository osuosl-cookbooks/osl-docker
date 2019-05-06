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
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/var/chef/cache/makecache-cuda').and_return(false)
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
          nvidia-driver-cuda
          nvidia-driver-cuda-libs
          nvidia-driver-devel
          nvidia-driver-libs
          nvidia-driver-NvFBCOpenGL
          nvidia-driver-NVML
          nvidia-libXNVCtrl
          nvidia-libXNVCtrl-devel
          nvidia-modprobe
          nvidia-persistenced
          nvidia-settings
          nvidia-xconfig
        ).each do |pkg|
          it do
            expect(chef_run).to add_yum_version_lock(pkg)
              .with(
                version: '410.104',
                release: '1.el7',
                epoch: 3
              )
          end
          it do
            expect(chef_run.yum_version_lock(pkg)).to notify('file[/var/chef/cache/makecache-cuda]').immediately
          end
        end

        it do
          expect(chef_run).to add_yum_version_lock('cuda-drivers')
            .with(
              version: '410.104',
              release: '1'
            )
        end

        it do
          expect(chef_run).to add_yum_version_lock('nvidia-docker2')
            .with(
              version: '2.0.3',
              release: '1.docker18.09.2.ce'
            )
        end

        it do
          expect(chef_run).to add_yum_version_lock('cuda')
            .with(
              version: '10.0.130',
              release: '1'
            )
        end
        %w(cuda-drivers nvidia-docker2 cuda).each do |pkg|
          it do
            expect(chef_run.yum_version_lock(pkg)).to notify('file[/var/chef/cache/makecache-cuda]').to(:touch).immediately
          end
        end

        it do
          expect(chef_run.log('yum makecache cuda')).to do_nothing
        end

        it do
          expect(chef_run.log('yum makecache cuda')).to notify('yum_repository[cuda]').immediately
        end

        it do
          expect(chef_run).to delete_file('/var/chef/cache/makecache-cuda')
        end

        it do
          expect(chef_run).to install_package(%w(nvidia-driver cuda-drivers nvidia-docker2))
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
        context '/var/chef/cache/makecache-cuda exists' do
          cached(:chef_run) do
            ChefSpec::SoloRunner.new(p).converge(described_recipe)
          end
          it 'converges successfully' do
            expect { chef_run }.to_not raise_error
          end
          before do
            allow(File).to receive(:exist?).and_call_original
            allow(File).to receive(:exist?).with('/var/chef/cache/makecache-cuda').and_return(true)
          end
          it do
            expect(chef_run).to write_log('yum makecache cuda').with(message: 'yum makecache cuda')
          end

          it do
            expect(chef_run.log('yum makecache cuda')).to notify('yum_repository[cuda]').immediately
          end
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
          nvidia-driver-cuda
          nvidia-driver-cuda-libs
          nvidia-driver-devel
          nvidia-driver-libs
          nvidia-driver-NvFBCOpenGL
          nvidia-driver-NVML
          nvidia-libXNVCtrl
          nvidia-libXNVCtrl-devel
          nvidia-modprobe
          nvidia-persistenced
          nvidia-settings
          nvidia-xconfig
        ).each do |pkg|
          it do
            expect(chef_run).to_not add_yum_version_lock(pkg)
          end
        end

        it do
          expect(chef_run).to_not install_package(%w(nvidia-driver cuda-drivers nvidia-docker2))
        end
      end
    end
  end
end
