#!/usr/bin/env bash
# Start build of given image and follows the output.
# After build finishes, we verify status is "Complete".

set -ue

function usage {
   printf "usage: %s [options]\n" $0
   printf "\t-h|--help\tPrints the usage\n"
   printf "\t-v|--verbose\tVerbose output\n"
   printf "\t-b|--build-config\tName of BuildConfig to start build for\n"
   printf "\t-n|--namespace\tNamespace (defaults to 'cd')\n"
}

NAMESPACE="cd"
BUILD_CONFIG=

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
  echo "You must be logged into OpenShift to start builds"
  exit 1
fi

echo "Starting build of '${BUILD_CONFIG}' in project '${NAMESPACE}' ..."
oc start-build -n ${NAMESPACE} ${BUILD_CONFIG} --follow
LAST_VERSION=$(oc -n ${NAMESPACE} get bc ${BUILD_CONFIG} -o jsonpath='{.status.lastVersion}')
BUILD_ID="${BUILD_CONFIG}-${LAST_VERSION}"

for i in 1 2 3; do
  BUILD_STATUS=$(oc -n ${NAMESPACE} get build ${BUILD_ID} -o jsonpath='{.status.phase}')
  if [ "${BUILD_STATUS}" == "Complete" ]; then
    echo "Build ${BUILD_ID} is complete."
    exit 0
  fi
  sleep 3
done
exit 1
