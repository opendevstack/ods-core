#!/usr/bin/env bash
# Start build of given image and follows the output.
# Depending on the VM available resources, the build process might take longer than expected.
# Instead of hard-coding a timeout value and hope for the build to complete within that time frame, simply wait for the build to complete successfully.

set -ue

NAMESPACE="ods"
BUILD_CONFIG=

function usage {
  printf "usage: %s [options]\n" $0
  printf "\t-h|--help\tPrints the usage\n"
  printf "\t-v|--verbose\tVerbose output\n"
  printf "\t-b|--build-config\tName of BuildConfig to start build for\n"
  printf "\t-n|--namespace\tNamespace (defaults to '${NAMESPACE}')\n"
}

while [[ "$#" -gt 0 ]]; do case $1 in
  -v|--verbose) set -x;;

  -h|--help) usage; exit 0;;

  -b=*|--build-config=*) BUILD_CONFIG="${1#*=}";;
  -b|--build-config) BUILD_CONFIG="$2"; shift;;

  -n=*|--namespace=*) NAMESPACE="${1#*=}";;
  -n|--namespace) NAMESPACE="$2"; shift;;

  *) echo "Unknown parameter passed: $1"; usage; exit 1;;
esac; shift; done

if [ -z ${BUILD_CONFIG} ]; then
  echo "Param --build-config is missing."; usage; exit 1;
fi

if ! oc whoami > /dev/null; then
  echo "You must be logged into OpenShift to run this script"
  exit 1
fi

echo "Starting build of '${BUILD_CONFIG}' in project '${NAMESPACE}' ..."
oc start-build -n ${NAMESPACE} ${BUILD_CONFIG} --follow
LAST_VERSION=$(oc -n ${NAMESPACE} get bc ${BUILD_CONFIG} -o jsonpath='{.status.lastVersion}')
BUILD_ID="${BUILD_CONFIG}-${LAST_VERSION}"

BUILD_STATUS=
until [[ "${BUILD_STATUS}" == "Complete" ]]
do
    BUILD_STATUS=$(oc -n ${NAMESPACE} get build ${BUILD_ID} -o jsonpath='{.status.phase}')
    if [ "${BUILD_STATUS}" == "Failed" ]; then
      echo "Build ${BUILD_ID} has failed."
      exit 1
    fi    
    printf .
    sleep 3
done

echo "Build ${BUILD_ID} is complete."
exit 0
