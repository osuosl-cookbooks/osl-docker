require 'serverspec'
set :backend, :exec

shared_examples_for 'docker' do |docker_env|
  describe service('docker') do
    it { should be_enabled }
    it { should be_running }
  end

  describe command('docker --version') do
    case os[:family]
    when 'redhat'
      its(:stdout) { should match(/17\.06\.1-ce/) }
    when 'debian'
      its(:stdout) { should match(/17\.05\.0-ce/) }
    end
  end

  describe command("#{docker_env} docker ps") do
    its(:exit_status) { should eq 0 }
  end
end
