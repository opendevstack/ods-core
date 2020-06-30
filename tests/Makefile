.PHONY: test lint verify prep-verify

test: create-projects/create-projects_test.go create-projects/create-projects_test.go go.mod go.sum
	go test -v github.com/opendevstack/ods-core/tests/create-projects -run "^(TestCreateJenkins)"
	sleep 5
	go test -v github.com/opendevstack/ods-core/tests/create-projects -run "^(TestCreateProject)"
	sleep 5
	go test -v github.com/opendevstack/ods-core/tests/create-projects -run "^(TestJenkinsFile)"

prep-verify:
	go get github.com/jstemmer/go-junit-report

verify: ods-verify/verify-ods-core-env-available_test.go ods-verify/verify-ods-namespace-images_test.go go.mod go.sum utils/* validate/*
	@(echo "Verifying ODS installation")
	@(go test -v -timeout 30s github.com/opendevstack/ods-core/tests/ods-verify 2>&1 > test-results.txt)
	@(cat test-results.txt | go-junit-report > test-report.xml)


lint:
	echo "Checking code ..."
	golangci-lint run
