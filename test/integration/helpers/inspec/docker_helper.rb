def inspec_docker?(docker_env = '')
  describe file('/etc/docker') do
    it { should be_directory }
  end

  describe service('docker') do
    it { should be_enabled }
    it { should be_running }
  end

  %w(docker dockerd).each do |cmd|
    describe command("#{cmd} --version") do
      its('stdout') { should match(/18\.09\.2/) }
    end
  end

  describe command("#{docker_env} docker ps") do
    its('exit_status') { should eq 0 }
  end

  describe command('docker ps') do
    its('exit_status') { should eq 0 }
  end
end
