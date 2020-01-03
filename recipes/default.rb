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
if node['platform_family'] == 'rhel'
  include_recipe 'yum-plugin-versionlock'

  # Remove repos which were created by chef-yum-docker cookbook that we no longer use
  %w(
    docker-main
    docker-stable
    docker-edge
    docker-test
  ).each do |r|
    yum_repository r do
      action :delete
    end
  end

  yum_version_lock node['osl-docker']['package_cli_name'] do
    version node['osl-docker']['package']['version']
    release node['osl-docker']['package_release']
    epoch 1
    action :update
  end

  yum_version_lock node['osl-docker']['package']['package_name'] do
    version node['osl-docker']['package']['version']
    release node['osl-docker']['package_release']
    epoch 3
    action :update
  end

  # Use our docker repo for ppc64le & s390x
  yum_repository 'Docker' do
    baseurl 'https://ftp.osuosl.org/pub/osl/repos/yum/$releasever/docker-stable/$basearch'
    gpgkey 'https://ftp.osuosl.org/pub/osl/repos/yum/RPM-GPG-KEY-osuosl'
    description 'Docker Stable repository'
    gpgcheck true
    enabled true
    only_if { %w(ppc64le s390x).include?(node['kernel']['machine']) }
  end

  # TODO: Use CentOS 7 repo on CentOS 8 until upstream has created the repo
  yum_repository 'Docker' do
    baseurl 'https://download.docker.com/linux/centos/7/x86_64/stable'
    gpgkey 'https://download.docker.com/linux/centos/gpg'
    description 'Docker Stable repository'
    gpgcheck true
    enabled true
    # Enable all rpms to workaround modularity issue:
    # https://forums.docker.com/t/yum-repo-for-centos-8/81884/8
    options(module_hotfixes: true)
    only_if { node['platform_version'].to_i >= 8 && node['kernel']['machine'] == 'x86_64' }
  end
end

if node['platform_family'] == 'debian'
  package 'dirmngr'

  # Remove repos which were created by chef-apt-docker cookbook that we no longer use
  %w(
    docker-main
    docker-stable
    docker-edge
    docker-test
  ).each do |r|
    apt_repository r do
      action :remove
    end
  end

  [
    node['osl-docker']['package']['package_name'],
    node['osl-docker']['package_cli_name'],
  ].each do |p|
    apt_preference p do
      pin "version #{node['osl-docker']['package']['version']}*"
      pin_priority '1001'
    end
  end
end

include_recipe 'firewall::prometheus'

firewall_prometheus 'docker_exporter' do
  port 9323
end

docker_installation_package 'default' do
  node['osl-docker']['package'].each do |key, value|
    send(key.to_sym, value)
  end
  action :create
  notifies :restart, 'docker_service[default]' unless node['osl-docker']['client_only']
end

directory '/etc/docker'

template '/etc/docker/daemon.json' do
  variables(
    config: node['osl-docker']['daemon']
  )
  not_if { node['osl-docker']['client_only'] }
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
  not_if { node['osl-docker']['host'].nil? }
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
  # Don't try to install docker twice since we do it above
  install_method 'none'
  if node['osl-docker']['tls']
    tls_verify true
    tls_ca_cert '/etc/docker/ssl/ca.pem'
    tls_server_cert '/etc/docker/ssl/server.pem'
    tls_server_key '/etc/docker/ssl/server-key.pem'
    tls_client_cert '/etc/docker/ssl/cert.pem'
    tls_client_key '/etc/docker/ssl/key.pem'
  end
  not_if { node['osl-docker']['client_only'] }
  action [:create, :start]
end

service 'docker' do
  action [:disable, :stop]
  only_if { node['osl-docker']['client_only'] }
end

volume_filter = []
unless node['osl-docker']['prune']['volume_filter'].empty?
  node['osl-docker']['prune']['volume_filter'].each do |f|
    volume_filter << "--filter #{f}"
  end
end

cron 'docker_prune_volumes' do
  minute 15
  command "/usr/bin/docker system prune --volumes -f #{volume_filter.join(' ')} > /dev/null"
  not_if { node['osl-docker']['client_only'] }
end

cron 'docker_prune_images' do
  minute 45
  hour 2
  weekday 0
  command "/usr/bin/docker system prune -a -f #{volume_filter.join(' ')} > /dev/null"
  not_if { node['osl-docker']['client_only'] }
end
