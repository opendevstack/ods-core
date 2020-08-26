#!/usr/bin/env bash
set -eu
set -o pipefail

PROJECT=$2
BUILD_NAME=$1
BUILD_URL=$(oc get -n ${PROJECT} build ${BUILD_NAME} -o jsonpath='{.metadata.annotations.openshift\.io/jenkins-build-uri}')
echo $BUILD_URL
ARTIFACT_URL=$BUILD_URL/artifact/artifacts/$3
echo "grabbing artifact from $ARTIFACT_URL - and storing in /tmp"
TOKEN=$(oc -n ${PROJECT} get sa/jenkins --template='{{range .secrets}}{{ .name }} {{end}}' | xargs -n 1 oc -n ${PROJECT} get secret --template='{{ if .data.token }}{{ .data.token }}{{end}}' | head -n 1 | base64 -d -)
httpCode=$(curl --insecure -sS ${ARTIFACT_URL} --header "Authorization: Bearer ${TOKEN}" -o /tmp/$3 -w "%{http_code}")
echo "response: $httpCode"
if [ ! "${httpCode}" == "200" ]; then
	echo "Could not find artifact $3 - url: $ARTIFACT_URL"
	exit 1
fi
