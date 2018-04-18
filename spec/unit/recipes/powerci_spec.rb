require_relative '../../spec_helper'

describe 'osl-docker::powerci' do
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
          host: ['unix:///var/run/docker.sock', 'tcp://0.0.0.0:2375']
        )
      end
      it do
        expect(chef_run).to create_iptables_ng_rule('docker_ipv4')
          .with(
            rule: [
              '--protocol tcp --source 192.168.6.0/24 --destination-port 2375 --jump ACCEPT',
              '--protocol tcp --source 192.168.6.0/24 --destination-port 2376 --jump ACCEPT',
              '--protocol tcp --source 140.211.168.207/32 --destination-port 2375 --jump ACCEPT',
              '--protocol tcp --source 140.211.168.207/32 --destination-port 2376 --jump ACCEPT'
            ]
          )
      end
      it do
        expect(chef_run).to create_iptables_ng_rule('docker_expose_ipv4')
          .with(
            rule: [
              '--protocol tcp --source 192.168.6.0/24 --destination-port 32768:61000 --jump ACCEPT',
              '--protocol tcp --source 140.211.168.207/32 --destination-port 32768:61000 --jump ACCEPT'
            ]
          )
      end
    end
  end
end
