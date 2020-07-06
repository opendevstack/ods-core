#!/usr/bin/env bash

LOG_URL=$(oc get build $1 -o json | jq '.metadata.annotations."openshift.io/jenkins-log-url"' | sed 's/"//g' )
curl ${LOG_URL} --header "Authorization: Bearer $(oc get sa/builder --template='{{range .secrets}}{{ .name }} {{end}}' | xargs -n 1 oc get secret --template='{{ if .data.token }}{{ .data.token }}{{end}}' | head -n 1 | base64 -d -)" -k
