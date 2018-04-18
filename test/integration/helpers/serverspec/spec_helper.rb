require 'serverspec'
set :backend, :exec

shared_examples_for 'docker' do |docker_env|
  describe service('docker') do
    it { should be_enabled }
    it { should be_running }
  end

  describe command('docker --version') do
    its(:stdout) { should match(/17\.09\.0-ce/) }
  end

  describe command("#{docker_env} docker ps") do
    its(:exit_status) { should eq 0 }
  end

  describe command('docker ps') do
    its(:exit_status) { should eq 0 }
  end
end
