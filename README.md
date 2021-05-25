osl-docker Cookbook
===================

OSL wrapper cookbook using [docker](https://supermarket.chef.io/cookbooks/docker) as a base. It installs the docker
package from Docker Inc. and starts the docker service.

Requirements
------------

- Chef 12.18.x or higher

Attributes
----------

- ``node['osl-docker']['package']`` -- Key/value hash which directly relates to the ``docker_installation_package``
  resource.
- ``node['osl-docker']['service'] `` -- Key/value hash which directly relates to the ``docker_service``.
- ``node['osl-docker']['tls']`` -- Boolean for enabling TLS for the docker service. Default: ``false``
- ``node['osl-docker']['data_bag']`` -- Name of the data bag to find the TLS certificates. Default: ``docker``

For example, if you wish to set the package version you could do the following:

``` ruby
node['osl-docker']['package']['version'] = '1.13.1'
```

If you wish to have have docker to listen on TCP instead of a socket, you can do the following:

``` ruby
node['osl-docker']['service']['host'] = 'tcp://0.0.0.0:2375'
```

TLS
---

If you wish to enable TLS for the docker daemon, you need to set the ``node['osl-docker']['tls']`` attribute to
``true`` and also create TWO data bag items using the FQDN of the host as part of the name (replacing periods with
dashes). One data bag item is for the server certificates and the other is for the client certificates. These all need
to be created from a certificate authority that we manage internally using easy-rsa.

For example, if we created certificates for foo.example.org, we would create a one data bag item named
``server-foo-example-org.json`` which includes the CA cert (as the ``chain_file``), cert and key for the server. Then
you also need to create a data bag item named ``client-foo-example-org.json`` which contains the client certs.  The CA
cert should be the same for this one as well.

Here's an example of what should be in the encrypted data bag item (without showing any certs).

Server data bag item:

``` json
{
  "cert": "<server cert>",
  "chain": "<CA cert>",
  "id": "server-foo-example-org",
  "key": "<server key>"
}
```

Client data bag item:

``` json
{
  "cert": "<client cert>",
  "chain": "<CA cert>",
  "id": "client-foo-example-org",
  "key": "<client key>"
}
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
