env ?= dev
ENV ?= $(env)
env := $(ENV)
ODS_CONFIGURATION_DIR := ../../ods-configuration
ODS_CONFIGURATION_FULL_PATH := $(abspath $(ODS_CONFIGURATION_DIR))
ODS_API_SERVICE_DATABASE_REPO := $(ODS_API_SERVICE_DIR:-.../ods-api-service)

# Load environment variables from ods-core.env file
include ../../ods-configuration/ods-core.env
export $(shell sed 's/=.*//' ../../ods-configuration/ods-core.env)

# Load environment variables from ods-core.ods-api-service.env file
include ../../ods-configuration/ods-core.ods-api-service.env
export $(shell sed 's/=.*//' ../../ods-configuration/ods-core.ods-api-service.env)

.DEFAULT_GOAL := help


##### HELM CHART MANAGEMENT
.PHONY: ods-api-service-helm-encrypt-secrets ods-api-service-helm-decrypt-secrets ods-api-service-helm-diff ods-api-service-render-helm-chart 

## Render ODS API Service Helm chart with all configurations (values and secrets).
ods-api-service-render-helm-chart:
	@cd chart && \
	helm secrets template ods-api-service . \
		-f $(ODS_CONFIGURATION_FULL_PATH)/ods-core.values.yaml \
		-f $(ODS_CONFIGURATION_FULL_PATH)/ods-core.secrets.enc.yaml \
		-f $(ODS_CONFIGURATION_FULL_PATH)/ods-api-service/values.yaml \
		-f $(ODS_CONFIGURATION_FULL_PATH)/ods-api-service/secrets.enc.yaml \
		-f $(ODS_CONFIGURATION_FULL_PATH)/ods-api-service/$(env)/values.$(env).yaml \
		-f $(ODS_CONFIGURATION_FULL_PATH)/ods-api-service/$(env)/secrets.$(env).enc.yaml \
		--set projectId=$(ODS_NAMESPACE) \
		--set appSelector=app=ods-api-service \
		--set registry=$(DOCKER_REGISTRY) \
		--set componentId=ods-api-service \
		--set global.projectId=$(ODS_NAMESPACE) \
		--set global.appSelector=app=ods-api-service \
		--set global.registry=$(DOCKER_REGISTRY) \
		--set global.componentId=ods-api-service \
		--set imageNamespace=$(ODS_NAMESPACE) \
		--set imageTag=$(ODS_IMAGE_TAG) \
		--set global.imageNamespace=$(ODS_NAMESPACE) \
		--set global.imageTag=$(ODS_IMAGE_TAG) \
		--set ODS_OPENSHIFT_APP_DOMAIN=$(OPENSHIFT_APPS_BASEDOMAIN)

## Render the generated application.yaml from Helm templates to a local file.
ods-api-service-render-application-yaml:
	@cd ods-api-service/chart && \
	helm secrets template ods-api-service . \
			-f $(ODS_CONFIGURATION_FULL_PATH)/ods-core.values.yaml \
			-f $(ODS_CONFIGURATION_FULL_PATH)/ods-core.secrets.enc.yaml \
			-f $(ODS_CONFIGURATION_FULL_PATH)/ods-api-service.values.yaml \
			-f $(ODS_CONFIGURATION_FULL_PATH)/ods-api-service/secrets.enc.yaml \
			-f $(ODS_CONFIGURATION_FULL_PATH)/ods-api-service/$(env)/values.$(env).yaml \
			-f $(ODS_CONFIGURATION_FULL_PATH)/ods-api-service/$(env)/secrets.$(env).enc.yaml \
		--set projectId=$(ODS_NAMESPACE) \
		--set appSelector=app=ods-api-service \
		--set registry=$(DOCKER_REGISTRY) \
		--set componentId=ods-api-service \
		--set global.projectId=$(ODS_NAMESPACE) \
		--set global.appSelector=app=ods-api-service \
		--set global.registry=$(DOCKER_REGISTRY) \
		--set global.componentId=ods-api-service \
		--set imageNamespace=$(ODS_NAMESPACE) \
		--set imageTag=$(ODS_IMAGE_TAG) \
		--set global.imageNamespace=$(ODS_NAMESPACE) \
		--set global.imageTag=$(ODS_IMAGE_TAG) \
		--set ODS_OPENSHIFT_APP_DOMAIN=$(OPENSHIFT_APPS_BASEDOMAIN) \
		2>/dev/null | \
		yq -r 'select(.kind == "ConfigMap") | select(.metadata.name == "ods-api-service-config") | .data["application.yaml"]'
		

## Render the generated .env file from Helm templates to a local file.
ods-api-service-renderdot-env:
	@cd ods-api-service/chart && \
	 helm secrets template ods-api-service . \
		-f $(ODS_CONFIGURATION_FULL_PATH)/ods-core.values.yaml \
		-f $(ODS_CONFIGURATION_FULL_PATH)/ods-core.secrets.enc.yaml \
		-f $(ODS_CONFIGURATION_FULL_PATH)/ods-api-service/values.yaml \
		-f $(ODS_CONFIGURATION_FULL_PATH)/ods-api-service/secrets.enc.yaml \
		-f $(ODS_CONFIGURATION_FULL_PATH)/ods-api-service/$(env)/values.$(env).yaml \
		-f $(ODS_CONFIGURATION_FULL_PATH)/ods-api-service/$(env)/secrets.$(env).enc.yaml \
		--set projectId=$(ODS_NAMESPACE) \
		--set appSelector=app=ods-api-service \
		--set registry=$(DOCKER_REGISTRY) \
		--set componentId=ods-api-service \
		--set global.projectId=$(ODS_NAMESPACE) \
		--set global.appSelector=app=ods-api-service \
		--set global.registry=$(DOCKER_REGISTRY) \
		--set global.componentId=ods-api-service \
		--set imageNamespace=$(ODS_NAMESPACE) \
		--set imageTag=$(ODS_IMAGE_TAG) \
		--set global.imageNamespace=$(ODS_NAMESPACE) \
		--set global.imageTag=$(ODS_IMAGE_TAG) \
		--set ODS_OPENSHIFT_APP_DOMAIN=$(OPENSHIFT_APPS_BASEDOMAIN) 2>/dev/null | ../../scripts/extract-config-env-from-template.sh



ods-api-service-helm-encrypt-secrets:
	@echo "Usage: make ods-api-service-helm-encrypt-secrets ENV=all|environment. It use ENV=dev by default if ENV is not set. It will encrypt secrets in the root of the configuration directory and in the environment-specific subdirectory (if it exists)."
	@echo "       make ods-api-service-helm-encrypt-secrets ODS_CONFIGURATION_DIR=path/to/config to specify a different configuration directory (default: ../ods-configuration)."

	@echo "Encrypting secrets in $(ODS_CONFIGURATION_DIR)..."
	./scripts/encrypt-helm-secrets.sh $(ODS_CONFIGURATION_DIR)/ods-api-service $(ENV)
	@echo "✓ Secrets encrypted"

## Decrypt secrets files (ENV=<name>|all, omit for root folder only)
ods-api-service-helm-decrypt-secrets:
	@echo "Usage: make ods-api-service-helm-decrypt-secrets ENV=all|environment. It use ENV=dev by default if ENV is not set. It will decrypt secrets in the root of the configuration directory and in the environment-specific subdirectory (if it exists)."
	@echo "       make ods-api-service-helm-decrypt-secrets ODS_CONFIGURATION_DIR=path/to/config to specify a different configuration directory (default: ../ods-configuration)."

	@echo "Decrypting secrets in $(ODS_CONFIGURATION_DIR)..."
	./scripts/decrypt-helm-secrets.sh $(ODS_CONFIGURATION_DIR) $(ENV)
	@echo "✓ Secrets decrypted"

## Diff Helm chart against cluster using helm secrets diff
ods-api-service-helm-diff:
	@echo "Running helm secrets diff (dry-run through Makefile)..."
	@export HELM_DIFF_IGNORE_UNKNOWN_FLAGS=true && helm -n devstack-dev secrets diff upgrade --install --atomic \
		-f $(ODS_CONFIGURATION_FULL_PATH)/ods-core.values.yaml \
		-f $(ODS_CONFIGURATION_FULL_PATH)/ods-core.secrets.enc.yaml \
		-f $(ODS_CONFIGURATION_FULL_PATH)/ods-api-service/values.yaml \
		-f $(ODS_CONFIGURATION_FULL_PATH)/ods-api-service/secrets.enc.yaml \
		-f $(ODS_CONFIGURATION_FULL_PATH)/ods-api-service/$(env)/values.$(env).yaml \
		-f $(ODS_CONFIGURATION_FULL_PATH)/ods-api-service/$(env)/secrets.$(env).enc.yaml \
		--set projectId=devstack \
		--set appSelector=app=devstack-api-service \
		--set registry=image-registry.openshift-image-registry.svc:5000 \
		--set componentId=api-service \
		--set global.projectId=devstack \
		--set global.appSelector=app=devstack-api-service \
		--set global.registry=image-registry.openshift-image-registry.svc:5000 \
		--set global.componentId=api-service \
		--set imageNamespace=devstack-dev \
		--set imageTag=b19c9164 \
		--set global.imageNamespace=devstack-dev \
		--set global.imageTag=b19c9164 \
		--set ODS_OPENSHIFT_APP_DOMAIN=apps.eu-dev.ocp.aws.boehringer.com \
		--no-color --three-way-merge --normalize-manifests \
		api-service ./chart

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