#
# Cookbook:: osl-docker
# Recipe:: nvidia
#
# Copyright:: 2019, Oregon State University
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
return unless node['platform_family'] == 'rhel'

node.default['osl-docker']['daemon']['runtimes'] = {
  nvidia: {
    path: 'nvidia-container-runtime',
    runtimeArgs: [],
  },
}

include_recipe 'yum-epel'
include_recipe 'yum-nvidia'
include_recipe 'osl-docker'
include_recipe 'yum-plugin-versionlock'

build_essential 'nvidia'

version_lock = node['osl-docker']['nvidia']['version_lock']
makecache_file = ::File.join(Chef::Config[:file_cache_path], 'makecache-cuda')

%w(
  dkms-nvidia
  nvidia-driver
  nvidia-driver-cuda
  nvidia-driver-cuda-libs
  nvidia-driver-devel
  nvidia-driver-latest-dkms
  nvidia-driver-latest-dkms-cuda
  nvidia-driver-latest-dkms-cuda-libs
  nvidia-driver-latest-dkms-devel
  nvidia-driver-latest-dkms-NvFBCOpenGL
  nvidia-driver-latest-dkms-NVML
  nvidia-driver-libs
  nvidia-driver-NvFBCOpenGL
  nvidia-driver-NVML
  nvidia-libXNVCtrl
  nvidia-libXNVCtrl-devel
  nvidia-modprobe
  nvidia-persistenced
  nvidia-settings
  nvidia-xconfig
).each do |p|
  yum_version_lock p do
    version version_lock['nvidia-driver']['version']
    release version_lock['nvidia-driver']['release']
    epoch 3
    notifies :touch, "file[#{makecache_file}]", :immediately
  end
end

yum_version_lock 'cuda-drivers' do
  version version_lock['cuda-drivers']['version']
  release version_lock['cuda-drivers']['release']
  notifies :touch, "file[#{makecache_file}]", :immediately
end

yum_version_lock 'nvidia-docker2' do
  version version_lock['nvidia-docker2']['version']
  release version_lock['nvidia-docker2']['release']
  notifies :touch, "file[#{makecache_file}]", :immediately
end

yum_version_lock 'cuda' do
  version version_lock['cuda']['version']
  release version_lock['cuda']['release']
  notifies :touch, "file[#{makecache_file}]", :immediately
end

log 'yum makecache cuda' do
  message 'yum makecache cuda'
  only_if { ::File.exist?(makecache_file) }
  notifies :makecache, 'yum_repository[cuda]', :immediately
end

file makecache_file do
  action :delete
end

package %w(nvidia-driver-latest-dkms cuda-drivers nvidia-docker2)
