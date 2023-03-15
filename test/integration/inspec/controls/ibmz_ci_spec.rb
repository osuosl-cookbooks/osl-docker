control 'ibmz-ci' do
  describe port(2375) do
    it { should be_listening }
  end

  describe crontab do
    its('commands') { should include '/usr/bin/docker system prune --volumes -f --filter label!=preserve=true > /dev/null' }
    its('commands') { should include '/usr/bin/docker system prune -a -f --filter label!=preserve=true > /dev/null' }
  end

  describe command('docker volume inspect ccache') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(%r{"Mountpoint": "/var/lib/docker/volumes/ccache/_data"}) }
    its('stdout') { should match(/"Name": "ccache"/) }
    its('stdout') { should match(/"Labels": {\n.*"preserve": "true"/) }
  end
end
