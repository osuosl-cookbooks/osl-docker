#
# Cookbook:: osl-docker
# Recipe:: ibmz_ci
#
# Copyright:: 2018, Oregon State University
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
node.default['firewall']['docker']['expose_ports'] = true
node.default['osl-docker']['tls'] = true
node.override['osl-docker']['service'] = { host: 'tcp://0.0.0.0:2376' }

include_recipe 'osl-docker::default'
include_recipe 'firewall::docker'
