require_relative '../../spec_helper'

describe 'osl-docker::workstation' do
  ALL_DEBIAN.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end

      include_context 'common_stubs'

      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to create_docker_service('default')
        expect(chef_run).to start_docker_service('default').with(
          host: ['unix:///var/run/docker.sock', 'tcp://127.0.0.1:2375']
        )
      end
      it do
        expect(chef_run).to add_osl_shell_environment('DOCKER_HOST').with(
          value: 'tcp://127.0.0.1:2375'
        )
      end
    end
  end
end
