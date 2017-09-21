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

include_recipe 'apt-docker' if node['platform_family'] == 'debian'

apt_preference node['osl-docker']['package']['package_name'] do
  pin "version #{node['osl-docker']['package']['version']}*"
  pin_priority '1001'
  only_if { node['platform_family'] == 'debian' }
end

docker_installation_package 'default' do
  node['osl-docker']['package'].each do |key, value|
    send(key.to_sym, value)
  end
end

docker_service 'default' do
  node['osl-docker']['service'].each do |key, value|
    send(key.to_sym, value)
  end
  action [:create, :start]
end
