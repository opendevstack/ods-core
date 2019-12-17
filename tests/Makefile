.PHONY: test lint

test: create-projects/create-projects_test.go create-projects/create-projects_test.go go.mod go.sum
	@(go test -v ./...)

lint:
	@(echo "Checking code ...")
	@(golangci-lint run)
