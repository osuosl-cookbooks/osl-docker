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

  describe docker_container 'oneshot-hello_world-1' do
    it { should exist }
    it { should be_running }
    its('image') { should eq 'alpine' }
    its('command') { should eq '/bin/sleep 1d' }
    its('labels') { should include 'com.docker.compose.project=oneshot' }
    its('labels') { should include 'com.docker.compose.service=hello_world' }
  end

  # The exited migrate container was reaped after the first converge; if the
  # running check miscounted the one-shot, the second converge would have
  # re-run `up` and recreated it.
  describe docker_container 'oneshot-migrate-1' do
    it { should_not exist }
  end
end
