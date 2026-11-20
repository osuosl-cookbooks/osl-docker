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

  describe docker_container 'pulled-busy-1' do
    it { should exist }
    it { should be_running }
    its('image') { should eq 'busybox:latest' }
  end

  # The first converge started this container on busybox:1.36 tagged as latest;
  # pull_images, on by default, had to pull the real latest and recreate it to get here.
  latest = command("docker image inspect -f '{{.Id}}' busybox:latest").stdout.strip
  old = command("docker image inspect -f '{{.Id}}' busybox:1.36").stdout.strip

  describe command("docker inspect -f '{{.Image}}' pulled-busy-1") do
    its('exit_status') { should eq 0 }
    its('stdout.strip') { should eq latest }
    its('stdout.strip') { should_not eq old }
  end

  # held opted out with pull_images false, so it still runs the busybox:1.36 it started on
  describe command("docker inspect -f '{{.Image}}' held-busy-1") do
    its('exit_status') { should eq 0 }
    its('stdout.strip') { should eq old }
    its('stdout.strip') { should_not eq latest }
  end
end
