# ODS core & infrastructure

![](https://github.com/opendevstack/ods-core/workflows/Continous%20Integration%20Tests/badge.svg?branch=master)

## Introduction
OpenDevStack (ODS) Core houses the all the central infrastructure components.

All the contained components except Atlassian tools are built in the Openshift central `ods` namespace.

The extended, most up to date, user friendly documentation can be found @ [opendevstack.org](https://www.opendevstack.org/ods-documentation/)

## Contents
1. [Jenkins master](jenkins/master) & base agent - the basis of the ODS build engine<br>
The [base agent](jenkins/agent-base) provides plugins for Sonarqube, optionally Snyk, CNES, skopeo and is HTTP proxy aware.
Specific [quickstarters / boilerplates](https://github.com/opendevstack/ods-quickstarters/tree/master) require different technologies e.g. `gradle`, `NPM/Yarn` etc. to build, hence warrant their own `builder agents`. These `agents` are based on the ods `jenkins base agent` and are hosted in the [ods-quickstarter repository](https://github.com/opendevstack/ods-quickstarters/tree/master/common/jenkins-agents) - next to their respective [boilerplates](https://github.com/opendevstack/ods-quickstarters/tree/master). <br>During `jenkins` builds, instances/pods of those `builder / agent` images can be found within the project specific `cd` namespace.
<br>*Deployment:* one global Jenkins instance in the central `ods` namespace

1. [Jenkins Webhook proxy](jenkins/webhook-proxy) - the glue layer between Bitbucket / Jira and Jenkins - to start a build from a change in a repository.
<br>*Deployment:* There is one instance of the webhook proxy in each project's `cd` namespace. The base image of the webhook proxy is located in the central `ods` namespace

1. [Nexus](nexus) - repository manager <br>
Nexus is used as artifact manager throughout OpenDevStack. Each [`jenkins agent`](https://github.com/opendevstack/ods-quickstarters/tree/master/common/jenkins-agents) is configured to bind to the installed NEXUS to centralize build / dependency artifact resolution.
<br>*Deployment:* There is one central instance of Nexus in the `ods` project

1. [Sonarqube](sonarqube) - Sofware quality management <br>
The OpenDevStack version of Sonarqube - preconfigured with language plugins used by the [boilerplates](https://github.com/opendevstack/ods-quickstarters/tree/master). All generated `Jenkinsfile`s contain a stage `stageScanForSonarQube` for sourcecode review - which connects to this central instance.
<br>*Deployment:* There is one central instance of SQ in the `ods` project

1. [ODS Provisioning Application](ods-provisioning-app) - The 'entrypoint' to work with OpenDevStack<br>
Provides the functionality to provision new projects and also components within those, based on [boilerplates](https://github.com/opendevstack/ods-quickstarters/tree/master). <br>The code for the provision application can be found [here](https://github.com/opendevstack/ods-provisioning-app). In case you want to work on the provision application, and build it yourself - there is a quickstarter that allows this, namely [ODS Provisioning Quickstarter](https://github.com/opendevstack/ods-quickstarters/tree/master/ods-provisioning-app).
<br>*Deployment:* There is one central instance of the provisioning app in the `ods` project

1. [ODS document generation service](ods-document-generation-svc) - a service used to create PDF documents from json input and html templates.
Used by the [release manager quickstarter](https://github.com/opendevstack/ods-quickstarters/tree/master/release-manager).
The templates are located in the [templates repository](https://github.com/opendevstack/ods-document-generation-templates). <br>The code for the documentation generation service is located [here](https://github.com/opendevstack/ods-document-generation-svc). In case you want to work on the document generation service, and build it yourself - there is a quickstarter that allows this, namely [ODS Document Generation Service](https://github.com/opendevstack/ods-quickstarters/tree/master/ods-document-gen-svc). <br>*Deployment:* There is one instance of the document generation service in each project's `cd` namespace. The base image of the doc gen service is located in the central `ods` namespace

1. [Atlassian infrastructure](infrastructure-setup) <br>
Contains all the ansible scripts to setup jira / confluence / bitbucket and atlassian crowd. Optional, if you have your own instances running, you can just configure OpenDevStack to use those in `ods-configuration/ods-core.env`.

1. [Tests](tests) <br>
The automated tests for ods core are in two locations:<br>
a) located side by side to the components, e.g for `sonarqube` they are located in [sonarqube/test.sh](sonarqube/test.sh). <br>
b) inside the [/tests](tests) directory. </p> The tests can be started with `make test`, which will call two test-suites. Namely, the tests to create a new project in [/tests/create-projects](tests/create-projects) and those in [/tests/ods-verify](tests/ods-verify). If both pass - the setup of ods-core components is successfull. <br>Running the ods-core tests is also a pre-condition for the [ods-quickstarter tests](https://github.com/opendevstack/ods-quickstarters/tree/master/tests), as the test projects are created thru the tests here.

1. [ODS Development Environment / ODS in a box](ods-devenv)<br>
ODS also ships as Amazon AMI - ready to go. The scripts to create the AMI can be found in ods-devenv. These scripts can be used also be used to install a `developer` version of ODS on a plain linux vm. Simply execute [bootstrap.sh](ods-devenv/scripts/bootstrap.sh)
