case node['platform_family']
when 'rhel'
  default['osl-docker']['package']['version'] = '18.06.1.ce'
  default['osl-docker']['package_release'] = '3.el7'
  default['osl-docker']['package']['package_version'] =
    "#{default['osl-docker']['package']['version']}-#{default['osl-docker']['package_release']}"
  default['osl-docker']['package']['package_name'] = 'docker-ce'
when 'debian'
  default['osl-docker']['package']['package_name'] = 'docker-ce'
  default['osl-docker']['package']['version'] = '18.06.1'
end
case node['kernel']['machine']
when 's390x'
  default['osl-docker']['tarball']['version'] = '18.06.1'
  default['osl-docker']['tarball']['checksum'] = '4042fc5a00baf9ceb3724b8f1a285bbdda714b0360b4a406fd316ecc6142dee3'
  default['osl-docker']['tarball']['source'] =
    'https://download.docker.com/linux/static/stable/s390x/docker-' \
    "#{default['osl-docker']['tarball']['version']}-ce.tgz"
when 'ppc64le'
  default['osl-docker']['tarball']['version'] = '18.06.1'
  default['osl-docker']['tarball']['checksum'] = '479083ac0b2bae839782ea53870809b8590f440db5f0bdf1294eac95e1a2ec3b'
  default['osl-docker']['tarball']['source'] =
    'https://download.docker.com/linux/static/stable/ppc64le/docker-' \
    "#{default['osl-docker']['tarball']['version']}-ce.tgz"
else
  default['osl-docker']['tarball'] = {}
end
default['osl-docker']['service'] = {}
default['osl-docker']['prune']['volume_filter'] = []
default['osl-docker']['tls'] = false
default['osl-docker']['host'] = node['osl-docker']['tls'] ? 'tcp://127.0.0.1:2376' : nil
default['osl-docker']['data_bag'] = 'docker'
