#!/usr/bin/env bash
set -eu

# This script sets up a ${PROJECT_ID}-cd/jenkins-master and the associated webhook proxy for the project you are creating.

TAILOR="tailor"
VERBOSE=false
STATUS=false

function usage {
   printf "usage: %s [options]\n", $0
   printf "\t--status\tExecutes tailor status\n"
   printf "\t-h|--help\tPrints the usage\n"
   printf "\t-v|--verbose\tVerbose output\n"
   printf "\t-t|--tailor\tChanges the executable of tailor. Default: tailor\n"
   printf "\tods-namespace\tThe namespace where all ODS resources reside. Default: cd\n"

}

ODS_NAMESPACE="cd"

while [[ "$#" -gt 0 ]]; do case $1 in
   --status) STATUS=true;;

   -v|--verbose) VERBOSE=true; set -x;;

   -h|--help) usage; exit 0;;

   -t=*|--tailor=*) TAILOR="${1#*=}";;
   -t|--tailor) TAILOR="$2"; shift;;

   --ods-namespace=*) ODS_NAMESPACE="${1#*=}";;
   --ods-namespace)   ODS_NAMESPACE="$2"; shift;;

   *) echo "Unknown parameter passed: $1"; usage; exit 1;;
 esac; shift; done

echo "Current tailor version is: $(${TAILOR} version)"

if $VERBOSE; then
  tailor_verbose="-v"
else
  tailor_verbose=""
fi

if [ -z ${PROJECT_ID+x} ]; then
  echo "PROJECT_ID is unset, but required"
  exit 1
else echo "PROJECT_ID=${PROJECT_ID}"; fi

if $STATUS; then
  echo "NOTE: Invoked with --status:  will use tailor status instead of tailor update."
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ODS_CORE_DIR=${SCRIPT_DIR%/*}

tailor_update_in_dir() {
  local dir="$1"
  shift
  if [ ${STATUS} = "true" ]; then
    cd "$dir" && ${TAILOR} $tailor_verbose status "$@"
  else
    cd "$dir" && ${TAILOR} $tailor_verbose --non-interactive update "$@"
  fi
}

cdUserPwdParam=""
if [ "${CD_USER_TYPE}" != "general" ]; then
  base64Pwd=$(echo -n "changeme" | base64)
  cdUserPwdParam="--param=CD_USER_PWD_B64=${base64Pwd}"
fi



tailor_update_in_dir "${ODS_CORE_DIR}/jenkins/ocp-config/deploy" \
  "--namespace=${PROJECT_ID}-cd" \
  "--param=PIPELINE_TRIGGER_SECRET_B64=${PIPELINE_TRIGGER_SECRET}" \
  "--param=PROJECT=${PROJECT_ID}" \
  "--param=CD_USER_ID_B64=${CD_USER_ID_B64}" \
  "--param=NAMESPACE=${ODS_NAMESPACE}" \
  $cdUserPwdParam \
  --selector "template=ods-jenkins-template"
