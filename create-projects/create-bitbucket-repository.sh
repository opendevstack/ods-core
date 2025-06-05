#!/usr/bin/env bash
set -e

function usage {
  printf "usage: %s [options]\n" "$0"
  printf "\t-h|--help\tPrints the usage\n"
  printf "\t-v|--verbose\tVerbose output\n"
  printf "\t-k|--project_key\tProject Key (case sensitive)\n"
  printf "\t-n|--repo_name\tRepository Name\n"
  printf "\t-b|--bitbucket_url\tBitbucket Url\n"
  printf "\t-u|--username\tUsername\n"
  printf "\t-p|--password\tPassword\n"
  printf "\t-ag|--admin_group\tAdmin Group\n"
  printf "\t-ug|--user_group\tUser Group\n"
}

while [[ "$#" -gt 0 ]]; do case $1 in
  -v|--verbose) set -x;;

  -h|--help) usage; exit 0;;

  -k=*|--project_key=*) PROJECT_KEY="${1#*=}";;
  -k|--project_key)     PROJECT_KEY="$2"; shift;;

  -n=*|--repo_name=*) REPO_NAME="${1#*=}";;
  -n|--repo_name)     REPO_NAME="$2"; shift;;

  -b=*|--bitbucket_url=*) BITBUCKET_URL="${1#*=}";;
  -b|--bitbucket_url)     BITBUCKET_URL="$2"; shift;;

  -u=*|--username=*) BASIC_AUTH_USER="${1#*=}";;
  -u|--username)     BASIC_AUTH_USER="$2"; shift;;

  -p=*|--password=*) BASIC_AUTH_PWD="${1#*=}";;
  -p|--password)     BASIC_AUTH_PWD="$2"; shift;;

  -ag=*|--admin_group=*) ADMIN_GROUP="${1#*=}";;
  -ag|--admin_group)     ADMIN_GROUP="$2"; shift;;

  -ug=*|--user_group=*) USER_GROUP="${1#*=}";;
  -ug|--user_group)     USER_GROUP="$2"; shift;;

   *) echo "Unknown parameter passed: $1"; usage; exit 1;;
esac; shift; done

# check required parameters
if [ -z "${PROJECT_KEY}" ]; then
  echo "PROJECT_KEY is unset"; usage
  exit 1
else
	echo "PROJECT_KEY=${PROJECT_KEY}"
fi

if [ -z "${REPO_NAME}" ]; then
  echo "REPO_NAME is unset"; usage
  exit 1
else
	echo "REPO_NAME=${REPO_NAME}"
fi

if [ -z "${BITBUCKET_URL}" ]; then
  echo "BITBUCKET_URL is unset"; usage
  exit 1
else
	echo "BITBUCKET_URL=${BITBUCKET_URL}"
fi

if [ -z "${BASIC_AUTH_USER}" ]; then
  echo "BASIC_AUTH_USER is unset"; usage
  exit 1
else
	echo "BASIC_AUTH_USER=${BASIC_AUTH_USER}"
fi

if [ -z "${BASIC_AUTH_PWD}" ]; then
  echo "BASIC_AUTH_PWD is unset"; usage
  exit 1
else
	echo "BASIC_AUTH_PWD=${BASIC_AUTH_PWD}"
fi

if [ -z "${ADMIN_GROUP}" ]; then
  echo "ADMIN_GROUP is unset"; usage
  exit 1
else
	echo "ADMIN_GROUP=${ADMIN_GROUP}"
fi

if [ -z "${USER_GROUP}" ]; then
  echo "USER_GROUP is unset"; usage
  exit 1
else
	echo "USER_GROUP=${USER_GROUP}"
fi

SCM_ID="git"
REPO_DESCRIPTION="Automatically created repository for project $PROJECT_KEY"

generate_create_repo_post_data()
{
  cat <<EOF
{
    "name" : "$REPO_NAME",
    "scmId" : "$SCM_ID",
    "forkable" : true,
    "description" : "$REPO_DESCRIPTION",
    "adminGroup" : "$ADMIN_GROUP",
    "userGroup" : "$USER_GROUP"
}
}
EOF
}

BASE64_CREDENTIALS=$(echo -n $BASIC_AUTH_USER:$BASIC_AUTH_PWD | base64)
CREATE_REPO_ENDPOINT="${BITBUCKET_URL}/rest/api/1.0/projects/${PROJECT_KEY}/repos"

echo "Create release manager repository ${REPO_NAME} for project ${PROJECT_KEY} in Bitbucket ${CREATE_REPO_ENDPOINT}"

curl --silent \
    --header "Authorization: Basic ${BASE64_CREDENTIALS}" \
    --header 'Accept: application/json' \
    --header 'Content-Type: application/json' \
    --url "${CREATE_REPO_ENDPOINT}" \
    --data "$(generate_create_repo_post_data)"



