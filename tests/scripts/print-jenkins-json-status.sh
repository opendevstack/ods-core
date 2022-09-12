#!/usr/bin/env bash
set -eu
set -o pipefail

OC_ERROR="false"
oc get build $1 -n $2 \
    -ojsonpath='{.metadata.annotations.openshift\.io/jenkins-status-json}' \
    | jq '[.stages[] | {stage: .name, status: .status}]' || OC_ERROR="true"

if [ "false" == "${OC_ERROR}" ]; then
    echo " "
    echo "ERROR: Could not get oc build status named $1 in namespace $2 !!! "
    echo " "
fi

