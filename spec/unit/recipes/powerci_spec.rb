require_relative '../../spec_helper'

describe 'osl-docker::powerci' do
  ALL_RHEL.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p.dup.merge(step_into: %w(osl-docker::default))).converge(described_recipe)
      end
      before do
        stub_command('docker volume inspect ccache').and_return(false)
      end

      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end

      it do
        expect(chef_run).to create_docker_service('default')
        expect(chef_run).to start_docker_service('default').with(
          host: ['unix:///var/run/docker.sock', 'tcp://0.0.0.0:2375']
        )
      end

      it do
        expect(chef_run).to create_cron('docker_prune_volumes').with(
          command: '/usr/bin/docker system prune --volumes -f --filter label!=preserve=true > /dev/null'
        )
      end

      it do
        expect(chef_run).to create_cron('docker_prune_images').with(
          command: '/usr/bin/docker system prune -a -f --filter label!=preserve=true > /dev/null'
        )
      end

      it { expect(chef_run).to run_execute('docker volume create --label preserve=true ccache') }

      context 'ccache volume already exists' do
        cached(:chef_run) do
          ChefSpec::SoloRunner.new(p).converge(described_recipe)
        end
        before do
          stub_command('docker volume inspect ccache').and_return(true)
        end

        it { expect(chef_run).to_not run_execute('docker volume create --label preserve=true ccache') }
      end
    end
  end
end
