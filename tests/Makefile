SHELL = /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

### By default we test all quickstarters located in ods-quickstarters
QS := ods-quickstarters/...

### By default we do not parallelize tests
PARALLEL := 1

## Full test of existing ODS core installation. Caution: Creates UNITT project and ODSVERIFY project.
test: smoketest verify test-create-projects
.PHONY: test

## Verify existing ODS core installation.
verify: prep-tools
	@(echo "Verifying ODS installation")
	@(./verify.sh)
.PHONY: verify

## Test crucial functionality of existing ODS installation (project/component provision). Caution: Creates ODSVERIFY project.
smoketest: prep-tools
	@(echo "Smoke testing ODS installation")
	# Customisable by prov-app-config.txt in smoketest directory.
	@(./smoke-test.sh)
.PHONY: smoketest

## Test project creation. Caution: Creates UNITT project.
test-create-projects:
	@(echo "Run project creation tests")
	@(./create-projects-test.sh)
.PHONY: test-create-projects

## Run quickstarter tests within existing ODS installation. Depends on UNITT project.
test-quickstarter:
	@(./quickstarter-test.sh $(QS) $(PARALLEL))
.PHONY: test-quickstarter

## Install tools required for tests.
prep-tools:
	which go-junit-report || go get github.com/jstemmer/go-junit-report
.PHONY: prep-tools

## Lint
lint:
	echo "Checking code ..."
	golangci-lint --version
	golangci-lint run --go=1.18
.PHONY: lint

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
