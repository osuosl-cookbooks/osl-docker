case node['platform_family']
when 'rhel'
  default['osl-docker']['package']['version'] = '18.09.2'
  default['osl-docker']['package_release'] = '3.el7'
  default['osl-docker']['package']['package_version'] =
    "#{default['osl-docker']['package']['version']}-#{default['osl-docker']['package_release']}"
  default['osl-docker']['package']['package_name'] = 'docker-ce'
  default['osl-docker']['package_cli_name'] = 'docker-ce-cli'
when 'debian'
  default['osl-docker']['package']['package_name'] = 'docker-ce'
  default['osl-docker']['package_cli_name'] = 'docker-ce-cli'
  case node['platform_version'].to_i
  when 8
    # Debian 8 has no builds for 18.09.2 :(
    default['osl-docker']['package']['version'] = '18.06.3'
  else
    default['osl-docker']['package']['version'] = '5:18.09.2'
    default['osl-docker']['package']['package_version'] = '5:18.09.2~3-0~debian-stretch'
  end
end
case node['kernel']['machine']
when 'ppc64le', 's390x'
  default['osl-docker']['package']['setup_docker_repo'] = false
end
default['osl-docker']['service'] = {}
default['osl-docker']['daemon'] = {}
default['osl-docker']['prune']['volume_filter'] = []
default['osl-docker']['tls'] = false
default['osl-docker']['host'] = node['osl-docker']['tls'] ? 'tcp://127.0.0.1:2376' : nil
default['osl-docker']['data_bag'] = 'docker'
default['osl-docker']['client_only'] = false
default['osl-docker']['nvidia']['driver_version'] = '410.104'
default['osl-docker']['nvidia']['driver_release'] = '1.el7'
default['osl-docker']['nvidia']['docker_version'] = '2.0.3'
default['osl-docker']['nvidia']['docker_release'] = '1.docker18.09.2.ce'
