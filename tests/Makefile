.PHONY: test lint verify prep-verify

test: verify create-projects/create-projects_test.go create-projects/create-projects_test.go go.mod go.sum
	go test -v github.com/opendevstack/ods-core/tests/create-projects -run "^(TestCreateNakedOCPProjectsThruShellScripts)"
	sleep 5
	go test -v github.com/opendevstack/ods-core/tests/create-projects -run "^(TestCreateODSJenkinsThruShellScripts)"
	sleep 5
	go test -v github.com/opendevstack/ods-core/tests/create-projects -run "^(TestCreateProjectThruWebhookProxyJenkinsFile)"

prep-verify:
	go get github.com/googleapis/gnostic@v0.4.0
	go get github.com/jstemmer/go-junit-report

verify: prep-verify go.mod go.sum ods-verify/* utils/* validate/*
	@(echo "Verifying ODS installation")
	@(./verify.sh)


lint:
	echo "Checking code ..."
	golangci-lint run
