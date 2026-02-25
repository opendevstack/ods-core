#!/usr/bin/env bash
set -eu
set -o pipefail

PROJECT=$2
BUILD_NAME=$1
BUILD_URL=$(oc get -n ${PROJECT} build ${BUILD_NAME} -o jsonpath='{.metadata.annotations.openshift\.io/jenkins-build-uri}')
echo $BUILD_URL

# Strip trailing slash to avoid double slashes in URL
BUILD_URL=${BUILD_URL%/}
ARTIFACT_URL="${BUILD_URL}/artifact/${3}"

# Extract just the filename from the artifact path for local storage
ARTIFACT_FILENAME=$(basename "$3")
OUTPUT_PATH="/tmp/${ARTIFACT_FILENAME}"

echo "grabbing artifact from $ARTIFACT_URL - and storing in ${OUTPUT_PATH}"
TOKEN=$(oc whoami --show-token)
httpCode=$(curl --insecure -sS ${ARTIFACT_URL} --header "Authorization: Bearer ${TOKEN}" -o "${OUTPUT_PATH}" -w "%{http_code}")
echo "response: $httpCode"
if [ ! "${httpCode}" == "200" ]; then
	echo "Could not find artifact $3 - url: $ARTIFACT_URL"
	exit 1
fi
