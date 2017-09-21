case node['platform_family']
when 'rhel'
  default['osl-docker']['package']['version'] = '17.06.1.ce'
  default['osl-docker']['package_release'] = node['kernel']['machine'] == 'ppc64le' ? '2.el7.centos' : '1.el7.centos'
  default['osl-docker']['package']['package_version'] =
    "#{default['osl-docker']['package']['version']}-#{default['osl-docker']['package_release']}"
  default['osl-docker']['package']['package_name'] = 'docker-ce'
when 'debian'
  default['osl-docker']['package']['package_name'] = 'docker-engine'
  default['osl-docker']['package']['version'] = '17.05.0'
end
default['osl-docker']['service'] = {}
