require 'spec_helper'

describe 'docker' do
  it_behaves_like 'docker', 'DOCKER_HOST="tcp://127.0.0.1:2375"'
end

describe port(2375) do
  it { should be_listening.on('127.0.0.1').with('tcp') }
end
