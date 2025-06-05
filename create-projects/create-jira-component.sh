#!/usr/bin/env bash
set -e

COMPONENT_NAME="Technology-release-manager"
COMPONENT_DESCRIPTION="Technology component"

function usage {
  printf "usage: %s [options]\n" "$0"
  printf "\t-h|--help\tPrints the usage\n"
  printf "\t-v|--verbose\tVerbose output\n"
  printf "\t-k|--project_key\tProject Key (case sensitive)\n"
  printf "\t-j|--jira_url\tJira Url\n"
  printf "\t-u|--username\tUsername\n"
  printf "\t-p|--password\tPassword\n"
}

while [[ "$#" -gt 0 ]]; do case $1 in
  -v|--verbose) set -x;;

  -h|--help) usage; exit 0;;

  -k=*|--project_key=*) PROJECT_KEY="${1#*=}";;
  -k|--project_key)     PROJECT_KEY="$2"; shift;;

  -j=*|--jira_url=*) JIRA_BASE_URL="${1#*=}";;
  -j|--jira_url)     JIRA_BASE_URL="$2"; shift;;

  -u=*|--username=*) BASIC_AUTH_USER="${1#*=}";;
  -u|--username)     BASIC_AUTH_USER="$2"; shift;;

  -p=*|--password=*) BASIC_AUTH_PWD="${1#*=}";;
  -p|--password)     BASIC_AUTH_PWD="$2"; shift;;

   *) echo "Unknown parameter passed: $1"; usage; exit 1;;
esac; shift; done

# check required parameters
if [ -z "${PROJECT_KEY}" ]; then
  echo "PROJECT_KEY is unset"; usage
  exit 1
else
	echo "PROJECT_KEY=${PROJECT_KEY}"
fi

if [ -z "${JIRA_BASE_URL}" ]; then
  echo "JIRA_BASE_URL is unset"; usage
  exit 1
else
	echo "JIRA_BASE_URL=${JIRA_BASE_URL}"
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

generate_create_component_post_data()
{
  cat <<EOF
{
  "name": "${COMPONENT_NAME}",
  "project": "${PROJECT_KEY}",
  "description": "${COMPONENT_DESCRIPTION}"
}
}
EOF
}

BASE64_CREDENTIALS=$(echo -n $BASIC_AUTH_USER:$BASIC_AUTH_PWD | base64)
CREATE_COMPONENT_ENDPOINT="${JIRA_BASE_URL}/rest/api/2/component"

echo "Add Jira component ${COMPONENT_NAME} for project ${PROJECT_KEY} in jira ${CREATE_COMPONENT_ENDPOINT}"

curl --silent \
    --header "Authorization: Basic ${BASE64_CREDENTIALS}" \
    --header 'Accept: application/json' \
    --header 'Content-Type: application/json' \
    --url "${CREATE_COMPONENT_ENDPOINT}" \
    --data "$(generate_create_component_post_data)"

