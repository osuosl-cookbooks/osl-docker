require_relative '../../spec_helper'

describe 'osl-docker::workstation' do
  DEBIAN_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to create_docker_service('default').with(
          host: ['tcp://127.0.0.1:2375']
        )
      end
      it do
        expect(chef_run).to add_magic_shell_environment('DOCKER_HOST').with(
          value: 'tcp://127.0.0.1:2375'
        )
      end
      it do
        expect(chef_run).to delete_systemd_socket('docker')
      end
    end
  end
end
