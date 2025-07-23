#!/usr/bin/env bash
set -e

COMPONENT_NAME="releasemanager"
COMPONENT_DESCRIPTION="Release Manager component"

function usage {
  printf "usage: %s [options]\n" "$0"
  printf "\t-h|--help\tPrints the usage\n"
  printf "\t-v|--verbose\tVerbose output\n"
  printf "\t-k|--project_key\tProject Key (case sensitive)\n"
  printf "\t-m|--marketplace_url\tMarketplace Url\n"
  printf "\t-u|--username\tUsername\n"
  printf "\t-p|--password\tPassword\n"
}

while [[ "$#" -gt 0 ]]; do case $1 in
  -v|--verbose) set -x;;

  -h|--help) usage; exit 0;;

  -k=*|--project_key=*) PROJECT_KEY="${1#*=}";;
  -k|--project_key)     PROJECT_KEY="$2"; shift;;

  -j=*|--mkt_url=*) MKT_BASE_URL="${1#*=}";;
  -j|--mkt_url)     MKT_BASE_URL="$2"; shift;;

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

if [ -z "${MKT_BASE_URL}" ]; then
  echo "MKT_BASE_URL is unset"; usage
  exit 1
else
	echo "MKT_BASE_URL=${MKT_BASE_URL}"
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
  "registerOnly": true,
  "params": {}
}
}
EOF
}

BASE64_CREDENTIALS=$(echo -n $BASIC_AUTH_USER:$BASIC_AUTH_PWD | base64)
CREATE_COMPONENT_ENDPOINT="${MKT_BASE_URL}/api/pub/v0/projects/${PROJECT_KEY}/components"
LOGIN_MKT_ENDPOINT="${MKT_BASE_URL}/api/pub/v0/user/login"

# Login in Marketplace Public API
RESPONSE=$(curl -s -X POST "${LOGIN_MKT_ENDPOINT}" \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic ${BASE64_CREDENTIALS}" \
  -d '{}')

# Get token from the response
TOKEN=$(echo "$RESPONSE" | jq -r '.token')

echo "Add component ${COMPONENT_NAME} for project ${PROJECT_KEY} in EDP Marketplace ${CREATE_COMPONENT_ENDPOINT}"

curl --silent \
    --header "Authorization: Bearer ${TOKEN}" \
    --header 'Accept: application/json' \
    --header 'Content-Type: application/json' \
    --url "${CREATE_COMPONENT_ENDPOINT}" \
    --data "$(generate_create_component_post_data)"