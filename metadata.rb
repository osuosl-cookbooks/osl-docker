name             'osl-docker'
maintainer       'Oregon State University'
maintainer_email 'chef@osuosl.org'
license          'apachev2'
issues_url       'https://github.com/osuosl-cookbooks/osl-docker/issues'
source_url       'https://github.com/osuosl-cookbooks/osl-docker'
description      'Installs/Configures osl-docker'
long_description 'Installs/Configures osl-docker'
version          '0.1.0'

depends          'apt'
depends          'apt-docker'
depends          'docker', '~> 2.15.0'
depends          'yum-docker'
depends          'yum-plugin-versionlock'

supports         'centos', '~> 7.0'
supports         'debian', '~> 8.0'
