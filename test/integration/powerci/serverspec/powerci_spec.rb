require 'spec_helper'

describe 'docker' do
  it_behaves_like 'docker', 'DOCKER_HOST="tcp://0.0.0.0:2375"'
end

describe port(2375) do
  it { should be_listening }
end

describe iptables do
  ['192.168.6.0/24', '140.211.168.207/32'].each do |ip|
    it { should have_rule("-A docker -s #{ip} -p tcp -m tcp --dport 2375 -j ACCEPT") }
    it { should have_rule("-A docker -s #{ip} -p tcp -m tcp --dport 2376 -j ACCEPT") }
    it { should have_rule("-A docker -s #{ip} -p tcp -m tcp --dport 32768:61000 -j ACCEPT") }
  end
end

describe command('docker volume inspect ccache') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match(%r{"Mountpoint": "/var/lib/docker/volumes/ccache/_data"}) }
  its(:stdout) { should match(/"Name": "ccache"/) }
  its(:stdout) { should match(/"Labels": {\n.*"preserve": "true"/) }
end
