control 'workstation' do
  describe port(2375) do
    it { should be_listening }
    its('addresses') { should cmp '127.0.0.1' }
    its('protocols') { should cmp 'tcp' }
  end
end
