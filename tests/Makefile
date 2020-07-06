.PHONY: test lint verify prep-verify

test: verify create-projects/create-projects_test.go create-projects/create-projects_test.go go.mod go.sum
	@(echo "Testing project creation")
	@(./installation-test.sh)

prep-verify:
	go get github.com/googleapis/gnostic@v0.4.0
	go get github.com/jstemmer/go-junit-report

verify: prep-verify go.mod go.sum ods-verify/* utils/* validate/*
	@(echo "Verifying ODS installation")
	@(./verify.sh)

lint:
	echo "Checking code ..."
	golangci-lint run
