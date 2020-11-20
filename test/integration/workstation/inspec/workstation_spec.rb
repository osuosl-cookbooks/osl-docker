require_relative '../../helpers/inspec/docker_helper'

inspec_docker?('DOCKER_HOST="tcp://127.0.0.1:2375"')

describe port(2375) do
  it { should be_listening }
  its('addresses') { should cmp '127.0.0.1' }
  its('protocols') { should cmp 'tcp' }
end
