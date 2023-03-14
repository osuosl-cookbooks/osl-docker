control 'compose' do
  describe command('/usr/local/bin/docker-compose version') do
    its('exit_status') { should eq 0 }
    its('stdout') { should match(/Docker Compose version v2\.15\.0/) }
  end
end
