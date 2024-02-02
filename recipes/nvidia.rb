#
# Cookbook:: osl-docker
# Recipe:: nvidia
#
# Copyright:: 2019-2024, Oregon State University
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
return unless platform_family?('rhel')

node.default['osl-docker']['daemon']['runtimes'] = {
  nvidia: {
    path: 'nvidia-container-runtime',
    runtimeArgs: [],
  },
}

osl_nvidia_driver 'latest'

yum_repository 'libnvidia-container' do
  baseurl 'https://nvidia.github.io/libnvidia-container/stable/centos$releasever/$basearch'
  gpgkey 'https://nvidia.github.io/libnvidia-container/gpgkey'
end

include_recipe 'osl-docker'

package 'nvidia-docker2' do
  notifies :create, 'template[/etc/docker/daemon.json]', :immediately
end

selinux_module 'nvidia_docker' do
  content <<~EOM
    module nvidia_docker 1.0;

    require {
            type xserver_t;
            type container_runtime_exec_t;
            class file entrypoint;
    }

    #============= xserver_t ==============
    allow xserver_t container_runtime_exec_t:file entrypoint;
  EOM
end
