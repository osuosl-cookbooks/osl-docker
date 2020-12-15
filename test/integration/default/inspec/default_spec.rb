require_relative '../../helpers/inspec/docker_helper'

inspec_docker?

describe json('/etc/docker/daemon.json') do
  its('metrics-addr') { should cmp '0.0.0.0:9323' }
  its('experimental') { should cmp 'true' }
  its(%w(log-opts max-size)) { should cmp '100m' }
  its(%w(log-opts max-file)) { should cmp '10' }
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
  it { should have_rule('-A prometheus -p tcp -m tcp --dport 9323 -j osl_only') }
end

describe ip6tables do
  it { should have_rule('-A prometheus -p tcp -m tcp --dport 9323 -j osl_only') }
end

describe http('http://localhost:9323/metrics') do
  its('status') { should cmp 200 }
  its('body') { should match(/^engine_daemon_engine_info.*/) }
end
