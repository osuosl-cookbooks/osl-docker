require 'spec_helper'

describe 'docker' do
  it_behaves_like 'docker'
end

describe port(2375) do
  it { should be_listening }
end

describe cron do
  its(:table) { should match(%r{^DOCKER_HOST=tcp://0\.0\.0\.0:2375$}) }
end

describe iptables do
  it { should have_rule('-A docker -s 192.168.6.0/24 -p tcp -m tcp --dport 2375 -j ACCEPT') }
  it { should have_rule('-A docker -s 192.168.6.0/24 -p tcp -m tcp --dport 2376 -j ACCEPT') }
  it { should have_rule('-A docker -s 192.168.6.0/24 -p tcp -m tcp --dport 32768:61000 -j ACCEPT') }
end
