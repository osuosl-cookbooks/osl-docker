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
        it do
          expect(chef_run).to install_build_essential('nvidia')
        end
        %w(
          yum-epel
          yum-nvidia
          osl-docker
          yum-plugin-versionlock
        ).each do |r|
          it do
            expect(chef_run).to include_recipe(r)
          end
        end

        %w(
          dkms-nvidia
          kmod-nvidia-latest-dkms
          nvidia-driver
          nvidia-driver-cuda
          nvidia-driver-cuda-libs
          nvidia-driver-devel
          nvidia-driver-latest
          nvidia-driver-latest-cuda
          nvidia-driver-latest-dkms
          nvidia-driver-latest-dkms-cuda
          nvidia-driver-latest-dkms-cuda-libs
          nvidia-driver-latest-dkms-devel
          nvidia-driver-latest-dkms-libs
          nvidia-driver-latest-dkms-NvFBCOpenGL
          nvidia-driver-latest-dkms-NVML
          nvidia-driver-libs
          nvidia-driver-NvFBCOpenGL
          nvidia-driver-NVML
          nvidia-kmod
          nvidia-libXNVCtrl
          nvidia-libXNVCtrl-devel
          nvidia-modprobe
          nvidia-modprobe-latest
          nvidia-modprobe-latest-dkms
          nvidia-persistenced
          nvidia-persistenced-latest
          nvidia-persistenced-latest-dkms
          nvidia-settings
          nvidia-xconfig
          nvidia-xconfig-latest
          nvidia-xconfig-latest-dkms
        ).each do |pkg|
          it do
            expect(chef_run).to add_yum_version_lock(pkg)
              .with(
                version: '440.33.01',
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
              version: '440.33.01',
              release: '1'
            )
        end

        it do
          expect(chef_run).to remove_yum_version_lock('nvidia-docker2')
            .with(
              version: '2.0.3',
              release: '1.docker18.09.2.ce'
            )
        end

        it do
          expect(chef_run).to add_yum_version_lock('cuda')
            .with(
              version: '10.2.89',
              release: '1'
            )
        end
        %w(440 450 455 460 465 470).each do |ver|
          [
            "nvidia-driver-branch-#{ver}",
            "nvidia-driver-branch-#{ver}-cuda",
            "nvidia-driver-branch-#{ver}-cuda-libs",
            "nvidia-driver-branch-#{ver}-devel",
            "nvidia-driver-branch-#{ver}-NvFBCOpenGL",
            "nvidia-driver-branch-#{ver}-NVML",
            "nvidia-modprobe-branch-#{ver}",
            "nvidia-persistenced-branch-#{ver}",
            "nvidia-xconfig-branch-#{ver}",
          ].each do |pkg|
            it do
              expect(chef_run).to add_yum_version_lock(pkg).with(version: '*', release: '*', epoch: 3)
            end
            it do
              expect(chef_run.yum_version_lock(pkg)).to notify('file[/var/chef/cache/makecache-cuda]').to(:touch).immediately
            end
          end
        end
        %w(cuda-drivers nvidia-docker2 cuda).each do |pkg|
          it do
            expect(chef_run.yum_version_lock(pkg)).to notify('file[/var/chef/cache/makecache-cuda]').to(:touch).immediately
          end
        end

        it do
          expect(chef_run.notify_group('notify yum makecache cuda')).to notify('yum_repository[cuda]').immediately
        end

        it do
          expect(chef_run).to delete_file('/var/chef/cache/makecache-cuda')
        end

        it do
          expect(chef_run).to install_package(%w(nvidia-driver-latest-dkms cuda-drivers nvidia-docker2))
        end

        it do
          expect(chef_run).to create_template('/etc/docker/daemon.json')
            .with(
              variables: {
                config: {
                  'metrics-addr' => '0.0.0.0:9323',
                  'experimental' => true,
                  'ip6tables' => true,
                  'log-opts' => {
                    'max-size' => '100m',
                    'max-file' => '10',
                  },
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
            expect(chef_run.notify_group('notify yum makecache cuda')).to notify('yum_repository[cuda]').immediately
          end
        end
      when DEBIAN_10
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
          nvidia-driver-latest-dkms
          nvidia-driver-latest-dkms-cuda
          nvidia-driver-latest-dkms-cuda-libs
          nvidia-driver-latest-dkms-devel
          nvidia-driver-latest-dkms-NvFBCOpenGL
          nvidia-driver-latest-dkms-NVML
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
          expect(chef_run).to_not install_package(%w(nvidia-driver-latest-dkms cuda-drivers nvidia-docker2))
        end
      end
    end
  end
end
