# # encoding: utf-8

# Inspec test for recipe osl-docker::nvidia

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/
describe package('nvidia-driver') do
  it { should be_installed }
  its('version') { should eq '410.104-1.el7' }
end

describe package('nvidia-docker2') do
  it { should be_installed }
  its('version') { should eq '2.0.3-1.docker18.09.2.ce' }
end

describe docker.info do
  its('Runtimes.nvidia.path') { should eq 'nvidia-container-runtime' }
end

describe command('nvidia-docker ps') do
  its('exit_status') { should eq 0 }
end
