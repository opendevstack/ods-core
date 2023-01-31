#!/usr/bin/env bash
set -eu

# This script sets up a ${PROJECT_ID}-cd/jenkins-master and the associated
# webhook proxy for the project you are creating.

# As this script is executed within the context of Jenkins, which has some
# env vars exposed (via the DeploymentConfig, but also from inside the image).
# It might be surprising to have them alter what the script does without seeing
# them passed/set in the Jenkinsfile_createBuildBot. That's why we reset all env vars here
# and require them to be passed as parameters to the script.

TAILOR="tailor"
ODS_NAMESPACE="ods"
ODS_IMAGE_TAG="latest"
ODS_BITBUCKET_PROJECT="opendevstack"
PROJECT_ID=""
CD_USER_TYPE=""
CD_USER_ID_B64=""
PIPELINE_TRIGGER_SECRET_B64=""
TAILOR_VERBOSE=""
TAILOR_NON_INTERACTIVE=""

function usage {
  printf "usage: %s [options]\n" "$0"
  printf "\t-h|--help\t\t\tPrints the usage\n"
  printf "\t-v|--verbose\t\t\tVerbose output\n"
  printf "\t-t|--tailor\t\t\tChanges the executable of tailor. Default: %s\n" "${TAILOR}"
  printf "\t-p|--project\t\t\tProject ID\n"
  printf "\t--ods-namespace\t\t\tThe namespace where all ODS resources reside. Default: %s\n" "${ODS_NAMESPACE}"
  printf "\t--ods-image-tag\t\t\tThe image tag to use. Default: %s\n" "${ODS_IMAGE_TAG}"
  printf "\t--ods-bitbucket-project\t\t\tThe Bitbucket project to use. Default: %s\n" "${ODS_BITBUCKET_PROJECT}"
  printf "\t--pipeline-trigger-secret-b64\tTrigger secret for pipelines (base64 encoded)\n"
  printf "\t--cd-user-type\t\t\tWhether CD user is general or project specific\n"
  printf "\t--cd-user-id-b64\t\tName of CD user (base64 encoded)\n"
}

while [[ "$#" -gt 0 ]]; do case $1 in
  -v|--verbose) TAILOR_VERBOSE="-v"; set -x;;

  --non-interactive) TAILOR_NON_INTERACTIVE="--non-interactive";;

  -h|--help) usage; exit 0;;

  -t=*|--tailor=*) TAILOR="${1#*=}";;
  -t|--tailor) TAILOR="$2"; shift;;

  -p=*|--project=*) PROJECT_ID="${1#*=}";;
  -p|--project)     PROJECT_ID="$2"; shift;;

  --ods-namespace=*) ODS_NAMESPACE="${1#*=}";;
  --ods-namespace)   ODS_NAMESPACE="$2"; shift;;

  --ods-image-tag=*) ODS_IMAGE_TAG="${1#*=}";;
  --ods-image-tag)   ODS_IMAGE_TAG="$2"; shift;;

  --ods-bitbucket-project=*) ODS_BITBUCKET_PROJECT="${1#*=}";;
  --ods-bitbucket-project)   ODS_BITBUCKET_PROJECT="$2"; shift;;

  --pipeline-trigger-secret-b64=*) PIPELINE_TRIGGER_SECRET_B64="${1#*=}";;
  --pipeline-trigger-secret-b64)   PIPELINE_TRIGGER_SECRET_B64="$2"; shift;;

  --cd-user-type=*) CD_USER_TYPE="${1#*=}";;
  --cd-user-type)   CD_USER_TYPE="$2"; shift;;

  --cd-user-id-b64=*) CD_USER_ID_B64="${1#*=}";;
  --cd-user-id-b64)   CD_USER_ID_B64="$2"; shift;;

   *) echo "Unknown parameter passed: $1"; usage; exit 1;;
esac; shift; done

if [ -z "${PROJECT_ID}" ]; then
  echo "--project is missing, but required"; usage
  exit 1
else
  echo "--project=${PROJECT_ID}"
fi

if [ -z "${PIPELINE_TRIGGER_SECRET_B64}" ]; then
  echo "--pipeline-trigger-secret-b64 is missing, but required"; usage
  exit 1
else
  echo "--pipeline-trigger-secret-b64=${PIPELINE_TRIGGER_SECRET_B64}"
fi

if [ -z "${CD_USER_TYPE}" ]; then
  echo "--cd-user-type is missing, but required"; usage
  exit 1
else
  echo "--cd-user-type=${CD_USER_TYPE}"
fi

if [ -z "${CD_USER_ID_B64}" ]; then
  echo "--cd-user-id-b64 is missing, but required"; usage
  exit 1
else
  echo "--cd-user-id-b64=${CD_USER_ID_B64}"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ODS_CORE_DIR=${SCRIPT_DIR%/*}

echo "Tailor version: $(${TAILOR} version)"

cdUserPwdParam=""
if [ "${CD_USER_TYPE}" != "general" ]; then
  base64Pwd=$(echo -n "changeme" | base64)
  cdUserPwdParam="--param=CD_USER_PWD_B64=${base64Pwd}"
fi

cd "${ODS_CORE_DIR}/jenkins/ocp-config/deploy"

${TAILOR} ${TAILOR_VERBOSE} ${TAILOR_NON_INTERACTIVE} apply \
  "--namespace=${PROJECT_ID}-cd" \
  "--param=PIPELINE_TRIGGER_SECRET_B64=${PIPELINE_TRIGGER_SECRET_B64}" \
  "--param=PROJECT=${PROJECT_ID}" \
  "--param=CD_USER_ID_B64=${CD_USER_ID_B64}" \
  "--param=ODS_NAMESPACE=${ODS_NAMESPACE}" \
  "--param=ODS_IMAGE_TAG=${ODS_IMAGE_TAG}" \
  "--param=ODS_BITBUCKET_PROJECT=${ODS_BITBUCKET_PROJECT}" \
  "${cdUserPwdParam}" \
  --selector "template=ods-jenkins-template"
