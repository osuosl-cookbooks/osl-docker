require_relative '../../spec_helper'

describe 'osl-docker::client' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end

      include_context 'common_stubs'

      it 'converges successfully' do
        expect { chef_run }.to_not raise_error
      end

      it { expect(chef_run).to_not add_osl_shell_environment('DOCKER_HOST') }
      it { expect(chef_run).to create_directory('/etc/docker') }
      it { expect(chef_run).to_not create_template('/etc/docker/daemon.json') }
      it { expect(chef_run).to_not create_directory('/etc/docker/ssl') }
      it { expect(chef_run).to_not create_certificate_manage('server-fauxhai-local') }
      it { expect(chef_run).to_not create_certificate_manage('client-fauxhai-local') }

      it do
        expect(chef_run).to_not add_osl_shell_environment('DOCKER_TLS_VERIFY').with(
          value: '1'
        )
      end
      it do
        expect(chef_run).to_not add_osl_shell_environment('DOCKER_CERT_PATH').with(
          value: '/etc/docker/ssl'
        )
      end

      it { expect(chef_run.cron('docker_prune_volumes')).to do_nothing }
      it { expect(chef_run.cron('docker_prune_images')).to do_nothing }
      it { expect(chef_run).to stop_docker_service('default') }
      it { expect(chef_run).to create_docker_service('default') }
    end
  end
end
