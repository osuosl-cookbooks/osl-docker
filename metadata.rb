name             'osl-docker'
maintainer       'Oregon State University'
maintainer_email 'chef@osuosl.org'
license          'Apache-2.0'
chef_version     '>= 16.0'
issues_url       'https://github.com/osuosl-cookbooks/osl-docker/issues'
source_url       'https://github.com/osuosl-cookbooks/osl-docker'
description      'Installs/Configures osl-docker'
version          '3.0.0'

depends          'apt'
depends          'certificate'
depends          'base'
depends          'docker', '~> 7.6.1'
depends          'osl-firewall'
depends          'yum-epel'
depends          'yum-nvidia'
depends          'yum-plugin-versionlock', '>= 0.4.0'

supports         'centos', '~> 8.0'
supports         'centos', '~> 7.0'
supports         'debian', '~> 10.0'
