#!/usr/bin/env bash

JENKINS_BUILD_JSON_RAW=$(oc get build $1 -ojson | jq '.metadata.annotations."openshift.io/jenkins-status-json"' | sed -e 's|\\||g')
echo "${JENKINS_BUILD_JSON_RAW:1:${#JENKINS_BUILD_JSON_RAW}-2}" | jq '[.stages[] | {stage: .name, status: .status}]'
