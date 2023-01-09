default['osl-docker']['compose']['version'] = '2.15.0'
default['osl-docker']['compose']['filename'] = "docker-compose-linux-#{node['kernel']['machine']}"
case node['kernel']['machine']
when 'x86_64'
  default['osl-docker']['compose']['checksum'] = 'ba481d45be2b137a2a185abd05f61d6d7766dbedfa038f16e4705760767a206e'
  default['osl-docker']['compose']['url_base'] = 'https://github.com/docker/compose/releases/download'
when 'aarch64'
  default['osl-docker']['compose']['checksum'] = '14d31297794868520cb2e61b543bb1c821aaa484af22b397904314ae8227f6a2'
  default['osl-docker']['compose']['url_base'] = 'https://github.com/docker/compose/releases/download'
when 'ppc64le'
  default['osl-docker']['compose']['checksum'] = '2b57f69c438fadaa88dc383d8df8b98955a2ab9262c7ca2524102c8199c8efb4'
  default['osl-docker']['compose']['url_base'] = 'http://ftp.osuosl.org/pub/osl/openpower/docker-compose'
end
