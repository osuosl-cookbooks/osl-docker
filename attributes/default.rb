case node['platform_family']
when 'rhel'
  default['osl-docker']['package']['version'] = '18.09.2'
  default['osl-docker']['package_release'] = '3.el7'
  default['osl-docker']['package']['package_version'] =
    "#{default['osl-docker']['package']['version']}-#{default['osl-docker']['package_release']}"
  default['osl-docker']['package']['package_name'] = 'docker-ce'
  default['osl-docker']['package_cli_name'] = 'docker-ce-cli'
  default['osl-docker']['package']['setup_docker_repo'] = !(node['platform_version'].to_i >= 8)
when 'debian'
  default['osl-docker']['package']['setup_docker_repo'] = true
  default['osl-docker']['package']['package_name'] = 'docker-ce'
  default['osl-docker']['package_cli_name'] = 'docker-ce-cli'
  default['osl-docker']['package']['version'] = '5:18.09.2'
  default['osl-docker']['package']['package_version'] = "5:18.09.2~3-0~debian-#{node['lsb']['codename']}"
end
case node['kernel']['machine']
when 'ppc64le', 's390x'
  default['osl-docker']['package']['setup_docker_repo'] = false
end
default['osl-docker']['service'] = {}
default['osl-docker']['daemon'] =
  {
    'metrics-addr' => '0.0.0.0:9323',
    'experimental' => true,
  }
default['osl-docker']['prune']['volume_filter'] = []
default['osl-docker']['tls'] = false
default['osl-docker']['host'] = node['osl-docker']['tls'] ? 'tcp://127.0.0.1:2376' : ''
default['osl-docker']['data_bag'] = 'docker'
default['osl-docker']['client_only'] = false
