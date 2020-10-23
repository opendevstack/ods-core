SHELL = /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

ODS_NAMESPACE := $(shell $(CURDIR)/scripts/get-config-param.sh ODS_NAMESPACE)
NEXUS_URL := $(shell $(CURDIR)/scripts/get-config-param.sh NEXUS_URL)
SONARQUBE_URL := $(shell $(CURDIR)/scripts/get-config-param.sh SONARQUBE_URL)
INSECURE := false
INSECURE_FLAG :=
ifeq ($(INSECURE), $(filter $(INSECURE), true yes))
    INSECURE_FLAG = --insecure
endif

# REPOSITORIES
## Prepare Bitbucket repos (create project and repos).
prepare-bitbucket-repos:
	cd ods-setup && ./bitbucket.sh $(INSECURE_FLAG)
.PHONY: prepare-bitbucket-repos

## Prepare local repos (fetch changes from Bitbucket).
prepare-local-repos:
	cd ods-setup && ./repos.sh --confirm
.PHONY: prepare-local-repos

## Sync repos (fetch changes from GitHub, and synchronize with Bitbucket).
sync-repos:
	cd ods-setup && ./repos.sh --sync --confirm
.PHONY: sync-repos

## Set ODS_IMAGE_TAG ref in Jenkins Shared Library.
set-shared-library-ref:
	cd scripts && ./set-shared-library-ref.sh
.PHONY: set-shared-library-ref


# CONFIG
## Update local sample config sample and run check against local actual config.
prepare-config:
	cd ods-setup && ./config.sh
.PHONY: prepare-config


# ODS SETUP
## Setup central "ods" project.
install-ods-project:
	cd ods-setup && ./setup-ods-project.sh --namespace $(ODS_NAMESPACE) --reveal-secrets


# JENKINS
## Install or update Jenkins resources.
install-jenkins: apply-jenkins-build start-jenkins-build apply-jenkins-deploy
.PHONY: install-jenkins

## Update OpenShift resources related to Jenkins images.
apply-jenkins-build:
	cd jenkins/ocp-config/build && tailor apply --namespace $(ODS_NAMESPACE)
.PHONY: apply-jenkins-build

## Install a jenkins instance in the ods namespace (needed by the provisioning app)
apply-jenkins-deploy:
	cd jenkins/ocp-config/deploy && tailor apply --namespace $(ODS_NAMESPACE) --selector template=ods-jenkins-template
.PHONY: apply-jenkins-deploy

## Start build of all Jenkins BuildConfig resources.
start-jenkins-build: start-jenkins-build-master start-jenkins-build-agent-base start-jenkins-build-webhook-proxy
.PHONY: jenkins-build

## Start build of BuildConfig "jenkins-master".
start-jenkins-build-master:
	ocp-scripts/start-and-follow-build.sh --namespace $(ODS_NAMESPACE) --build-config jenkins-master
.PHONY: start-jenkins-build-master

## Start build of BuildConfig "jenkins-agent-base".
start-jenkins-build-agent-base:
	ocp-scripts/start-and-follow-build.sh --namespace $(ODS_NAMESPACE) --build-config jenkins-agent-base
.PHONY: start-jenkins-build-agent-base

## Start build of BuildConfig "jenkins-webhook-proxy".
start-jenkins-build-webhook-proxy:
	ocp-scripts/start-and-follow-build.sh --namespace $(ODS_NAMESPACE) --build-config jenkins-webhook-proxy
.PHONY: start-jenkins-build-webhook-proxy


# PROVISIONING APP
## Install the provisioning app.
install-provisioning-app: apply-provisioning-app-build start-provisioning-app-build apply-provisioning-app-deploy
.PHONY: install-provisioning-app

## Update OpenShift resources related to the Provisioning App image.
apply-provisioning-app-build:
	cd ods-provisioning-app/ocp-config && tailor apply --namespace $(ODS_NAMESPACE) is,bc
.PHONY: apply-provisioning-app-build

## Start build of BuildConfig "ods-provisioning-app".
start-provisioning-app-build:
	ocp-scripts/start-and-follow-build.sh --namespace $(ODS_NAMESPACE) --build-config ods-provisioning-app
.PHONY: start-provisioning-app-build

## Update OpenShift resources related to the Provisioning App service.
apply-provisioning-app-deploy:
	cd ods-provisioning-app/ocp-config && tailor apply --namespace $(ODS_NAMESPACE) --exclude is,bc
.PHONY: apply-provisioning-app-deploy

# DOCUMENT GENERATION SERVICE IMAGE
## Install the documentation generation image.
install-doc-gen: apply-doc-gen-build start-doc-gen-build
.PHONY: install-doc-gen

## Update OpenShift resources related to the Document Generation image.
apply-doc-gen-build:
	cd ods-document-generation-svc/ocp-config && tailor apply --namespace $(ODS_NAMESPACE)
.PHONY: apply-doc-gen-build

## Start build of BuildConfig "ods-doc-gen-svc".
start-doc-gen-build:
	ocp-scripts/start-and-follow-build.sh --namespace $(ODS_NAMESPACE) --build-config ods-doc-gen-svc
.PHONY: start-doc-gen-build


# SONARQUBE
## Install or update SonarQube.
install-sonarqube: apply-sonarqube-build start-sonarqube-build apply-sonarqube-deploy configure-sonarqube
.PHONY: install-sonarqube

## Update OpenShift resources related to the SonarQube image.
apply-sonarqube-build:
	cd sonarqube/ocp-config && tailor apply --namespace $(ODS_NAMESPACE) bc,is
.PHONY: apply-sonarqube-build

## Start build of BuildConfig "sonarqube".
start-sonarqube-build:
	ocp-scripts/start-and-follow-build.sh --namespace $(ODS_NAMESPACE) --build-config sonarqube
.PHONY: start-sonarqube-build

## Update OpenShift resources related to the SonarQube service.
apply-sonarqube-deploy:
	cd sonarqube/ocp-config && tailor apply --namespace $(ODS_NAMESPACE) --exclude bc,is
	@echo "Visit $(SONARQUBE_URL)/setup to see if any update actions need to be taken."
.PHONY: apply-sonarqube-deploy

## Configure SonarQube service.
configure-sonarqube:
	cd sonarqube && ./configure.sh --sonarqube=$(SONARQUBE_URL) $(INSECURE_FLAG)
.PHONY: configure-sonarqube


# NEXUS
## Install or update Nexus.
install-nexus: apply-nexus-build start-nexus-build apply-nexus-deploy
.PHONY: nexus

## Update OpenShift resources related to the Nexus image.
apply-nexus-build:
	cd nexus/ocp-config && tailor apply --namespace $(ODS_NAMESPACE) bc,is
.PHONY: apply-nexus-build

## Start build of BuildConfig "nexus".
start-nexus-build:
	ocp-scripts/start-and-follow-build.sh --namespace $(ODS_NAMESPACE) --build-config nexus
.PHONY: start-nexus-build

## Update OpenShift resources related to the Nexus service.
apply-nexus-deploy:
	cd nexus/ocp-config && tailor apply --namespace $(ODS_NAMESPACE) --exclude bc,is
.PHONY: apply-nexus-deploy

## Configure Nexus service.
configure-nexus:
	cd nexus && ./configure.sh --namespace $(ODS_NAMESPACE) --nexus=$(NEXUS_URL) $(INSECURE_FLAG)
.PHONY: configure-nexus
### configure-nexus is not part of install-nexus because it is not idempotent yet.


# BACKUP
## Create a backup of the current state.
backup: backup-sonarqube backup-ocp-config
.PHONY: backup

## Create a backup of OpenShift resources in "cd" namespace.
backup-ocp-config:
	tailor export --namespace $(ODS_NAMESPACE) > backup_cd.yml
.PHONY: backup-ocp-config

## Create a backup of the SonarQube database in the current directory.
backup-sonarqube:
	cd sonarqube && ./backup.sh --namespace $(ODS_NAMESPACE) --backup-dir `pwd`
.PHONY: backup-sonarqube


### HELP
### Based on https://gist.github.com/prwhite/8168133#gistcomment-2278355.
help:
	@echo ''
	@echo 'Usage:'
	@echo '  make <target>'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:|^# .*/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  %-35s %s\n", helpCommand, helpMessage; \
		} else { \
			printf "\n"; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
.PHONY: help
