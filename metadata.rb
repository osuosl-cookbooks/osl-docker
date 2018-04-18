name             'osl-docker'
maintainer       'Oregon State University'
maintainer_email 'chef@osuosl.org'
license          'apachev2'
issues_url       'https://github.com/osuosl-cookbooks/osl-docker/issues'
source_url       'https://github.com/osuosl-cookbooks/osl-docker'
description      'Installs/Configures osl-docker'
long_description 'Installs/Configures osl-docker'
version          '1.7.2'

depends          'apt', '< 7.0.0'
depends          'certificate'
depends          'docker', '~> 2.15.0'
depends          'firewall', '>= 4.4.4'
depends          'systemd', '< 3.0.0'
depends          'magic_shell'
depends          'yum-docker'
depends          'yum-plugin-versionlock'

supports         'centos', '~> 7.0'
supports         'debian', '~> 8.0'
supports         'debian', '~> 9.0'
