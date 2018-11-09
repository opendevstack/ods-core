# Ideally we would us a very small image like plain alpine and just copy the
# pre-built binary into it, but due to e.g. multistage builds not available in
# OpenShift yet, for now the easiest is to build the binary in this image.
FROM golang:1.11-alpine

RUN apk add --no-cache ca-certificates && \
    mkdir -p /home/webhook-proxy && \
    chgrp -R 0 /home/webhook-proxy && \
    chmod g+w /home/webhook-proxy

COPY main.go /home/webhook-proxy/main.go
COPY pipeline.json /home/webhook-proxy/pipeline.json

WORKDIR /home/webhook-proxy

RUN CGO_ENABLED=0 go build -o webhook-proxy

EXPOSE 8080

CMD ./webhook-proxy
