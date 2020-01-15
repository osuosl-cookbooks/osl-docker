name             'osl-docker'
maintainer       'Oregon State University'
maintainer_email 'chef@osuosl.org'
license          'Apache-2.0'
chef_version     '>= 14.0'
issues_url       'https://github.com/osuosl-cookbooks/osl-docker/issues'
source_url       'https://github.com/osuosl-cookbooks/osl-docker'
description      'Installs/Configures osl-docker'
long_description 'Installs/Configures osl-docker'
version          '2.8.0'

depends          'apt'
depends          'certificate'
depends          'docker', '~> 4.9.2'
depends          'firewall', '>= 4.4.4'
depends          'magic_shell'
depends          'yum-epel'
depends          'yum-nvidia'
depends          'yum-plugin-versionlock'

supports         'centos', '~> 8.0'
supports         'centos', '~> 7.0'
supports         'debian', '~> 9.0'
supports         'debian', '~> 10.0'
