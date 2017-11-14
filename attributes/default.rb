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
default['osl-docker']['service'] = {}
