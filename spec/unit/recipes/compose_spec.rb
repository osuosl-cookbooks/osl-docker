require_relative '../../spec_helper'

describe 'osl-docker::compose' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end
      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end
      it do
        expect(chef_run).to create_remote_file('/usr/local/bin/docker-compose')
          .with(
            source: 'https://github.com/docker/compose/releases/download/1.18.0/docker-compose-Linux-x86_64',
            checksum: 'b2f2c3834107f526b1d9cc8d8e0bdd132c6f1495b036a32cbc61b5288d2e2a01',
            mode: '0755'
          )
      end
      case p
      when CENTOS_7
        context 'ppc64le' do
          cached(:chef_run) do
            ChefSpec::SoloRunner.new(p) do |node|
              node.automatic['kernel']['machine'] = 'ppc64le'
            end.converge(described_recipe)
          end
          it do
            expect(chef_run).to create_remote_file('/usr/local/bin/docker-compose')
              .with(
                source: 'http://ftp.osuosl.org/pub/osl/openpower/docker-compose/1.18.0/docker-compose-Linux-ppc64le',
                checksum: '4458de249ca5f776738e44a6af2f869c1186b2d018dd15705045aa01a45e50c5',
                mode: '0755'
              )
          end
        end
      end
    end
  end
end
