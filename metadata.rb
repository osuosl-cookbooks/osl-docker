name             'osl-docker'
maintainer       'Oregon State University'
maintainer_email 'chef@osuosl.org'
license          'Apache-2.0'
chef_version     '>= 16.0'
issues_url       'https://github.com/osuosl-cookbooks/osl-docker/issues'
source_url       'https://github.com/osuosl-cookbooks/osl-docker'
description      'Installs/Configures osl-docker'
version          '4.11.1'

depends          'apt'
depends          'certificate'
depends          'cron'
depends          'docker', '~> 11.1.0'
depends          'osl-firewall'
depends          'osl-gpu'
depends          'osl-resources'
depends          'osl-selinux'

supports         'almalinux', '~> 8.0'
supports         'centos', '~> 7.0'
supports         'debian', '~> 11.0'
supports         'debian', '~> 12.0'
