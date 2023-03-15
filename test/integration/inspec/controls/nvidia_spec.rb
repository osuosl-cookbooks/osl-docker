os_release = os.release.to_i

control 'nvidia' do
  if os_release >= 8
    describe package('nvidia-driver') do
      it { should be_installed }
    end
  else
    describe package('nvidia-driver-latest-dkms') do
      it { should be_installed }
    end
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
