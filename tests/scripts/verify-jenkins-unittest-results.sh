#!/usr/bin/env bash
set -eu
set -o pipefail

PROJECT=$2
BUILD_NAME=$1
BUILD_URL=$(oc get -n "${PROJECT}" build "${BUILD_NAME}" -o jsonpath='{.metadata.annotations.openshift\.io/jenkins-build-uri}')
echo "Using $BUILD_URL/testReport calculated from ${BUILD_NAME} and searching for $3 tests"
TOKEN=$(oc -n "${PROJECT}" get sa/jenkins --template='{{range .secrets}}{{ .name }} {{end}}' | xargs -n 1 oc -n "${PROJECT}" get secret --template='{{ if .data.token }}{{ .data.token }}{{end}}' | head -n 1 | base64 -d -)
result=$(curl --insecure -sS "${BUILD_URL}/testReport" --location --header "Authorization: Bearer ${TOKEN}" | grep -oP '\K[[:digit:]]*(?= tests)')
echo "# of tests executed in pipeline ${BUILD_NAME}: ${result}"
if [[ ! "${result}" -gt 0 ]]
then
	echo "Could not find unit test results for build ${BUILD_NAME} in project ${PROJECT}"
	exit 1
fi
