osl-docker CHANGELOG
====================
This file is used to list changes made in each version of the
osl-docker cookbook.

2.12.0 (2021-03-17)
-------------------
- Idempotency fixes

2.11.0 (2021-01-26)
-------------------
- Bump to docker-7.6.1 cookbook

2.10.2 (2021-01-26)
-------------------
- Cookstyle fixes

2.10.1 (2020-11-20)
-------------------
- Enable log rotation for containers

2.10.0 (2020-06-24)
------------------
- Chef 15 compatibility fixes

2.9.0 (2020-01-21)
------------------
- Adding Support for Debian 10 and fixing Docker packages

2.8.3 (2020-03-05)
------------------
- Update nvidia driver to 440.33.01 and CUDA to 10.2

2.8.2 (2020-02-20)
------------------
- Remove restarting docker service on package upgrades

2.8.1 (2020-01-08)
------------------
- Include firewall::docker in default recipe

2.8.0 (2020-01-03)
------------------
- CentOS 8 support

2.7.0 (2019-12-22)
------------------
- Chef 14 post-migration fixes

2.6.3 (2019-11-25)
------------------
- Exclude/Version lock additional nvidia packages

2.6.2 (2019-11-12)
------------------
- Update to nvidia-driver-418.87.01

2.6.1 (2019-09-26)
------------------
- Add firewall_prometheus resource for docker_exporter

2.6.0 (2019-09-05)
------------------
- Chef 14 compatability fixes

2.5.1 (2019-08-16)
------------------
- Update nvidia-driver to 418.87.00 and fix package name

2.5.0 (2019-07-20)
------------------
- Remove refs to Debian Jessie

2.4.1 (2019-05-09)
------------------
- Enable builtin prometheus metrics in docker

2.4.0 (2019-05-06)
------------------
- Add support for nvidia-docker

2.3.1 (2019-04-16)
------------------
- Add client recipe

2.3.0 (2019-04-15)
------------------
- Update to docker-18.09.2 and switch to using rpms for ppc64le/s390x

2.2.2 (2019-02-20)
------------------
- Update to docker-18.06.2

2.2.1 (2018-09-28)
------------------
- Tell docker_service not to try an install_method

2.2.0 (2018-09-27)
------------------
- Update to docker-18.06.1

2.1.0 (2018-09-25)
------------------
- Update to latest upstream docker cookbook

2.0.0 (2018-07-17)
------------------
- Chef 13 compatibility fixes

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

