require_relative '../../helpers/inspec/docker_helper.rb'

inspec_docker?

describe file('/etc/docker/daemon.json') do
  its('content') do
    should match(/{
  "metrics-addr": "0.0.0.0:9323",
  "experimental": true
}/)
  end
end

describe crontab.where { command =~ /docker system prune --volumes/ } do
  its('minutes') { should cmp '15' }
  its('hours') { should cmp '*' }
  its('days') { should cmp '*' }
  its('months') { should cmp '*' }
end

describe crontab.where { command =~ /docker system prune -a -f/ } do
  its('minutes') { should cmp '45' }
  its('hours') { should cmp '2' }
  its('days') { should cmp '*' }
  its('months') { should cmp '*' }
  its('weekdays') { should cmp '0' }
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
  its('stdout') { should match(/^engine_daemon_engine_info.*/) }
  its('exit_status') { should eq 0 }
end
