default['osl-docker']['compose']['version'] = '1.18.0'
default['osl-docker']['compose']['filename'] = "docker-compose-Linux-#{node['kernel']['machine']}"
case node['kernel']['machine']
when 'x86_64'
  default['osl-docker']['compose']['checksum'] = 'b2f2c3834107f526b1d9cc8d8e0bdd132c6f1495b036a32cbc61b5288d2e2a01'
  default['osl-docker']['compose']['url_base'] = 'https://github.com/docker/compose/releases/download'
when 'ppc64le'
  default['osl-docker']['compose']['checksum'] = '4458de249ca5f776738e44a6af2f869c1186b2d018dd15705045aa01a45e50c5'
  default['osl-docker']['compose']['url_base'] = 'http://ftp.osuosl.org/pub/osl/openpower/docker-compose'
end
