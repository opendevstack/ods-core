# Changelog

## Unreleased

### Added

- Add SCM Git plugin to SonarQube ([#448](https://github.com/opendevstack/ods-core/pull/448))

### Changed

- Increase memory available to Jenkins ([#437](https://github.com/opendevstack/ods-core/pull/437), [#442](https://github.com/opendevstack/ods-core/pull/442) and [e5448c8](https://github.com/opendevstack/ods-core/commit/e5448c87a890f8cbc4bec02496e33a2864e31205))
- Use official `openshift-sync` plugin (1.0.34) instead of patched one ([#439](https://github.com/opendevstack/ods-core/pull/439) and [81e1ed1](https://github.com/opendevstack/ods-core/commit/81e1ed1915874c9f904396b9b1db2722e823457e))
- Update Tailor to 0.13.1 ([#436](https://github.com/opendevstack/ods-core/pull/436))
- Update CNES report tool to 3.1.0 ([#433](https://github.com/opendevstack/ods-core/pull/433))
- Update SonarQube Java plugin to 6.2.0 ([#428](https://github.com/opendevstack/ods-core/pull/428))

### Fixed

- Webhook Proxy: Ensure that pipeline name is not more than 63 characters ([#406](https://github.com/opendevstack/ods-core/pull/406))
- Use HTTPS in curl command in jenkins-slave-base ([#388](https://github.com/opendevstack/ods-core/pull/388))
- Add missing `PROV_APP_CROWD_URI` param to sample config ([#385](https://github.com/opendevstack/ods-core/pull/385))
- Add missing `SONAR_ADMIN_PASSWORD_B64` param sample config ([#383](https://github.com/opendevstack/ods-core/pull/383))

## [2.0] - 2019-12-13

### Added
- Add skopeo into Jenkins slave to move images ([#253](https://github.com/opendevstack/ods-core/issues/253))
- Single Tailor comparison script ([#207](https://github.com/opendevstack/ods-core/issues/207))
- Allow to specify project in build endpoint of webhook proxy ([#229](https://github.com/opendevstack/ods-core/issues/229))
- Make ODS image tag and Git Ref configurable ([#225](https://github.com/opendevstack/ods-core/issues/225))
- Grant image-puller rights on project-cd for project envs service accounts ([#293](https://github.com/opendevstack/ods-core/issues/293))
- Backup script for SonarQube ([#265](https://github.com/opendevstack/ods-core/issues/265))

### Changed
- Update Nexus to 3.19.1 ([#263](https://github.com/opendevstack/ods-core/issues/263))
- Update SonarQube to 7.9 and plugins to latest ([#249](https://github.com/opendevstack/ods-core/issues/249))
- Centralise configuration ([#219](https://github.com/opendevstack/ods-core/issues/219))
- Tag Jenkins images with ODS version ([#211](https://github.com/opendevstack/ods-core/issues/211))
- Move jenkins templates to ods-core ([#323](https://github.com/opendevstack/ods-core/issues/323))
- Replace Rundeck secure route checking with OpenShift job / Jenkins job ([#324](https://github.com/opendevstack/ods-core/issues/324))
- Improve Jenkins Dockerfiles ([#312](https://github.com/opendevstack/ods-core/issues/312))
- Update Tailor to 0.11.0 ([#290](https://github.com/opendevstack/ods-core/issues/290))

### Fixed
- Export script test if remote branch exists before during checkout ([#300](https://github.com/opendevstack/ods-core/pull/300))
- Airflow quickstarter TLS verification can fail ([#222](https://github.com/opendevstack/ods-core/issues/222))
- Secure route check should also look for reencrypt termination type ([#325](https://github.com/opendevstack/ods-core/issues/325))
- Invalid APP_DNS doesn't stop build at given step ([#298](https://github.com/opendevstack/ods-core/issues/298))
- Build endpoint does not update env params ([#237](https://github.com/opendevstack/ods-core/issues/237))
- Components previously deleted reappear in cloned environment ([#318](https://github.com/opendevstack/ods-core/issues/318))

### Removed
- Removal of Crowd HTTP basic auth proxy related shared images ([#215](https://github.com/opendevstack/ods-core/issues/215))
- Removal of Airflow related shared images ([#289](https://github.com/opendevstack/ods-core/issues/289))

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
