case node['platform_family']
when 'rhel'
  default['osl-docker']['package']['version'] = '17.09.0.ce'
  default['osl-docker']['package_release'] = '1.el7.centos'
  default['osl-docker']['package']['package_version'] =
    "#{default['osl-docker']['package']['version']}-#{default['osl-docker']['package_release']}"
  default['osl-docker']['package']['package_name'] = 'docker-ce'
when 'debian'
  default['osl-docker']['package']['package_name'] = 'docker-ce'
  default['osl-docker']['package']['version'] = '17.09.0'
end
case node['kernel']['machine']
when 's390x'
  default['osl-docker']['tarball']['version'] = '17.09.0'
  default['osl-docker']['tarball']['checksum'] = '6037fbd5e22d68fde6ddf73a28c10b5c37d916b02b6848a3cb62344ced137365'
  default['osl-docker']['tarball']['source'] =
    'https://download.docker.com/linux/static/stable/s390x/docker-' \
    "#{default['osl-docker']['tarball']['version']}-ce.tgz"
else
  default['osl-docker']['tarball'] = {}
end
default['osl-docker']['service'] = {}
default['osl-docker']['tls'] = false
default['osl-docker']['data_bag'] = 'docker'
