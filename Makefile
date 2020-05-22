SHELL = /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

NAMESPACE=ods
NEXUS_URL=
SONARQUBE_URL=

# REPOSITORIES
## Prepare local repos (fetch changes from Bitbucket).
prepare-repos:
	cd ods-setup && ./repos.sh --confirm
.PHONY: prepare-repos

## Sync repos (fetch changes from GitHub, and synchronize with Bitbucket).
sync-repos:
	cd ods-setup && ./repos.sh --sync --confirm
.PHONY: sync-repos


# CONFIG
## Update local sample config sample and run check against local actual config.
prepare-config:
	cd ods-setup && ./config.sh
.PHONY: prepare-config


# ODS SETUP
## Setup central "ods" project.
install-ods-project:
	cd ods-setup && ./setup-ods-project.sh --namespace ${NAMESPACE} --reveal-secrets


# JENKINS
## Install or update Jenkins resources.
install-jenkins: apply-jenkins-build start-jenkins-build apply-jenkins-deploy
.PHONY: install-jenkins

## Update OpenShift resources related to Jenkins images.
apply-jenkins-build:
	cd jenkins/ocp-config/build && tailor apply --namespace ${NAMESPACE}
.PHONY: apply-jenkins-build

## Install a jenkins instance in the ods namespace (needed by the provisioning app)
apply-jenkins-deploy:
	cd jenkins/ocp-config/deploy && tailor apply --namespace ${NAMESPACE} --selector template=ods-jenkins-template
.PHONY: apply-jenkins-deploy

## Start build of all Jenkins BuildConfig resources.
start-jenkins-build: start-jenkins-build-master start-jenkins-build-slave-base start-jenkins-build-webhook-proxy
.PHONY: jenkins-build

## Start build of BuildConfig "jenkins-master".
start-jenkins-build-master:
	ocp-scripts/start-and-follow-build.sh --namespace ${NAMESPACE} --build-config jenkins-master
.PHONY: start-jenkins-build-master

## Start build of BuildConfig "jenkins-slave-base".
start-jenkins-build-slave-base:
	ocp-scripts/start-and-follow-build.sh --namespace ${NAMESPACE} --build-config jenkins-slave-base
.PHONY: start-jenkins-build-slave-base

## Start build of BuildConfig "jenkins-webhook-proxy".
start-jenkins-build-webhook-proxy:
	ocp-scripts/start-and-follow-build.sh --namespace ${NAMESPACE} --build-config jenkins-webhook-proxy
.PHONY: start-jenkins-build-webhook-proxy


# PROVISIONING APP
## Install the provision app.
install-provisioning-app: apply-provisioning-app-deploy
.PHONY: install-provisioning-app

## Update OpenShift resources related to the Provisioning App service.
apply-provisioning-app-deploy:
	cd ods-provisioning-app/ocp-config && tailor apply --namespace ${NAMESPACE} is
	ocp-scripts/import-image-from-dockerhub.sh --namespace ${NAMESPACE} --image ods-provisioning-app --target-stream ods-provisioning-app
	cd ods-provisioning-app/ocp-config && tailor apply --namespace ${NAMESPACE} --exclude is
.PHONY: apply-provisioning-app-deploy


# DOCUMENT GENERATION SERVICE
## Install the documentation generation service.
install-doc-gen: apply-doc-gen-build
.PHONY: install-doc-gen

## Update OpenShift resources related to the Document Generation image.
apply-doc-gen-build:
	cd ods-doc-gen-svc/ocp-config && tailor apply --namespace ${NAMESPACE}
	ocp-scripts/import-image-from-dockerhub.sh --namespace ${NAMESPACE} --image ods-document-generation-svc --target-stream ods-doc-gen-svc
.PHONY: apply-doc-gen-build


# SONARQUBE
## Install or update SonarQube.
install-sonarqube: apply-sonarqube-build start-sonarqube-build apply-sonarqube-deploy configure-sonarqube
.PHONY: install-sonarqube

## Update OpenShift resources related to the SonarQube image.
apply-sonarqube-build:
	cd sonarqube/ocp-config && tailor apply --namespace ${NAMESPACE} bc,is
.PHONY: apply-sonarqube-build

## Start build of BuildConfig "sonarqube".
start-sonarqube-build:
	ocp-scripts/start-and-follow-build.sh --namespace ${NAMESPACE} --build-config sonarqube
.PHONY: start-sonarqube-build

## Update OpenShift resources related to the SonarQube service.
apply-sonarqube-deploy:
	cd sonarqube/ocp-config && tailor apply --namespace ${NAMESPACE} --exclude bc,is --param ODS_NAMESPACE=${NAMESPACE}
	SONARQUBE_URL=`oc -n ${NAMESPACE} get route sonarqube -ojsonpath={.spec.host}`
	echo "Visit ${SONARQUBE_URL}/setup to see if any update actions need to be taken."
.PHONY: apply-sonarqube-deploy

## Configure SonarQube service.
configure-sonarqube:
	SONARQUBE_URL=`oc -n ${NAMESPACE} get route sonarqube -ojsonpath={.spec.host}`
	cd sonarqube && ./configure.sh --sonarqube=${SONARQUBE_URL}
.PHONY: configure-sonarqube


# NEXUS
## Install or update Nexus.
install-nexus: apply-nexus
.PHONY: nexus

## Update OpenShift resources related to the Nexus service.
apply-nexus:
	cd nexus/ocp-config && tailor apply --namespace ${NAMESPACE}
.PHONY: apply-nexus

## Configure Nexus service.
### Not part of install-nexus because it is not idempotent yet.
configure-nexus:
	NEXUS_URL=`oc -n ${NAMESPACE} get route nexus -ojsonpath={.spec.host}`
	cd nexus && ./configure.sh --namespace ${NAMESPACE} --nexus=${NEXUS_URL}
.PHONY: configure-nexus


# BACKUP
## Create a backup of the current state.
backup: backup-sonarqube backup-ocp-config
.PHONY: backup

## Create a backup of OpenShift resources in "cd" namespace.
backup-ocp-config:
	tailor export --namespace ${NAMESPACE} > backup_cd.yml
.PHONY: backup-ocp-config

## Create a backup of the SonarQube database in the current directory.
backup-sonarqube:
	cd sonarqube && ./backup.sh --namespace ${NAMESPACE} --backup-dir `pwd`
.PHONY: backup-sonarqube


# HELP
# Based on https://gist.github.com/prwhite/8168133#gistcomment-2278355.
help:
	@echo ''
	@echo 'Usage:'
	@echo '  make <target>'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  %-35s %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
.PHONY: help
