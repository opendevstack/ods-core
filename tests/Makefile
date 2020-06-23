.PHONY: test lint

test: create-projects/create-projects_test.go create-projects/create-projects_test.go go.mod go.sum
	go test -v github.com/opendevstack/ods-core/tests/create-projects -run "^(TestCreateJenkins)"
	sleep 5
	go test -v github.com/opendevstack/ods-core/tests/create-projects -run "^(TestCreateProject)"
	sleep 5
	go test -v github.com/opendevstack/ods-core/tests/create-projects -run "^(TestJenkinsFile)"

lint:
	echo "Checking code ..."
	golangci-lint run
