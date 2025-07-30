control 'osl_dockercompose' do
  describe docker_container 'test-hello_world-1' do
    it { should exist }
    it { should be_running }
    its('image') { should eq 'alpine' }
    its('command') { should eq '/bin/sleep 1d' }
    its('labels') { should include 'com.docker.compose.project=test' }
    its('labels') { should include 'com.docker.compose.service=hello_world' }
  end

  describe docker_container 'services-hello_world1-1' do
    it { should exist }
    it { should be_running }
    its('image') { should eq 'alpine' }
    its('command') { should eq '/bin/sleep 1d' }
    its('labels') { should include 'com.docker.compose.project=services' }
    its('labels') { should include 'com.docker.compose.service=hello_world1' }
  end

  describe docker_container 'services-hello_world2-1' do
    it { should exist }
    it { should be_running }
    its('image') { should eq 'alpine' }
    its('command') { should eq '/bin/sleep 1d' }
    its('labels') { should include 'com.docker.compose.depends_on=hello_world1:service_started:false' }
    its('labels') { should include 'com.docker.compose.project=services' }
    its('labels') { should include 'com.docker.compose.service=hello_world2' }
  end
end
