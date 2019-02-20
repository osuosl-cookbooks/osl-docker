case node['platform_family']
when 'rhel'
  default['osl-docker']['package']['version'] = '18.06.2.ce'
  default['osl-docker']['package_release'] = '3.el7'
  default['osl-docker']['package']['package_version'] =
    "#{default['osl-docker']['package']['version']}-#{default['osl-docker']['package_release']}"
  default['osl-docker']['package']['package_name'] = 'docker-ce'
when 'debian'
  default['osl-docker']['package']['package_name'] = 'docker-ce'
  default['osl-docker']['package']['version'] = '18.06.2'
end
case node['kernel']['machine']
when 's390x'
  default['osl-docker']['tarball']['version'] = '18.06.2'
  default['osl-docker']['tarball']['checksum'] = 'a061c590785bec5010273eb7592968a65046bb21063e2a387cd8b74d13c6d275'
  default['osl-docker']['tarball']['source'] =
    'https://download.docker.com/linux/static/stable/s390x/docker-' \
    "#{default['osl-docker']['tarball']['version']}-ce.tgz"
when 'ppc64le'
  default['osl-docker']['tarball']['version'] = '18.06.2'
  default['osl-docker']['tarball']['checksum'] = '9be128dc0da806dca4212da66cb7691f24771a5fd357b30336e4b858263432b3'
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
