#!/usr/bin/env bash
set -eu
set -o pipefail

PROJECT=$1
JENKINS_POD=$(oc get pod --no-headers| grep jenkins | cut -d ' ' -f1)

echo "getting logs from pod: ${JENKINS_POD}"
oc -n ${PROJECT} logs ${JENKINS_POD}
