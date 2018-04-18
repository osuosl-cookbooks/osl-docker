require_relative '../../spec_helper'

describe 'osl-docker::ibmz_ci' do
  CENTOS_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to create_docker_service('default').with(
          host: ['unix:///var/run/docker.sock', 'tcp://0.0.0.0:2376']
        )
      end
      it do
        expect(chef_run).to create_docker_volume('ccache')
      end
    end
  end
end
