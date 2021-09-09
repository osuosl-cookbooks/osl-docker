require_relative '../../spec_helper'

describe 'osl-docker::client' do
  ALL_PLATFORMS.each do |p|
    context "#{p[:platform]} #{p[:version]}" do
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(p).converge(described_recipe)
      end

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

      case p
      when CENTOS_7
        it { expect(chef_run).to include_recipe('yum-plugin-versionlock') }

        it do
          expect(chef_run).to remove_yum_version_lock('docker-ce').with(
            version: '18.09.2',
            release: '3.el7'
          )
        end
        it do
          expect(chef_run).to remove_yum_version_lock('docker-ce-cli').with(
            version: '18.09.2',
            release: '3.el7'
          )
        end
      when DEBIAN_10
        it do
          expect(chef_run).to remove_apt_preference('docker-ce').with(
            pin: 'version 5:18.09.2~3-0~debian-buster',
            pin_priority: '1001'
          )
        end

        it do
          expect(chef_run).to remove_apt_preference('docker-ce-cli').with(
            pin: 'version 5:18.09.2~3-0~debian-buster',
            pin_priority: '1001'
          )
        end
      end
    end
  end
end
