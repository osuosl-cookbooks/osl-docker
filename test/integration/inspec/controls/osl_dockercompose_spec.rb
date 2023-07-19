control 'osl_dockercompose' do
  describe docker_container 'test-hello_world-1' do
    it { should exist }
    it { should be_running }
    its('image') { should eq 'alpine' }
    its('command') { should eq '/bin/sleep 1d' }
  end
end
