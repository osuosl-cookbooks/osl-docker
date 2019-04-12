require 'serverspec'
set :backend, :exec

shared_examples_for 'docker' do |docker_env|
  describe service('docker') do
    it { should be_enabled }
    it { should be_running }
  end

  %w(docker dockerd).each do |cmd|
    describe command("#{cmd} --version") do
      if os[:family] == 'debian' && os[:release].to_i == 8
        its(:stdout) { should match(/18\.06\.3/) }
      else
        its(:stdout) { should match(/18\.09\.2/) }
      end
    end
  end

  describe command("#{docker_env} docker ps") do
    its(:exit_status) { should eq 0 }
  end

  describe command('docker ps') do
    its(:exit_status) { should eq 0 }
  end
end
