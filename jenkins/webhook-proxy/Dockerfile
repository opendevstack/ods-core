# Build stage
FROM golang:1.23-alpine AS builder

RUN apk update  && \
    apk -i upgrade && \
    apk cache clean && \
    mkdir -p /home/webhook-proxy

COPY main.go /home/webhook-proxy/main.go
COPY go.mod /home/webhook-proxy/go.mod

WORKDIR /home/webhook-proxy

RUN CGO_ENABLED=0 go build -o webhook-proxy

# Final stage
FROM alpine:latest

# Set default ALLOWED_EXTERNAL_PROJECTS env var
ARG allowedExternalProjects=opendevstack
ENV ALLOWED_EXTERNAL_PROJECTS=$allowedExternalProjects

RUN apk update  && \
    apk -i upgrade && \
    apk cache clean && \
    mkdir -p /home/webhook-proxy && \
    chgrp -R 0 /home/webhook-proxy && \
    chmod g+w /home/webhook-proxy

COPY --from=builder /home/webhook-proxy/webhook-proxy /home/webhook-proxy/webhook-proxy
COPY pipeline.json.tmpl /home/webhook-proxy/pipeline.json.tmpl

WORKDIR /home/webhook-proxy

EXPOSE 8080

CMD ./webhook-proxy
