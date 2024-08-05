default['osl-docker']['service'] = {}
default['osl-docker']['daemon'] =
  {
    'metrics-addr' => '0.0.0.0:9323',
    'experimental' => true,
    'ip6tables' => true,
    'log-opts' => {
      'max-size' => '100m',
      'max-file' => '10',
    },
  }
default['osl-docker']['prune']['volume_filter'] = []
default['osl-docker']['tls'] = false
default['osl-docker']['host'] = node['osl-docker']['tls'] ? 'tcp://127.0.0.1:2376' : nil
default['osl-docker']['data_bag'] = 'docker'
default['osl-docker']['client_only'] = false
default['osl-docker']['setup_repo'] = true
