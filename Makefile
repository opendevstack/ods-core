SHELL = /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# CONFIG
## Update configuration based on sample config.
config:
	cd configuration-sample && ./update
.PHONY: config

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
	oc -n cd start-build jenkins-master --follow
.PHONY: jenkins-start-build-master

## Start build of BuildConfig "jenkins-slave-base".
jenkins-start-build-slave-base:
	oc -n cd start-build jenkins-slave-base --follow
.PHONY: jenkins-start-build-slave-base

## Start build of BuildConfig "jenkins-webhook-proxy".
jenkins-start-build-webhook-proxy:
	oc -n cd start-build jenkins-webhook-proxy --follow
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
	oc -n cd start-build sonarqube --follow
.PHONY: sonarqube-start-build

# NEXUS
## Install or update Nexus.
nexus: nexus-apply
.PHONY: nexus

## Update OpenShift resources related to the Nexus service.
nexus-apply:
	cd nexus/ocp-config && tailor update
.PHONY: nexus-apply

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
