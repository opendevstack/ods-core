#!/usr/bin/env bash
# This script can be used to store the token of a serviceaccount with rights
# to a deployment project in a secret, and share that secret with Jenkins.
# This script would typically be run by a project admin.
set -eu

usage() {
    echo "USAGE: $0 -p <project, e.g. foo-cd> -s <secret-name, e.g. foo-prod> -n <sa-name, e.g. robot> -t <sa-token, e.g. ZXlKaGJHY2lPaUpT...>"
}

while [[ "$#" > 0 ]]; do case $1 in
  -s=*|--secret-name=*) secretName="${1#*=}";;
  -s|--secret-name) secretName="$2"; shift;;

  -p=*|--project=*) project="${1#*=}";;
  -p|--project) project="$2"; shift;;

  -n=*|--sa-name=*) saName="${1#*=}";;
  -n|--sa-name) saName="$2"; shift;;

  -t=*|--sa-token=*) saToken="${1#*=}";;
  -t|--sa-token) saToken="$2"; shift;;

  *) echo "Unknown parameter passed: $1"; usage; exit 1;;
esac; shift; done

if [ -z ${project+x} ]; then
    echo "ERROR: param --project is required."; usage; exit 1;
elif [ -z ${secretName+x} ]; then
    echo "ERROR: param --secret-name is required."; usage; exit 1;
elif [ -z ${saName+x} ]; then
    echo "ERROR: param --sa-name is required."; usage; exit 1;
elif [ -z ${saToken+x} ]; then
    echo "ERROR: param --sa-token is required."; usage; exit 1;
else
    echo ""
    echo "Creating new secret ${project}:${secretName} for serviceaccount ${saName}."
fi

oc -n ${project} create secret generic ${secretName} --from-literal=password=${saToken} --from-literal=username=${saName} --type="kubernetes.io/basic-auth"
oc -n ${project} label secret ${secretName} credential.sync.jenkins.openshift.io=true

echo ""
echo "Secret ${project}:${secretName} created and synced with Jenkins."
echo ""
