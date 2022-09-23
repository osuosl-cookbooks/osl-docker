require_relative '../../spec_helper'

describe 'osl-docker::nvidia' do
  CENTOS_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end

      it { is_expected.to install_osl_nvidia_driver('latest') }

      it do
        is_expected.to create_yum_repository('libnvidia-container').with(
        )
      end

      it { is_expected.to install_package('nvidia-docker2') }
      it { is_expected.to include_recipe('osl-docker') }

      it do
        is_expected.to create_template('/etc/docker/daemon.json')
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

      case p
      when CENTOS_7
        it { is_expected.to create_selinux_module('nvidia_docker') }
      when CENTOS_8
        it { is_expected.to_not create_selinux_module('nvidia_docker') }
      end
    end
  end
end
