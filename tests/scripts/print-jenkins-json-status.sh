#!/usr/bin/env bash
set -eu
set -o pipefail

oc get build $1 -n $2 \
    -ojsonpath='{.metadata.annotations.openshift\.io/jenkins-status-json}' \
    | jq '[.stages[] | {stage: .name, status: .status}]'
