#
# Cookbook:: osl-docker
# Recipe:: default
#
# Copyright:: 2017-2024, Oregon State University
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
include_recipe 'osl-selinux' if platform_family?('rhel')

osl_firewall_docker 'osl-docker'

osl_firewall_port 'docker_exporter' do
  service_name 'prometheus'
  ports %w(9323)
end

cron_package 'osl-docker'
cron_service 'osl-docker' do
  action [:enable, :start]
end

node.default['osl-docker']['service']['misc_opts'] = '--live-restore'
node.default['osl-docker']['service']['host'] = ['unix:///var/run/docker.sock']
node.default['osl-docker']['service']['host'] << node['osl-docker']['host'] unless node['osl-docker']['host'].nil?

docker_service 'default' do
  node['osl-docker']['service'].each do |key, value|
    send(key.to_sym, value)
  end
  if node['osl-docker']['tls'] && ::File.exist?('/etc/docker/ssl/key.pem')
    tls_verify true
    tls_ca_cert '/etc/docker/ssl/ca.pem'
    tls_server_cert '/etc/docker/ssl/server.pem'
    tls_server_key '/etc/docker/ssl/server-key.pem'
    tls_client_cert '/etc/docker/ssl/cert.pem'
    tls_client_key '/etc/docker/ssl/key.pem'
  end
  if node['osl-docker']['client_only']
    action [:create, :stop]
  elsif !node['osl-docker']['tls'] || ::File.exist?('/etc/docker/ssl/key.pem')
    action [:create, :start]
  else
    action [:create]
  end
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
  notifies :restart, 'docker_service[default]'
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
  notifies :restart, 'docker_service[default]'
end

if node['osl-docker']['host'] # use if instead of not_if to fix nil value validation
  osl_shell_environment 'DOCKER_HOST' do
    value node['osl-docker']['host']
  end
end

osl_shell_environment 'DOCKER_TLS_VERIFY' do
  value '1'
  only_if { node['osl-docker']['tls'] }
  notifies :restart, 'docker_service[default]'
end

osl_shell_environment 'DOCKER_CERT_PATH' do
  value '/etc/docker/ssl'
  only_if { node['osl-docker']['tls'] }
  notifies :restart, 'docker_service[default]'
end

volume_filter = []
unless node['osl-docker']['prune']['volume_filter'].empty?
  node['osl-docker']['prune']['volume_filter'].each do |f|
    volume_filter << "--filter #{f}"
  end
end

cron 'docker_prune_volumes' do
  minute '15'
  command "/usr/bin/docker system prune --volumes -f #{volume_filter.join(' ')} > /dev/null"
  not_if { node['osl-docker']['client_only'] }
end

cron 'docker_prune_images' do
  minute '45'
  hour '2'
  weekday '0'
  command "/usr/bin/docker system prune -a -f #{volume_filter.join(' ')} > /dev/null"
  not_if { node['osl-docker']['client_only'] }
end

# In the event the node is utilizing iptables, sync docker to restart when iptables restarts.
# Docker automatically adds extra rules to iptables, but these changes are not saved on reloads.
osl_systemd_unit_drop_in 'iptables-fix' do
  unit_name 'docker.service'
  content({
    'Unit' => {
      'PartOf' => 'iptables.service',
    },
  })
end
