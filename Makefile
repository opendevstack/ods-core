SHELL = /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# REPOSITORIES
## Prepare local repos by fetching changes from GitHub.
prepare-repos:
	cd ods-setup && ./repos.sh --no-push --confirm
.PHONY: prepare-repos

## Prepare local repos by fetching changes from GitHub, and synchronize with Bitbucket repos.
sync-repos:
	cd ods-setup && ./repos.sh --push --confirm
.PHONY: sync-repos


# ODS SETUP
## Setup central "cd" project.
cd-project:
	cd ods-setup && ./setup-ods-project.sh

# CONFIG
## Update local sample config sample and run check against local actual config.
prepare-config:
	cd ods-setup && ./config.sh
.PHONY: prepare-config

# JENKINS
## Install or update Jenkins resources.
jenkins: jenkins-apply-build jenkins-start-build
.PHONY: jenkins

## Update OpenShift resources related to Jenkins images.
jenkins-apply-build:
	cd jenkins/ocp-config && tailor update
.PHONY: jenkins-apply-build

## Start build of all Jenkins BuildConfig resources.
jenkins-start-build: jenkins-start-build-master jenkins-start-build-slave-base jenkins-start-build-webhook-proxy
.PHONY: jenkins-start-build

## Start build of BuildConfig "jenkins-master".
jenkins-start-build-master:
	ocp-scripts/start-and-follow-build.sh --build-config jenkins-master
.PHONY: jenkins-start-build-master

## Start build of BuildConfig "jenkins-slave-base".
jenkins-start-build-slave-base:
	ocp-scripts/start-and-follow-build.sh --build-config jenkins-slave-base
.PHONY: jenkins-start-build-slave-base

## Start build of BuildConfig "jenkins-webhook-proxy".
jenkins-start-build-webhook-proxy:
	ocp-scripts/start-and-follow-build.sh --build-config jenkins-webhook-proxy
.PHONY: jenkins-start-build-webhook-proxy

# SONARQUBE
## Install or update SonarQube.
sonarqube: sonarqube-apply-build sonarqube-start-build sonarqube-apply-deploy
.PHONY: sonarqube

## Update OpenShift resources related to the SonarQube image.
sonarqube-apply-build:
	cd sonarqube/ocp-config && tailor update bc,is
.PHONY: sonarqube-build-resources

## Update OpenShift resources related to the SonarQube service.
sonarqube-apply-deploy:
	cd sonarqube/ocp-config && tailor update --exclude bc,is
	route=$(oc get route sonarqube -ojsonpath={.spec.host}) && echo "Visit ${route}/setup to see if any update actions need to be taken."
.PHONY: sonarqube-apply-deploy

## Start build of BuildConfig "sonarqube".
sonarqube-start-build:
	ocp-scripts/start-and-follow-build.sh --build-config sonarqube
.PHONY: sonarqube-start-build

# NEXUS
## Install or update Nexus.
nexus: nexus-apply
.PHONY: nexus

## Update OpenShift resources related to the Nexus service.
nexus-apply:
	cd nexus/ocp-config && tailor update
.PHONY: nexus-apply

# SECURE ROUTE CHECKING
secure-routes: secure-routes-apply
.PHONY: secure-routes

secure-routes-apply:
	cd check-ocp-secure-routes/ocp-config && tailor update
.PHONY: secure-routes-apply

# BACKUP
## Create a backup of the current state.
backup: backup-sonarqube backup-ocp-config
.PHONY: backup

## Create a backup of OpenShift resources in "cd" namespace.
backup-ocp-config:
	tailor export -n cd > backup_cd.yml
.PHONY: backup-ocp-config

## Create a backup of the SonarQube database in the current directory.
backup-sonarqube:
	cd sonarqube && sh backup.sh .
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
