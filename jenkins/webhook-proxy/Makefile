fmt:
	@(gofmt -w .)

build: build-linux build-darwin build-windows

build-linux:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o webhook-proxy_linux_amd64 -v github.com/opendevstack/ods-webhook-proxy

build-darwin:
	GOOS=darwin GOARCH=amd64 CGO_ENABLED=0 go build -o webhook-proxy_darwin_amd64 -v github.com/opendevstack/ods-webhook-proxy

build-windows:
	GOOS=windows GOARCH=amd64 CGO_ENABLED=0 go build -o webhook-proxy_windows_amd64.exe -v github.com/opendevstack/ods-webhook-proxy
