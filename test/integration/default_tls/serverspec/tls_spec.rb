require 'spec_helper'

docker_env = 'DOCKER_HOST="tcp://127.0.0.1:2376" DOCKER_CERT_PATH="/etc/docker/ssl" DOCKER_TLS_VERIFY="1"'
curl_docker = 'curl -v https://127.0.0.1:2376/images/json ' \
              '--cert /etc/docker/ssl/cert.pem --key /etc/docker/ssl/key.pem --cacert /etc/docker/ssl/ca.pem'

describe 'docker' do
  it_behaves_like 'docker', docker_env
end

describe port(2376) do
  it { should be_listening }
end

describe command(curl_docker) do
  its(:stderr) { should match(/client certificate from file\n.*subject: CN=client/) } if os[:family] == 'redhat'
  its(:stderr) { should match(/Server certificate:\n.*subject: CN=localhost/) }
  its(:stderr) { should match(/Server: Docker/) }
  its(:stdout) { should match(/\[.*\]/) }
  its(:stderr) { should match(%r{HTTP/1.1 200 OK}) }
  its(:stderr) do
    if os[:family] == 'redhat'
      should match(/issuer: E=dnsadmin@osuosl.org,CN=localhost,O=OSU Open Source Lab,L=Corvallis,ST=Oregon,C=US/)
    else
      should match(/issuer: C=US; ST=Oregon; L=Corvallis; O=OSU Open Source Lab; CN=localhost; \
emailAddress=dnsadmin@osuosl.org/)
    end
  end
end
