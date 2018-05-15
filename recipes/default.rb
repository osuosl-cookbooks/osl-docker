#
# Cookbook:: osl-docker
# Recipe:: default
#
# Copyright:: 2017, Oregon State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
if node['platform_family'] == 'rhel' && node['kernel']['machine'] != 's390x'
  include_recipe 'yum-docker'
  include_recipe 'yum-plugin-versionlock'

  if node['kernel']['machine'] == 'ppc64le'
    edit_resource(:yum_repository, 'docker-main') do
      baseurl 'http://ftp.unicamp.br/pub/ppc64el/rhel/7/docker-ppc64el/'
      gpgcheck false
    end
  else
    edit_resource(:yum_repository, 'docker-main') do
      baseurl 'https://download.docker.com/linux/centos/7/x86_64/stable/'
      gpgkey 'https://download.docker.com/linux/centos/gpg'
    end
  end

  yum_version_lock node['osl-docker']['package']['package_name'] do
    version node['osl-docker']['package']['version']
    release node['osl-docker']['package_release']
    notifies :makecache, 'yum_repository[docker-main]', :immediately
  end
end

# Needed on Debian 9 to import the GPG key
package 'dirmngr' do
  only_if { node['platform_family'] == 'debian' && node['platform_version'].to_i >= 9 }
end

apt_repository 'docker-main' do
  uri 'https://download.docker.com/linux/debian'
  components %w(stable)
  distribution node['lsb']['codename']
  keyserver 'hkp://p80.pool.sks-keyservers.net:80'
  key '0EBFCD88'
  only_if { node['platform_family'] == 'debian' }
end

apt_preference node['osl-docker']['package']['package_name'] do
  pin "version #{node['osl-docker']['package']['version']}*"
  pin_priority '1001'
  only_if { node['platform_family'] == 'debian' }
end

docker_installation_tarball 'default' do
  node['osl-docker']['tarball'].each do |key, value|
    send(key.to_sym, value)
  end
  only_if { node['kernel']['machine'] == 's390x' }
  notifies :restart, 'docker_service[default]'
end

group 'docker' do
  system true
  only_if { node['kernel']['machine'] == 's390x' }
end

docker_installation_package 'default' do
  node['osl-docker']['package'].each do |key, value|
    send(key.to_sym, value)
  end
  not_if { node['kernel']['machine'] == 's390x' }
  notifies :restart, 'docker_service[default]'
end

directory '/etc/docker/ssl' do
  owner 'root'
  group 'docker'
  mode '0750'
  recursive true
  only_if { node['osl-docker']['tls'] }
end

certificate_manage "server-#{node['fqdn'].tr('.', '-')}" do
  data_bag node['osl-docker']['data_bag']
  cert_path '/etc/docker/ssl'
  chain_file 'ca.pem'
  cert_file 'server.pem'
  key_file 'server-key.pem'
  owner 'root'
  group 'docker'
  create_subfolders false
  only_if { node['osl-docker']['tls'] }
  notifies :restart, 'docker_service[default]'
end

certificate_manage "client-#{node['fqdn'].tr('.', '-')}" do
  data_bag node['osl-docker']['data_bag']
  cert_path '/etc/docker/ssl'
  chain_file 'ca.pem'
  cert_file 'cert.pem'
  key_file 'key.pem'
  owner 'root'
  group 'docker'
  create_subfolders false
  only_if { node['osl-docker']['tls'] }
end

node.default['osl-docker']['service']['host'] = ['unix:///var/run/docker.sock']
node.default['osl-docker']['service']['host'] << node['osl-docker']['host'] unless node['osl-docker']['host'].nil?

magic_shell_environment 'DOCKER_HOST' do
  value node['osl-docker']['host']
  only_if { node['osl-docker']['host'] }
end

magic_shell_environment 'DOCKER_TLS_VERIFY' do
  value '1'
  only_if { node['osl-docker']['tls'] }
end

magic_shell_environment 'DOCKER_CERT_PATH' do
  value '/etc/docker/ssl'
  only_if { node['osl-docker']['tls'] }
end

docker_service 'default' do
  node['osl-docker']['service'].each do |key, value|
    send(key.to_sym, value)
  end
  if node['osl-docker']['tls']
    tls_verify true
    tls_ca_cert '/etc/docker/ssl/ca.pem'
    tls_server_cert '/etc/docker/ssl/server.pem'
    tls_server_key '/etc/docker/ssl/server-key.pem'
    tls_client_cert '/etc/docker/ssl/cert.pem'
    tls_client_key '/etc/docker/ssl/key.pem'
  end
  action [:create, :start]
end

cron 'docker_prune_volumes' do
  minute 15
  command '/usr/bin/docker system prune --volumes -f > /dev/null'
end

cron 'docker_prune_images' do
  minute 45
  hour 2
  weekday 0
  command '/usr/bin/docker system prune -a -f > /dev/null'
end
