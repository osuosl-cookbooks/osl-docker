osl-docker CHANGELOG
====================
This file is used to list changes made in each version of the
osl-docker cookbook.

1.7.5 (2018-05-16)
------------------
- volume fixes for powerci/ibmz

1.7.4 (2018-05-15)
------------------
- Remove DOCKER_HOST from cron jobs

1.7.3 (2018-04-20)
------------------
- Add ccache volume on POWER/IBM-Z CI

1.7.2 (2018-04-18)
------------------
- Enable docker socket by default

1.7.1 (2018-04-10)
------------------
- Lock apt cookbook to < 7.0.0

1.7.0 (2018-03-29)
------------------
- IBM-Z CI docker recipe

1.6.0 (2018-03-23)
------------------
- Optional TLS support for docker daemons

1.5.0 (2018-02-19)
------------------
- Install docker-compose binary

1.4.3 (2017-12-12)
------------------
- Allow access to docker from powerci-jenkins host

1.4.2 (2017-12-09)
------------------
- s390x support via tarball installation method

1.4.1 (2017-11-28)
------------------
- Prune docker volumes and images via cronjob

1.4.0 (2017-11-27)
------------------
- Bump to docker-ce-17.09.0

1.3.0 (2017-11-13)
------------------
- Add workstation which deprecates workstation::docker

1.2.3 (2017-10-13)
------------------
- Remove apt-docker cookbook and add repository manually

1.2.2 (2017-10-05)
------------------
- Expose the docker container ports to the jenkins server on powerci

1.2.1 (2017-09-22)
------------------
- Add firewall rules for docker on powerci

1.2.0 (2017-09-21)
------------------
- Add ppc64le support / Update to latest Docker-ce version

1.1.0 (2017-08-24)
------------------
- Added powerci recipe and tests.

1.0.1 (2017-08-18)
------------------
- Set package_name to docker-engine instead of docker-ce

1.0.0 (2017-06-26)
------------------
- Initial default recipe

0.1.0
-----
- Initial release of osl-docker

