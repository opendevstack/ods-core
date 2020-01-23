#!/usr/bin/env bash

#Builds all jenkins-master jenkins-slave-base and webhook-proxy

set -ue

function usage {
   printf "usage: %s [options]\n" $0
   printf "\t--force\tIgnores warnings and error with tailor --force\n"
   printf "\t-h|--help\tPrints the usage\n"
   printf "\t-v|--verbose\tVerbose output\n"
   printf "\t-t|--tailor\tChanges the executable of tailor. Default: tailor\n"
   printf "\t-n|--namespace\tChanges the default OpenDevStack namespace where all resources will be created. Default: cd\n"
   printf "\t-r|--ods-base-repository\tODS base repository. Overrides default in settings file\n"
   printf "\t-b|--ods-ref\tODS reference in repository. Overrides default in settings file\n"

}
TAILOR="tailor"
NAMESPACE="cd"
REPOSITORY=""
REF=""
while [[ "$#" -gt 0 ]]; do case $1 in

   -v|--verbose) set -x;;

   --force) FORCE="--force"; ;;

   -h|--help) usage; exit 0;;

   -t=*|--tailor=*) TAILOR="${1#*=}";;
   -t|--tailor) TAILOR="$2"; shift;;

   -n=*|--namespace=*) NAMESPACE="${1#*=}";;
   -n|--namespace) NAMESPACE="$2"; shift;;

   -r=*|--ods-base-repository=*) REPOSITORY="${1#*=}";;
   -r|--ods-base-repository) REPOSITORY="$2"; shift;;

   -b=*|--ods-ref=*) REF="${1#*=}";;
   -b|--ods-ref) REF="$2"; shift;;

   *) echo "Unknown parameter passed: $1"; usage; exit 1;;
 esac; shift; done

if ! oc whoami; then
  echo "You should be logged into OpenShift to run the script"
  exit 1
fi

if ! oc project ${NAMESPACE}; then
  echo "The project '${NAMESPACE}' does not exist. Please setup the project using 'setup-ods-project.sh'"
  exit 1
fi

echo "Applying Tailorfile to project '${NAMESPACE}'"

if [ ! -z "${REF}" ]; then
REF="--param=ODS_GIT_REF=${REF}"
fi

if [ ! -z "${REPOSITORY}" ]; then
REPOSITORY="--param=REPO_BASE=${REPOSITORY}"
fi

${TAILOR} update ${FORCE} --context-dir=${BASH_SOURCE%/*}/../jenkins/ocp-config --non-interactive -n ${NAMESPACE} ${REF} ${REPOSITORY}

echo "Start Jenkins Builds"
oc start-build -n ${NAMESPACE} jenkins-master --follow
sleep 3
STATUS=$(oc get build jenkins-master-1 -o jsonpath='{.status.phase}')
if [ "${STATUS}" != "Complete" ]; then
  echo "'oc start-build -n ${NAMESPACE}' jenkins-master did not complete successfully (${STATUS})"
  exit 1
fi
oc start-build -n ${NAMESPACE} jenkins-slave-base --follow
sleep 3
STATUS=$(oc get build jenkins-slave-base-1 -o jsonpath='{.status.phase}')
if [ "${STATUS}" != "Complete" ]; then
  echo "'oc start-build -n ${NAMESPACE}' jenkins-slave-base did not complete successfully (${STATUS})"
  exit 1
fi
oc start-build -n ${NAMESPACE} jenkins-webhook-proxy --follow
sleep 3
STATUS=$(oc get build jenkins-webhook-proxy-1 -o jsonpath='{.status.phase}')
if [ "${STATUS}" != "Complete" ]; then
  echo "'oc start-build -n ${NAMESPACE}' jenkins-webhook-proxy did not complete successfully (${STATUS})"
  exit 1
fi
