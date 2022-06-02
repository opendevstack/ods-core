# Changelog

## Unreleased

- Create Dockerfile.rhel7 and Dockerfile.centos7 with respectives plugins.rhel7.txt and plugins.centos7.txt definitions  ([1000](https://github.com/opendevstack/ods-core/issues/1000))
- Change FROM image of SonarQube to avoid build problems in the AdoptJDK11 ([994](https://github.com/opendevstack/ods-core/pull/994))
- Fix port from 3.x for SonarQube libressl issue - change to openssl ([#996](https://github.com/opendevstack/ods-core/issues/996))
- Fix mro and docgen tests adding ODS_BITBUCKET_PROJECT param ([#1014](https://github.com/opendevstack/ods-core/pull/1014))
- Configure buildbot to build 4.x branch ([1016](https://github.com/opendevstack/ods-core/pull/1016))
- Add 4.x build status badge to README ([1017](https://github.com/opendevstack/ods-core/pull/1017))
- Update plugins.rhel7.txt ([1023](https://github.com/opendevstack/ods-core/pull/1023))
- `make` is missing from Jenkins agent images in OpenShift 4 ([1025](https://github.com/opendevstack/ods-core/issues/1025))
- Update ods.service in order to startup the ods service correctly ([1042](https://github.com/opendevstack/ods-core/pull/1042))
- Add dependency to docker.service in ods systemd service definition ([1045](https://github.com/opendevstack/ods-core/pull/1045))
- Add support for ods-saas-service quickstarter ([#1033](https://github.com/opendevstack/ods-core/pull/1033))
- ODS AMI build failing due to broken helm diff package ([#1083](https://github.com/opendevstack/ods-core/pull/1083))
- ODS AMI CI build fails with Prov APP (ocp check precondition) ([#1117](https://github.com/opendevstack/ods-core/pull/1117))
- Add plugins necessary to upgrade to 4.9 base image in the list of managed plugins ([#1121](https://github.com/opendevstack/ods-core/pull/1121))
- Upgraded atlassian suite to 8.20.6 and added functionality to upgrade without reinstalling all the box.
- Upgrades needed by Github and Jenkins pipelines to work again. Includes some pipeline modifications to detect errors early.
- Upgrades atlassian suite ([#1138](https://github.com/opendevstack/ods-core/issues/1138)) 

### Added

- Extend provisioning app configuration to allow to enable single page client ([#1009](https://github.com/opendevstack/ods-core/pull/1009))
- Assign the owner as a label to the project ([#946](https://github.com/opendevstack/ods-core/pull/946))
- Install Aquasec scannercli on jenkins base image ([#976](https://github.com/opendevstack/ods-core/pull/976))
- Add changelog enforcer as GitHub Action to workflow ([#891](https://github.com/opendevstack/ods-core/issues/891))
- Narrow down system:authenticated permissions when creating new ODS project ([#942](https://github.com/opendevstack/ods-core/issues/942))
- Added SonarQube test for commercial editions ([#978](https://github.com/opendevstack/ods-core/pull/978))
- Added SonarQube apex plugin for enterprise and datacenter editions ([#977](https://github.com/opendevstack/ods-core/pull/977))
- Add pub key parameter to buildbot ([#956](https://github.com/opendevstack/ods-core/pull/956))
- Extends packer build to add a pub key as authorized key to odsbox ami image ([#953](https://github.com/opendevstack/ods-core/pull/953))
- Add script to generate the OpenVPN client profile for the ODS in a box
- Allow to configure database image for SonarQube ([#984](https://github.com/opendevstack/ods-core/pull/984))
- Updated test suite README.md with proxy and jq requirements
- Add configmaps for cluster creation and ods box dev environment ([#989](https://github.com/opendevstack/ods-core/pull/989))
- Add new plugin for Jenkins ([#999](https://github.com/opendevstack/ods-core/issues/999))
- Set sql-mode to ANSI_QUOTES in the creation of atlassian_mysql container to accept querys with double quotes in column and tables names ([#1072](https://github.com/opendevstack/ods-core/pull/1072))

### Changed

- ds-jupyter-notebook renamed to ds-jupyter-lab and upgrade to JupyterLab 3 ([#562](https://github.com/opendevstack/ods-quickstarters/issues/562))
- Updated Tailor to 1.3.4 ([#1090](https://github.com/opendevstack/ods-core/issues/1090))

### Fixed

- ODS AMI build failed due to an installation error of chrome package ([#1054](https://github.com/opendevstack/ods-core/pull/1054))
- ODS AMI build failed due to jira missing permissions on jira data folder ([#1005](https://github.com/opendevstack/ods-core/pull/1005))
- ODS AMI build failed due to bitbucket crashed container ([#1001](https://github.com/opendevstack/ods-core/pull/1001))
- Preserve clusterIPs of services ([#983](https://github.com/opendevstack/ods-core/pull/983))
- Use storageClassName instead of annotation ([#985](https://github.com/opendevstack/ods-core/pull/985))
- Tailor detects drift in cluster IP addresses in OCP 4.7+ ([#683](https://github.com/opendevstack/ods-jenkins-shared-library/issues/683))
- Jenkins plugins version for OCP 3 ([#1000](https://github.com/opendevstack/ods-core/issues/1000))
- fix openshift templates deprecation notice ([#639](https://github.com/opendevstack/ods-quickstarters/issues/639))
- Fix config check ([#1036](https://github.com/opendevstack/ods-core/pull/1036))
- Update jenkins plugins ([#1040](https://github.com/opendevstack/ods-core/pull/1040))
- Do not replace multiple occurences of project in component name ([#1078](https://github.com/opendevstack/ods-core/issues/1078))
- Jenkins Agent Base UBI8 fix new Centos repos ([#1093](https://github.com/opendevstack/ods-core/pull/1093))
- Update centos mirror ([#1098](https://github.com/opendevstack/ods-core/pull/1098))
- Point Aqua credential id to project-specific CD user ([#1125](https://github.com/opendevstack/ods-core/issues/1125))

### Removed

- ds-ml-service deprecated and moved to extra-quickstarters ([#568](https://github.com/opendevstack/ods-quickstarters/issues/568))

## [3.0] - 2020-08-11

### Added
- Publish ods images to Docker Hub ([#490](https://github.com/opendevstack/ods-core/issues/490))
- Add script to manage Bitbucket ODS project and repos ([#614](https://github.com/opendevstack/ods-core/pull/614))
- Support for http proxy for Nexus and Jenkins master ([#637](https://github.com/opendevstack/ods-core/issues/637))
- Add C# scanner plugin to Sonarqube ([#650](https://github.com/opendevstack/ods-core/issues/650))
- Add Groovy plugin ([#595](https://github.com/opendevstack/ods-core/pull/595))
- Configure Bitbucket "opendevstack" project name ([#347](https://github.com/opendevstack/ods-core/issues/347))
- Support "PR Opened" push event from Bitbucket ([#512](https://github.com/opendevstack/ods-core/issues/512))
- Check scripts with shellcheck ([#540](https://github.com/opendevstack/ods-core/pull/540))
- Add PHP plugin to Sonarqube ([#536](https://github.com/opendevstack/ods-core/issues/536))
- add doc gen service and new selectors ([#515](https://github.com/opendevstack/ods-core/pull/515))
- Add SonarQube readiness probe ([#495](https://github.com/opendevstack/ods-core/pull/495))
- Add AWS quickstarter into the Prov-app config map ([#970](https://github.com/opendevstack/ods-core/pull/970))

### Changed
- Updated start-and-follow-build script to wait for OpenShift build to complete sucessfully ([#939](https://github.com/opendevstack/ods-core/pull/939))
- Improve install documentation ([#730](https://github.com/opendevstack/ods-core/issues/730))
- Update proxy.groovy ([#691](https://github.com/opendevstack/ods-core/pull/691))
- Assign self-provisioner role to Jenkins serviceaccount ([#529](https://github.com/opendevstack/ods-core/pull/529))
- Read ODS_NAMESPACE from config ([#719](https://github.com/opendevstack/ods-core/pull/719))
- Bump Tailor to 1.2.0 ([#763](https://github.com/opendevstack/ods-core/pull/763))
- extend ods-core tests - to reflect a real installation qualification ([#646](https://github.com/opendevstack/ods-core/issues/646))
- always get tagged image - latest version ([#706](https://github.com/opendevstack/ods-core/pull/706))
- parameterize ProvApp cleanup of incomplete project config ([#699](https://github.com/opendevstack/ods-core/issues/699))
- update prov app configuration with properties basic auth and confluence adapter ([#696](https://github.com/opendevstack/ods-core/issues/696))
- ods-verify: parameterize bitbucket project and ocp one ([#677](https://github.com/opendevstack/ods-core/pull/677))
- Missing environment variables in env.sample file ([#664](https://github.com/opendevstack/ods-core/issues/664))
- set default spring profile in provision app explicity set 2 layers of configuration ([#656](https://github.com/opendevstack/ods-core/issues/656))
- run quickstarter tests after setup ([#644](https://github.com/opendevstack/ods-core/pull/644))
- Rename jenkins-slave-base to jenkins-agent-base ([#633](https://github.com/opendevstack/ods-core/issues/633))
- SQ token should be automatically added into ods-core.env and file committed into BB ([#624](https://github.com/opendevstack/ods-core/issues/624))
- Write updated SQ config values to ods-core.env ([#627](https://github.com/opendevstack/ods-core/pull/627))
- add original certificate importing for jenkins master, slave-base and sonarqube ([#611](https://github.com/opendevstack/ods-core/pull/611))
- Delete .kube directory before booting Jenkins ([#606](https://github.com/opendevstack/ods-core/pull/606))
- Configure URLs instead of hosts ([#259](https://github.com/opendevstack/ods-core/issues/259))
- Webhook proxy resource constraints ([#603](https://github.com/opendevstack/ods-core/pull/603))
- consistently set defaults for volume claims ([#589](https://github.com/opendevstack/ods-core/pull/589))
- Specify resource constraints for Nexus and SonarQube ([#596](https://github.com/opendevstack/ods-core/pull/596))
- create-projects: Exchange environment variable with proper command line arguments ([#333](https://github.com/opendevstack/ods-core/issues/333))
- Rename /and change labels of provision application ([#506](https://github.com/opendevstack/ods-core/issues/506))
- BuildConfig resources ([#571](https://github.com/opendevstack/ods-core/pull/571))
- Base ods-provision app & ods-doc-gen service on imagestreams rather than having only a DC ([#505](https://github.com/opendevstack/ods-core/issues/505))
- Rename Nexus OCP resources from nexus3 to nexus ([#509](https://github.com/opendevstack/ods-core/issues/509))
- adds missing property webhookproxy events and change namespace in Tailor file ([#553](https://github.com/opendevstack/ods-core/pull/553))
- Fetch shared lib from github per default instead of requiring "local" clone on bitbucket ([#518](https://github.com/opendevstack/ods-core/issues/518))
- Change default branch from production to master ([#523](https://github.com/opendevstack/ods-core/issues/523))
- Unify Jenkins image setup ([#544](https://github.com/opendevstack/ods-core/pull/544))
- Makefile should tag dockerhub images (scheduled) into respective image streams ([#545](https://github.com/opendevstack/ods-core/issues/545))
- Jenkins BuildConfig "from" inconsistent ([#482](https://github.com/opendevstack/ods-core/issues/482))
- Configure readable repos via ConfigMap ([#535](https://github.com/opendevstack/ods-core/pull/535))
- Avoid harcoding prov-cd namespace ([#531](https://github.com/opendevstack/ods-core/pull/531))
- Move opendevstack from current "global" CD OCP namespace to opendevstack/ods namespace ([#493](https://github.com/opendevstack/ods-core/issues/493))
- create-projects: Unkown path in Tailorfile ([#334](https://github.com/opendevstack/ods-core/issues/334))
- Use master branch of configuration ([#476](https://github.com/opendevstack/ods-core/issues/476))
- Update Nexus to 3.22.0 ([#460](https://github.com/opendevstack/ods-core/issues/460))
- Automate Nexus configuration ([#508](https://github.com/opendevstack/ods-core/pull/508))
- Update SonarQube to 8.2 ([#459](https://github.com/opendevstack/ods-core/issues/459))
- Automate SonarQube setup ([#488](https://github.com/opendevstack/ods-core/issues/488))
- Writable cache dir in Jenkins slave ([#496](https://github.com/opendevstack/ods-core/issues/496))
- Preserve immutable fields in Nexus/SonarQube config ([#453](https://github.com/opendevstack/ods-core/pull/453))
- Remove image trigger from Jenkins master instances / deployments ([#210](https://github.com/opendevstack/ods-core/issues/210)) ([#396](https://github.com/opendevstack/ods-core/issues/396))

### Fixed
- Log non-successful return code when triggering pipeline ([#694](https://github.com/opendevstack/ods-core/pull/694))
- Latest jenkins-master:v3.11 breaks ([#670](https://github.com/opendevstack/ods-core/issues/670))
- Fix provisioning app auth config in ods-core.env ([#704](https://github.com/opendevstack/ods-core/pull/704))
- ods-provision-app and others that pull opendevstackorg - do NOT refresh on change of latest ([#705](https://github.com/opendevstack/ods-core/issues/705))
- Webhook proxy does not update pipeline definition in case of repeated call with same name but different env / jenkinspipeline ([#710](https://github.com/opendevstack/ods-core/issues/710))
- setup repos syntax error ([#666](https://github.com/opendevstack/ods-core/issues/666))
- Makefile configure targets use host, not URL ([#678](https://github.com/opendevstack/ods-core/issues/678))
- /tests broken and on old version ([#636](https://github.com/opendevstack/ods-core/issues/636))
- amend DOCKER_REGISTRY setting in default config to use 'docker-registry.default.svc' ([#638](https://github.com/opendevstack/ods-core/issues/638))
- ods-setup - various edp in a box driven findings ([#625](https://github.com/opendevstack/ods-core/issues/625))
- failed to run script file: ods-jenkins-shared-library.groovy ([#316](https://github.com/opendevstack/ods-core/issues/316))
- fix bitbucketHost to bitbucketUrl ([#621](https://github.com/opendevstack/ods-core/pull/621))
- Jenkins Master does not specify CPU constraints ([#612](https://github.com/opendevstack/ods-core/issues/612))
- Jenkins becomes "unresponsive" and does not start new job runs ([#473](https://github.com/opendevstack/ods-core/issues/473))
- Fix "java.lang.UnsupportedOperationException" during init script ([#597](https://github.com/opendevstack/ods-core/pull/597))
- Sonarqube - updatecenter / marketplace does not use proxy ([#373](https://github.com/opendevstack/ods-core/issues/373))
- Nexus repo setup script missing in ods-core ([#423](https://github.com/opendevstack/ods-core/issues/423))
- ods-core/infrastructure-setup/ still contains rundeck setup ([#424](https://github.com/opendevstack/ods-core/issues/424))
- Not all params from configuration-sample are used anymore ([#376](https://github.com/opendevstack/ods-core/issues/376))
- Webhook Proxy does not run under jenkins serviceaccount ([#413](https://github.com/opendevstack/ods-core/issues/413))
- Jenkins runs out of memory and becomes unresponsive ([#412](https://github.com/opendevstack/ods-core/issues/412))
- CNES report plugin in base slave incompatible with ods-core SQ version ([#419](https://github.com/opendevstack/ods-core/issues/419))
- checkout-respositories.sh executes in sh instead of bash ([#397](https://github.com/opendevstack/ods-core/issues/397))
- webhook proxy - jenkins fails to fetch build in case branch name > 63chars ([#369](https://github.com/opendevstack/ods-core/issues/369))
- Download of sonar-scanner-cli fails ([#378](https://github.com/opendevstack/ods-core/issues/378))
- fix volume size and fix unresolved mirror errmsg on startup ([#639](https://github.com/opendevstack/ods-core/pull/639))
- Sonarqube 8.2 support - missing jacoco plugin ([#457](https://github.com/opendevstack/ods-core/issues/457))
- Use latest version (1.0.44) of openshift-sync plugin ([#461](https://github.com/opendevstack/ods-core/pull/461))
- Do not copy init.groovy.d files on initial boot ([#443](https://github.com/opendevstack/ods-core/issues/443))
- Restrict permissions of the default role ([#452](https://github.com/opendevstack/ods-core/issues/452))
- Better documentation, logging and env var handling ([#446](https://github.com/opendevstack/ods-core/pull/446))
- Move ODS config to Jenkins master ([#410](https://github.com/opendevstack/ods-core/pull/410))
- Ensure that pipeline name is not longer than 63 characters ([#405](https://github.com/opendevstack/ods-core/pull/405))
- Add missing PROV_APP_CROWD_URI param ([#384](https://github.com/opendevstack/ods-core/pull/384))
- Add missing SONAR_ADMIN_PASSWORD_B64 param ([#382](https://github.com/opendevstack/ods-core/pull/382))
- Use HTTPS in curl command ([#387](https://github.com/opendevstack/ods-core/pull/387))

### Removed
- remove inactive spring active profile property from prov app config map ([#64](https://github.com/opendevstack/ods-core/issues/648))
- Remove obsolete scripts from infrastructure-setup ([#618](https://github.com/opendevstack/ods-core/pull/618))
- removed owasp-dependency-check pvc and cli ([#556](https://github.com/opendevstack/ods-core/pull/556))

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
