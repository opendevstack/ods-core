#!/usr/bin/env bash
set -eu
set -o pipefail

PROJECT=$1
BUILD_NAME=$2

BUILD_URL=$(oc get -n "${PROJECT}" build "${BUILD_NAME}" -o jsonpath='{.metadata.annotations.openshift\.io/jenkins-build-uri}')
echo "Using $BUILD_URL/testReport calculated from ${BUILD_NAME}"
TOKEN=$(oc whoami --show-token)

curl --insecure -sS "${BUILD_URL}/testReport" --location --header "Authorization: Bearer ${TOKEN}"
