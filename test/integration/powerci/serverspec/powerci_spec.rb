require 'serverspec'

set :backend, :exec

describe service('docker') do
  it { should be_enabled }
  it { should be_running }
end

describe command('docker --version') do
  its(:stdout) { should match(/17\.06\.1-ce/) }
end

describe command('docker ps') do
  its(:exit_status) { should eq 0 }
end

describe port(2375) do
  it { should be_listening }
end

describe iptables do
  it { should have_rule('-A docker -s 192.168.6.0/24 -p tcp -m tcp --dport 2375 -j ACCEPT') }
  it { should have_rule('-A docker -s 192.168.6.0/24 -p tcp -m tcp --dport 2376 -j ACCEPT') }
  it { should have_rule('-A docker -s 192.168.6.0/24 -p tcp -m tcp --dport 32768:61000 -j ACCEPT') }
end
