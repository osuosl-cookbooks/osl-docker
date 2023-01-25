name             'osl-docker'
maintainer       'Oregon State University'
maintainer_email 'chef@osuosl.org'
license          'Apache-2.0'
chef_version     '>= 16.0'
issues_url       'https://github.com/osuosl-cookbooks/osl-docker/issues'
source_url       'https://github.com/osuosl-cookbooks/osl-docker'
description      'Installs/Configures osl-docker'
version          '4.7.0'

depends          'apt'
depends          'certificate'
depends          'docker', '~> 7.7.1'
depends          'osl-firewall'
depends          'osl-gpu'
depends          'osl-resources'
depends          'osl-selinux'
depends          'yum-epel'
depends          'yum-plugin-versionlock', '>= 0.4.0'

supports         'centos', '~> 7.0'
supports         'centos_stream', '~> 8.0'
supports         'debian', '~> 11.0'
