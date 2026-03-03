#!/usr/bin/env bash
set -eu
set -o pipefail

PROJECT=$2
BUILD_NAME=$1
BUILD_URL=$(oc get -n ${PROJECT} build ${BUILD_NAME} -o jsonpath='{.metadata.annotations.openshift\.io/jenkins-build-uri}')
echo $BUILD_URL

# Strip trailing slash to avoid double slashes in URL
BUILD_URL=${BUILD_URL%/}

# Extract just the filename from the artifact path for local storage
ARTIFACT_FILENAME=$(basename "$3")
OUTPUT_PATH="/tmp/${ARTIFACT_FILENAME}"

# Define candidate artifact URLs
ARTIFACT_URLS=(
	"${BUILD_URL}/artifact/${3}"
	"${BUILD_URL}/artifact/artifacts/${3}"
)

TOKEN=$(oc whoami --show-token)
echo "grabbing artifact from $ARTIFACT_FILENAME - and storing in ${OUTPUT_PATH}"

# Try each URL until one succeeds
for url in "${ARTIFACT_URLS[@]}"; do
	httpCode=$(curl --insecure -sS "${url}" --header "Authorization: Bearer ${TOKEN}" -o "${OUTPUT_PATH}" -w "%{http_code}")
	echo "trying: $url - response: $httpCode"
	if [ "${httpCode}" == "200" ]; then
		exit 0
	fi
done

echo "Could not find artifact $3"
exit 1
