.PHONY: test build download lint

build: download tests/create-projects/testsuite

test: tests/create-projects/create-projects_test.go tests/create-projects/create-projects_test.go go.mod go.sum
	@(go test -v -cover github.com/opendevstack/ods-core/tests/create-projects)

download:
	@(echo "Downloading modules ...")
	@(go mod download)

lint:
	@(echo "Checking code ...")
	@(golangci-lint run)

#imports:
#	@(echo "Fixing go imports ...")
#	@(goimports -w .)
