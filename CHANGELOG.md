# Changelog

## [Unreleased]

## [1.0.2] - 2019-04-02

### Fixed

- SonarQube image build failed due to erronous `mkdir` call ([#81](https://github.com/opendevstack/ods-core/issues/81))
- nginx-authproxy-crowd image build failed due to outdated Nginx dependency ([#84](https://github.com/opendevstack/ods-core/issues/84))

## [1.0.1] - 2019-01-25

### Fixed
- Wrong ticket number extracted if branch contains multiple numbers ([#71](https://github.com/opendevstack/ods-core/pull/71))


## [1.0.0] - 2018-12-03

### Added

- `jenkins-slave-base` can be built on either centos7 or rhel7 configurable via buildconfig (#5)
- Nexus also contains a backup pvc (for the backup of db task)
- Jenkins webhook proxy to proxy webhooks and manage pipelines (#45)

### Changed
- `jenkins-slave-base` now grabs root ca to provide to all other slaves (including rundeck's OC container) (#18, #20)
- Upgrade of Sonarqube to latest 7.3 (#32)
- Make storage class and provisioner configurable (#36)

### Fixed
- Secrets for authproxy container (in shared images) was missing (#6)
- Email sendout (#45)
- Set Jenkins URL during initialization (#52)


## [0.1.0] - 2018-07-27

Initial release.
