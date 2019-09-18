require 'spec_helper'

describe 'docker' do
  it_behaves_like 'docker'
end

describe file('/etc/docker/daemon.json') do
  its(:content) do
    should match(/{
  "metrics-addr": "0.0.0.0:9323",
  "experimental": true
}/)
  end
end

describe cron do
  it { should have_entry('15 * * * * /usr/bin/docker system prune --volumes -f  > /dev/null') }
  it { should have_entry('45 2 * * 0 /usr/bin/docker system prune -a -f  > /dev/null') }
end

describe port(9323) do
  it { should be_listening }
end

describe iptables do
  it { should have_rule('-A prometheus -s 10.1.0.0/23 -p tcp -m tcp --dport 9323 -j ACCEPT') }
end

describe ip6tables do
  it { should have_rule('-A prometheus -s 2605:bc80:3010::/48 -p tcp -m tcp --dport 9323 -j ACCEPT') }
end

describe command('curl http://localhost:9323/metrics') do
  its(:stdout) { should match(/^engine_daemon_engine_info.*/) }
  its(:exit_status) { should eq 0 }
end
