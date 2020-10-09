source 'https://supermarket.chef.io'

solver :ruby, :required

cookbook 'base', git: 'git@github.com:osuosl-cookbooks/base'
cookbook 'docker_test', path: 'test/cookbooks/docker_test'
cookbook 'firewall', git: 'git@github.com:osuosl-cookbooks/firewall'

# TODO: Remove after upstream has merged / released fix
cookbook 'yum-plugin-versionlock', github: 'detjensrobert/chef-yum-plugin-versionlock', branch: 'c7-regex-fix'

metadata
