osl-docker Cookbook
===================

OSL wrapper cookbook using
[docker](https://supermarket.chef.io/cookbooks/docker) as a base. It installs
the docker package from Docker Inc. and starts the docker service.

Requirements
------------

- Chef 12.18.x or higher

Attributes
----------

- ``node['osl-docker']['package']`` -- Key/value hash which directly relates to
  the ``docker_installation_package`` resource.
- ``node['osl-docker']['service'] `` -- Key/value hash which directly relates to
  the ``docker_service``.

For example, if you wish to set the package version you could do the following:

``` ruby
node['osl-docker']['package']['version'] = '1.13.1'
```

If you wish to have have docker to listen on TCP instead of a socket, you can do
the following:

``` ruby
node['osl-docker']['service']['host'] = 'tcp://0.0.0.0:2375'
```

Usage
-----
#### osl-docker::default

Installs Docker from Docker Inc's repo and starts the docker service

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `username/add_component_x`)
3. Write tests for your change
4. Write your change
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
- Author:: Oregon State University <chef@osuosl.org>

```text
Copyright:: 2017, Oregon State University

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
