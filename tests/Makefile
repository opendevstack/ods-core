.PHONY: test lint verify prep-verify

test: verify create-projects/create-projects_test.go create-projects/create-projects_test.go go.mod go.sum
	go test -v github.com/opendevstack/ods-core/tests/create-projects -run "^(TestCreateJenkins)"
	sleep 5
	go test -v github.com/opendevstack/ods-core/tests/create-projects -run "^(TestCreateProject)"
	sleep 5
	go test -v github.com/opendevstack/ods-core/tests/create-projects -run "^(TestJenkinsFile)"

prep-verify:
	go get github.com/jstemmer/go-junit-report

verify: prep-verify go.mod go.sum ods-verify/* utils/* validate/*
	@(echo "Verifying ODS installation")
	@(./verify.sh)


lint:
	echo "Checking code ..."
	golangci-lint run
