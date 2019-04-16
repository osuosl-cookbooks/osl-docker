name             'osl-docker'
maintainer       'Oregon State University'
maintainer_email 'chef@osuosl.org'
license          'Apache-2.0'
chef_version     '>= 12.18' if respond_to?(:chef_version)
issues_url       'https://github.com/osuosl-cookbooks/osl-docker/issues'
source_url       'https://github.com/osuosl-cookbooks/osl-docker'
description      'Installs/Configures osl-docker'
long_description 'Installs/Configures osl-docker'
version          '2.3.1'

depends          'apt'
depends          'certificate'
depends          'docker', '~> 4.9.2'
depends          'firewall', '>= 4.4.4'
depends          'magic_shell'
depends          'yum-plugin-versionlock'

supports         'centos', '~> 7.0'
supports         'debian', '~> 8.0'
supports         'debian', '~> 9.0'
