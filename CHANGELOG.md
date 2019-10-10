# Changelog

## [1.2.0] - 2019-10-10

### Added

- Add Multirepo / rm jenkins library and jenkins shared build library as globals lib into jenkins ([#146](https://github.com/opendevstack/ods-core/issues/146))
- Add support for SonarQube scanning to Golang quickstarter ([#190](https://github.com/opendevstack/ods-core/issues/190))
- Feature/platform jenkins mro sharedlib & build shared lib configuration ([#148](https://github.com/opendevstack/ods-core/issues/148))
- Webhook Proxy: Use Go template to render pipeline config ([#133](https://github.com/opendevstack/ods-core/issues/133))
- Jenkins webhook proxy should create pipeline based on HTTP/ params ([#80](https://github.com/opendevstack/ods-core/issues/80))

### Changed

- Update Tailor in jenkins-slave-base to the latest version ([#193](https://github.com/opendevstack/ods-core/issues/193))
- Add mro / rm jenkins library as global lib into jenkins ([#146](https://github.com/opendevstack/ods-core/issues/146))
- Remove project param from webhook proxy ([#162](https://github.com/opendevstack/ods-core/issues/162))
- Update Jenkins plugin credentials-binding to 1.18 ([#141](https://github.com/opendevstack/ods-core/issues/141))
- Update OpenResty version ([#149](https://github.com/opendevstack/ods-core/issues/149))
- Sonarqube image should support alternate download of Developer edition for commercial use ([#121](https://github.com/opendevstack/ods-core/issues/121))

### Fixed

- Prov App cannot be build through webhook proxy anymore ([#188](https://github.com/opendevstack/ods-core/issues/188))
- Webhook proxy /build does not work in case repository has enabled bb webhook proxy ([#174](https://github.com/opendevstack/ods-core/issues/174))
- Jenkins Master not able to access Repos on self-signed Bitbucket instances ([#167](https://github.com/opendevstack/ods-core/issues/167))
- Webhook Proxy Bad Request handling ([#154](https://github.com/opendevstack/ods-core/issues/154))


## [1.1.0] - 2019-05-28

### Added

- `GIT LFS` enabled and installed on the `jenkins-slave-base` ([#76](https://github.com/opendevstack/ods-core/issues/76))
- `travis build` addition for webhook proxy ([#64](https://github.com/opendevstack/ods-core/issues/64))
- Scripted Nexus setup ([#42](https://github.com/opendevstack/ods-core/issues/42))
- Webhook Proxy: Allow to protect all branches or branches with certain prefix ([#55](https://github.com/opendevstack/ods-core/issues/55))
- Add tailor CLI to Jenkins base slave ([#62](https://github.com/opendevstack/ods-core/issues/62))
- Add Jenkins slave `nodejs10-angular`

### Changed

- `jenkins-slave-base`'s FROM is configurable now - to ensure pickup of the right OC delivered version  ([#88](https://github.com/opendevstack/ods-core/issues/88))
- [`shared-images/nginx-authproxy-crowd`](shared-images/nginx-authproxy-crowd) is based on the `openresty shared image` rather than a from scratch debian build
- Oracle Java role not required anymore ([#40](https://github.com/opendevstack/ods-core/issues/40))

### Fixed

- SQ build fails: mkdir /opt mkdir: can't create directory '/opt': File exists ([#81](https://github.com/opendevstack/ods-core/issues/76))
- OC pipelines not in sync with Jenkins: custom fix openshift Jenkins plugin copied to plugins until it is not officially released/provided ([#86](https://github.com/opendevstack/ods-core/issues/86))
- Copy files in `init.groovy.d` during boot from image to volume ([#97](https://github.com/opendevstack/ods-core/issues/97))
- Prevents builds from being orphaned ([#72](https://github.com/opendevstack/ods-core/issues/72))

## [1.0.2] - 2019-04-02

### Fixed

- SQ build fails: mkdir /opt mkdir: can't create directory '/opt': File exists ([#81](https://github.com/opendevstack/ods-core/issues/76))

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
