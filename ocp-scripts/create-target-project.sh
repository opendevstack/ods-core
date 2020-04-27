#!/usr/bin/env bash
# This script can be used to create a new project, setup with serviceaccount
# an image-puller secret so that the orchestration pipeline can use it as a
# deploy target. This script would typically be run by a cluster admin.
set -eu

usage() {
    echo "USAGE: $0 -p <project, e.g. foo-prod> -s <source-cluster-registry-host, e.g. registry.example.openshift.com> -s <source-cluster-registry-token, e.g. ZXlKaGJHY2lPaUpT...>"
}

while [[ "$#" > 0 ]]; do case $1 in
  -p=*|--project=*) project="${1#*=}";;
  -p|--project) project="$2"; shift;;

  -s=*|--source-cluster-registry-host=*) sourceClusterRegistryHost="${1#*=}";;
  -s|--source-cluster-registry-host) sourceClusterRegistryHost="$2"; shift;;

  -t=*|--source-cluster-registry-token=*) sourceClusterRegistryToken="${1#*=}";;
  -t|--source-cluster-registry-token) sourceClusterRegistryToken="$2"; shift;;

  *) echo "Unknown parameter passed: $1"; usage; exit 1;;
esac; shift; done

if [ -z ${project+x} ]; then
    echo "ERROR: param --project is required."; usage; exit 1;
elif [ -z ${sourceClusterRegistryHost+x} ]; then
    echo "ERROR: param --source-cluster-registry-host is required."; usage; exit 1;
elif [ -z ${sourceClusterRegistryToken+x} ]; then
    echo "ERROR: param --source-cluster-registry-token is required."; usage; exit 1;
else
    echo ""
    echo "Creating new project ${project} with image-puller secret pointing to ${sourceClusterRegistryHost}."
fi

serviceaccountName="robot"
imagePullSecretName="mro-image-pull"

if ! oc whoami; then
  echo "You must be logged into OpenShift to run the script"
  exit 1
fi

echo ""
echo "Creating project ..."
oc new-project ${project}

echo ""
echo "Creating serviceaccount ..."
oc create sa ${serviceaccountName}
oc policy add-role-to-user admin system:serviceaccount:${project}:${serviceaccountName} -n ${project}

echo ""
echo "Creating image-puller secret ..."
oc -n ${project} create secret docker-registry ${imagePullSecretName} --docker-server=${sourceClusterRegistryHost} --docker-username=cd/cd-integration --docker-password=${sourceClusterRegistryToken} --docker-email=a@b.com
oc -n ${project} secrets link deployer ${imagePullSecretName} --for=pull
oc -n ${project} secrets link default ${imagePullSecretName} --for=pull

echo ""
echo "Token for serviceaccount ${project}:${serviceaccountName}:"
echo ""
oc -n ${project} get sa/${serviceaccountName} --template '{{range .secrets}}{{.name}},{{end}}' | tr ',' '\n' | while read secretName; do
    if [[ ${secretName} == ${serviceaccountName}-token-* ]];
    then
        encodedToken=$(oc -n ${project} get -ojsonpath='{.data.token}' secret ${secretName})
        decodedToken=$(echo -n "${encodedToken}" | base64 --decode)
        echo ${decodedToken}
    fi
done
echo ""
