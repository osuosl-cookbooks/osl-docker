require 'spec_helper'

docker_env = 'DOCKER_HOST="tcp://0.0.0.0:2376" DOCKER_CERT_PATH="/etc/docker/ssl" DOCKER_TLS_VERIFY="1"'

describe 'docker' do
  it_behaves_like 'docker', docker_env
end

describe port(2376) do
  it { should be_listening }
end
