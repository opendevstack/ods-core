# Build stage
FROM public.ecr.aws/docker/library/golang:1.24-alpine AS builder

RUN apk update  && \
    apk -i upgrade && \
    apk cache clean && \
    mkdir -p /home/webhook-proxy

COPY main.go /home/webhook-proxy/main.go
COPY go.mod /home/webhook-proxy/go.mod

WORKDIR /home/webhook-proxy

RUN CGO_ENABLED=0 go build -o webhook-proxy

# Final stage
FROM registry.access.redhat.com/ubi9/ubi-micro@sha256:35de56a9413112f1474e392ebc35e0cf6f0fb484c8e8877bbae59b513694b41f

# Set default ALLOWED_EXTERNAL_PROJECTS env var
ARG allowedExternalProjects=opendevstack
ENV ALLOWED_EXTERNAL_PROJECTS=$allowedExternalProjects

RUN mkdir -p /home/webhook-proxy && \
    chgrp -R 0 /home/webhook-proxy && \
    chmod g+w /home/webhook-proxy

COPY --from=builder /home/webhook-proxy/webhook-proxy /home/webhook-proxy/webhook-proxy
COPY pipeline.json.tmpl /home/webhook-proxy/pipeline.json.tmpl

WORKDIR /home/webhook-proxy

USER 1001

EXPOSE 8080

CMD ./webhook-proxy
