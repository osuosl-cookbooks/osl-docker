describe service('docker') do
  it { should_not be_enabled }
  it { should_not be_running }
end

%w(docker dockerd).each do |cmd|
  describe command("#{cmd} --version") do
    its('stdout') { should match(/18\.09\.2/) }
  end
end

describe command('docker ps') do
  its('exit_status') { should eq 1 }
end

describe file('/etc/docker/daemon.json') do
  it { should_not exist }
end

describe crontab do
  its('commands') { should_not include '/usr/bin/docker system prune --volumes -f  > /dev/null' }
  its('commands') { should_not include '/usr/bin/docker system prune -a -f  > /dev/null' }
end
