describe command('/usr/local/bin/docker-compose version') do
  its('exit_status') { should eq 0 }
  its('stdout') { should match(/docker-compose version 1\.18\.0/) }
end
