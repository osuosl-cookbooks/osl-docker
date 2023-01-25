require_relative '../../spec_helper'

version = 'v2.15.0'

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
            source: "https://github.com/docker/compose/releases/download/#{version}/docker-compose-linux-x86_64",
            checksum: 'ba481d45be2b137a2a185abd05f61d6d7766dbedfa038f16e4705760767a206e',
            mode: '0755'
          )
      end
      case p
      when CENTOS_7
        context 'aarch64' do
          cached(:chef_run) do
            ChefSpec::SoloRunner.new(p) do |node|
              node.automatic['kernel']['machine'] = 'aarch64'
            end.converge(described_recipe)
          end
          it do
            expect(chef_run).to include_recipe 'osl-selinux'
          end
          it do
            expect(chef_run).to create_remote_file('/usr/local/bin/docker-compose')
              .with(
                source: "https://github.com/docker/compose/releases/download/#{version}/docker-compose-linux-aarch64",
                checksum: '14d31297794868520cb2e61b543bb1c821aaa484af22b397904314ae8227f6a2',
                mode: '0755'
              )
          end
        end
        context 'ppc64le' do
          cached(:chef_run) do
            ChefSpec::SoloRunner.new(p) do |node|
              node.automatic['kernel']['machine'] = 'ppc64le'
            end.converge(described_recipe)
          end
          it do
            expect(chef_run).to include_recipe 'osl-selinux'
          end
          it do
            expect(chef_run).to create_remote_file('/usr/local/bin/docker-compose')
              .with(
                source: "http://ftp.osuosl.org/pub/osl/openpower/docker-compose/#{version}/docker-compose-linux-ppc64le",
                checksum: '2b57f69c438fadaa88dc383d8df8b98955a2ab9262c7ca2524102c8199c8efb4',
                mode: '0755'
              )
          end
        end
      when CENTOS_8
        it do
          expect(chef_run).to include_recipe 'osl-selinux'
        end
      end
    end
  end
end
