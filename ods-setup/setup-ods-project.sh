#!/usr/bin/env bash

# Create the namespace for holding all ODS resources

set -ue

function usage {
   printf "usage: %s [options]\n" $0
   printf "\t--force\tIgnores warnings and error with tailor --force\n"
   printf "\t-h|--help\tPrints the usage\n"
   printf "\t-v|--verbose\tVerbose output\n"
   printf "\t-t|--tailor\tChanges the executable of tailor. Default: tailor\n"
   printf "\t-n|--namespace\tChanges the default OpenDevStack namespace where all resources will be created. Default: cd\n"

}
TAILOR="tailor"
NAMESPACE="cd"

while [[ "$#" -gt 0 ]]; do case $1 in

   -v|--verbose) set -x;;

   --force) FORCE="--force"; ;;

   -h|--help) usage; exit 0;;

   -t=*|--tailor=*) TAILOR="${1#*=}";;
   -t|--tailor) TAILOR="$2"; shift;;

   -n=*|--namespace=*) NAMESPACE="${1#*=}";;
   -n|--namespace) NAMESPACE="$2"; shift;;

   *) echo "Unknown parameter passed: $1"; usage; exit 1;;
 esac; shift; done

if ! oc whoami; then
  echo "You should be logged to run the script"
  exit 1
fi

if oc project ${NAMESPACE}; then
  echo "The project '${NAMESPACE}' already exists"
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
