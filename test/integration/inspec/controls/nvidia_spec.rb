control 'nvidia' do
  describe package('nvidia-driver') do
    it { should be_installed }
  end

  describe package('nvidia-docker2') do
    it { should be_installed }
  end

  describe docker.info do
    its('Runtimes.nvidia.path') { should eq 'nvidia-container-runtime' }
  end

  describe command('nvidia-docker ps') do
    its('exit_status') { should eq 0 }
  end
end
