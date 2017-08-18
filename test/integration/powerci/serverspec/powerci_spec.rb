require 'serverspec'

set :backend, :exec

describe service('docker') do
  it { should be_enabled }
  it { should be_running }
end

describe command('docker --version') do
  its(:stdout) { should match(/1\.13\.1/) }
end

describe command('docker ps') do
  its(:exit_status) { should eq 0 }
end

describe file('/etc/docker/daemon.json') do
  its(:content) { should match %r{"hosts": ['tcp://0.0.0.0:2375']} }
end
