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

describe port(2375) do
  it { should be_listening.with('tcp6') }
end
