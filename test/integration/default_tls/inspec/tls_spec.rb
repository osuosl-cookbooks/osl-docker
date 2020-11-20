require_relative '../../helpers/inspec/docker_helper'

docker_env = 'DOCKER_HOST="tcp://127.0.0.1:2376" DOCKER_CERT_PATH="/etc/docker/ssl" DOCKER_TLS_VERIFY="1"'
curl_docker = 'curl -v https://127.0.0.1:2376/images/json ' \
              '--cert /etc/docker/ssl/cert.pem --key /etc/docker/ssl/key.pem --cacert /etc/docker/ssl/ca.pem'
operating_system = os.family
release = os.release.to_i

inspec_docker?(docker_env)

describe port(2376) do
  it { should be_listening }
end

describe command(curl_docker) do
  its('stderr') { should match(/Server certificate:\n.*subject: CN=localhost/) }
  its('stderr') { should match(/Server: Docker/) }
  its('stdout') { should match(/\[.*\]/) }
  its('stderr') { should match(%r{HTTP/1.1 200 OK}) }
  if operating_system == 'redhat' && release < 8
    its('stderr') { should match(/client certificate from file\n.*subject: CN=client/) }
    its('stderr') do
      should match(/issuer: E=dnsadmin@osuosl.org,CN=localhost,O=OSU Open Source Lab,L=Corvallis,ST=Oregon,C=US/)
    end
  else
    its('stderr') do
      should match(/issuer: C=US; ST=Oregon; L=Corvallis; O=OSU Open Source Lab; CN=localhost; \
emailAddress=dnsadmin@osuosl.org/)
    end
  end
end
