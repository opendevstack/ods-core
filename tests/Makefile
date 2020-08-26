.PHONY: test lint verify prep-verify

# By default we test all quickstarters located in ods-quickstarters
QS := ods-quickstarters/...

# Run ods-core tests.
# Creates UNITT project and ODSVEROFY project.
test: verify create-projects/create-projects_test.go create-projects/create-projects_test.go go.mod go.sum
	@(echo "Testing project creation")
	@(./installation-test.sh)

# Run quickstarter tests.
test-quickstarter:
	@(./quickstarter-test.sh $(QS))

# Install tools required for verify target.
prep-verify:
	go get github.com/jstemmer/go-junit-report

# Verify existing ODS installation. It runs tests in ods-verify.
# Customisable by prov-app-config.txt in ods-verify directory.
verify: prep-verify go.mod go.sum ods-verify/* utils/* validate/*
	@(echo "Verifying ODS installation")
	@(./verify.sh)

lint:
	echo "Checking code ..."
	golangci-lint run
