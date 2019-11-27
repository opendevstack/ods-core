# ODS core & infrastructure

## Introduction
OpenDevStack (ODS) Core houses the all the central infrastructure components.

All the contained components except Atlassian tools are built in the Openshift central `CD` namespace.

## Contents
1. [Jenkins master](jenkins/master) & base slave - the basis of the ODS build engine <br>
The [base slave](jenkins/slave-base) provides plugins for OWASP, Sonarqube, and CNES and is HTTP proxy aware.
Specific [quickstarters / boilerplates](https://github.com/opendevstack/ods-quickstarters/tree/master) require different technologies e.g. `gradle`, `NPM/Yarn` etc. to build, hence warrant their own `builder slaves`. These `slaves` are based on this `base slave` and are hosted in the [ods-quickstarter repository](https://github.com/opendevstack/ods-quickstarters/tree/master/common/jenkins-slaves) - next to their respective [boilerplates](https://github.com/opendevstack/ods-quickstarters/tree/master). <br><br>During `jenkins` builds instances/pods of those `builder` images can be found within the project specific `project-cd` namespace.

1. [Nexus](nexus) - repository manager <br>
Nexus is used as artifact manager throughout OpenDevStack. Each [`jenkins slave`](https://github.com/opendevstack/ods-quickstarters/tree/master/common/jenkins-slaves) is configured to bind to the installed NEXUS to centralize build / dependency artifact resolution. There is one central instance of Nexus in the `CD` project

1. [Sonarqube](sonarqube) - Sofware quality management <br>
The OpenDevStack version of Sonarqube - preconfigured with language plugins used by the [boilerplates](https://github.com/opendevstack/ods-quickstarters/tree/master). All generated `Jenkinsfile`s contain a stage `stageScanForSonarQube` for sourcecode review - which connects to this central instance. There is one central instance of SQ in the `CD` project

4. [Shared images](shared-images) - Docker Images for common functionality <br>
   1. The [Airflow](shared-images/airflow) and [Elasticsearch](shared-images/elasticsearch) images - used for Airflow quickstarter, an [Airflow](https://airflow.apache.org/) OpenDevStack compatible and enhanced implementation.
   2. The [webhook proxy](jenkins/webhook-proxy) used to connect Bitbucket webhooks to their respective jenkins instances. For example a merged PR will trigger the respective `webook proxy` instance in the right `project`, which in turn creates an `openshift build pipeline`, that triggers jenkins to build.

5. [Atlassian infrastructure](infrastructure-setup) <br>
Contains all the ansible scripts to setup jira / confluence / bitbucket and atlassian crowd. Optional, if you have your own instances running, you can just configure OpenDevStack to use those.
