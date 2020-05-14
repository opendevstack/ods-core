# ODS Jenkins Slave base

## Introduction
The base jenkins slave used by all ODS [builder slaves](https://github.com/opendevstack/ods-quickstarters/tree/master/common/jenkins-slaves)

## Features / Plugins
1. Creates trust relationship with applications in the OpenShift cluster (through certificate management)
1. [Sonarqube scanner plugin](http://repo1.maven.org/maven2/org/sonarsource/scanner) binding to the central [SQ instance](../../sonarqube)
1. [Sonarqube report plugin](https://github.com/lequal/sonar-cnes-report) used to download the scan results within the
[jenkins shared library](https://github.com/opendevstack/ods-jenkins-shared-library)'s stage `odsComponentStageScanWithSonar` 
1. Creates proxy awareness when `HTTP_PROXY` is injected during build phase
1. [Tailor](https://github.com/opendevstack/tailor) - on top of `openshift CLI` to provide infrastructure as code
1. [Snyk Security Scan CLI](https://github.com/snyk/snyk) when `SNYK_DISTRIBUTION_URL` is injected during build phase
1. [skopeo](https://github.com/containers/skopeo) to [promote container images between registries](https://blog.openshift.com/promoting-container-images-between-registries-with-skopeo/).
