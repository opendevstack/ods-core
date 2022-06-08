#!/usr/bin/env bash
set -eu
set -o pipefail

PROJECT=$1
BUILD_NAME=$2

BUILD_URL=$(oc get -n "${PROJECT}" build "${BUILD_NAME}" -o jsonpath='{.metadata.annotations.openshift\.io/jenkins-build-uri}')
echo "Using $BUILD_URL/testReport calculated from ${BUILD_NAME}"
TOKEN=$(oc -n "${PROJECT}" get sa/jenkins --template='{{range .secrets}}{{ .name }} {{end}}' | xargs -n 1 oc -n "${PROJECT}" get secret --template='{{ if .data.token }}{{ .data.token }}{{end}}' | head -n 1 | base64 -d -)

curl --insecure -sS "${BUILD_URL}/testReport" --location --header "Authorization: Bearer ${TOKEN}"
