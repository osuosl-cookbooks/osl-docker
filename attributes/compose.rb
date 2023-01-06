default['osl-docker']['compose']['version'] = '2.15'
default['osl-docker']['compose']['filename'] = "docker-compose-Linux-#{node['kernel']['machine']}"
case node['kernel']['machine']
when 'x86_64'
  default['osl-docker']['compose']['checksum'] = 'ba481d45be2b137a2a185abd05f61d6d7766dbedfa038f16e4705760767a206e'
  default['osl-docker']['compose']['url_base'] = 'https://github.com/docker/compose/releases/download'
when 'ppc64le'
  default['osl-docker']['compose']['checksum'] = '4458de249ca5f776738e44a6af2f869c1186b2d018dd15705045aa01a45e50c5'
  default['osl-docker']['compose']['url_base'] = 'http://ftp.osuosl.org/pub/osl/openpower/docker-compose'
end
