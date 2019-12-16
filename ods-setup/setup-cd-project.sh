#!/usr/bin/env bash
set -xe

function usage() {

  exit
}
TAILOR=tailor

while [ "$1" != "" ]; do
  case $1 in
  -t | --tailor)
    shift
    TAILOR=$1
    ;;
  -h | --help)
    usage
    exit
    ;;
  --force)
    FORCE="--force"
    ;;
  *)
    usage
    exit 1
    ;;
  esac
  shift
done

NAMESPACE=cd

if ! oc whoami; then
  echo "You should be logged to run the script"
  exit 1
fi

if oc project ${NAMESPACE}; then
  echo "The project CD already exists"
  exit 1
fi

oc new-project ${NAMESPACE} --description="Base project holding the templates and the Repositoy Manager" --display-name="OpenDevStack"

# Allow system:authenticated group to pull images from CD namespace
oc adm policy add-cluster-role-to-group system:image-puller system:authenticated -n ${NAMESPACE}
oc adm policy add-role-to-group view system:authenticated -n ${NAMESPACE}

oc create sa deployment -n ${NAMESPACE}
oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:${NAMESPACE}:deployment

# create secrets for global cd_user
${TAILOR} update ${FORCE} --context-dir=${BASH_SOURCE%/*}/ocp-config/cd-user --non-interactive
