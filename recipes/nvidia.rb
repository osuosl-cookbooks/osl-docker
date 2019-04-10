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

node.default['osl-docker']['daemon'] = {
  runtimes: {
    nvidia: {
      path: 'nvidia-container-runtime',
      runtimeArgs: [],
    },
  },
}

include_recipe 'yum-epel'
include_recipe 'yum-nvidia'
include_recipe 'build-essential'
include_recipe 'osl-docker'
include_recipe 'yum-plugin-versionlock'

%w(
  dkms-nvidia
  nvidia-driver
  nvidia-driver-cuda-libs
  nvidia-driver-libs
).each do |p|
  yum_version_lock p do
    version node['osl-docker']['nvidia']['driver_version']
    release node['osl-docker']['nvidia']['driver_release']
    epoch 3
  end
end

yum_version_lock 'nvidia-docker2' do
  version node['osl-docker']['nvidia']['docker_version']
  release node['osl-docker']['nvidia']['docker_release']
end

package 'nvidia-driver' do
  version "#{node['osl-docker']['nvidia']['driver_version']}-#{node['osl-docker']['nvidia']['driver_release']}"
end

package 'nvidia-docker2' do
  version "#{node['osl-docker']['nvidia']['docker_version']}-#{node['osl-docker']['nvidia']['docker_release']}"
end
