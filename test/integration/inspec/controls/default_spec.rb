docker_env = input('docker_env')
client_only = input('client_only')
tls = input('tls')

control 'default' do
  describe file '/etc/docker' do
    it { should be_directory }
  end

  describe service 'docker' do
    if client_only
      it { should_not be_enabled }
      it { should_not be_running }
    else
      it { should be_enabled }
      it { should be_running }
    end
  end

  describe file '/etc/systemd/system/docker.service.d/iptables-fix.conf' do
    it { should exist }
    its('content') { should match 'PartOf = iptables.service' }
  end

  %w(docker dockerd).each do |cmd|
    describe command "#{cmd} --version" do
      its('stdout') { should match(/2[0-9].[0-9]/) }
    end
  end

  describe command "#{docker_env} docker ps" do
    if client_only
      its('exit_status') { should eq 1 }
    else
      its('exit_status') { should eq 0 }
    end
  end

  describe command 'docker ps' do
    if client_only
      its('exit_status') { should eq 1 }
    else
      its('exit_status') { should eq 0 }
    end
  end

  describe iptables do
    it { should_not have_rule('-A INPUT -j REJECT --reject-with icmp-host-prohibited') }
  end

  if client_only
    describe file '/etc/docker/daemon.json' do
      it { should_not exist }
    end

    describe crontab do
      its('commands') { should_not include '/usr/bin/docker system prune --volumes -f  > /dev/null' }
      its('commands') { should_not include '/usr/bin/docker system prune -a -f  > /dev/null' }
    end
  else
    describe docker.info do
      its('LiveRestoreEnabled') { should eq true }
      its(%w(RegistryConfig Mirrors)) { should eq %w(https://registry.osuosl.org/) }
    end

    describe json '/etc/docker/daemon.json' do
      its('metrics-addr') { should cmp '0.0.0.0:9323' }
      its('experimental') { should cmp 'true' }
      its('registry-mirrors') { should cmp %w(https://registry.osuosl.org) }
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

    describe port 9323 do
      it { should be_listening }
    end

    describe iptables do
      it { should have_rule('-A prometheus -p tcp -m tcp --dport 9323 -j osl_only') }
    end

    describe ip6tables do
      it { should have_rule('-A prometheus -p tcp -m tcp --dport 9323 -j osl_only') }
    end

    describe http 'http://localhost:9323/metrics' do
      its('status') { should cmp 200 }
      its('body') { should match(/^engine_daemon_engine_info.*/) }
    end

    if tls
      curl_docker = 'curl -v https://127.0.0.1:2376/images/json ' \
                    '--cert /etc/docker/ssl/cert.pem --key /etc/docker/ssl/key.pem --cacert /etc/docker/ssl/ca.pem'

      describe port 2376 do
        it { should be_listening }
      end

      describe command(curl_docker) do
        its('stderr') { should match(/Server certificate:\n.*subject: CN=localhost/) }
        its('stderr') { should match(/Server: Docker/) }
        its('stdout') { should match(/\[.*\]/) }
        its('stderr') { should match(%r{HTTP/1.1 200 OK}) }
        its('stderr') do
          should match(/issuer: C=US; ST=Oregon; L=Corvallis; O=OSU Open Source Lab; CN=localhost; emailAddress=dnsadmin@osuosl.org/)
        end
      end
    end
  end
end
