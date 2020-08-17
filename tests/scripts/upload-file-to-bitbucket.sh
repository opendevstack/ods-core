#!/usr/bin/env bash
set -eu
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ODS_CONFIGURATION_DIR=../../../../ods-configuration

echo_done(){
    echo -e "\033[92mDONE\033[39m: $1"
}

echo_warn(){
    echo -e "\033[93mWARN\033[39m: $1"
}

echo_error(){
    echo -e "\033[31mERROR\033[39m: $1"
}

echo_info(){
    echo -e "\033[94mINFO\033[39m: $1"
}

BITBUCKET_URL=""
BITBUCKET_USER=""
BITBUCKET_PWD=""
BITBUCKET_PROJECT="unitt"
INSECURE=""
REPOSITORY=
BRANCH=master

function usage {
    printf "Initialise OpenDevStack Bitbucket project.\n\n"
    printf "This script will ask interactively for parameters by default.\n"
    printf "However, you can also pass them directly. Usage:\n\n"
    printf "\t-h|--help\t\tPrint usage\n"
    printf "\t-v|--verbose\t\tEnable verbose mode\n"
    printf "\t-i|--insecure\t\tAllow insecure server connections when using SSL\n"
    printf "\n"
    printf "\t-b|--bitbucket\t\tBitbucket URL, e.g. 'https://bitbucket.example.com'\n"
    printf "\t-u|--user\t\tBitbucket user\n"
    printf "\t-p|--password\t\tBitbucket password\n"
    printf "\t-t|--project\tName of OpenDevStack project (defaults to '%s')\n" "${BITBUCKET_PROJECT}"
}

while [[ "$#" -gt 0 ]]; do
    case $1 in

    -v|--verbose) set -x;;

    -h|--help) usage; exit 0;;

    -i|--insecure) INSECURE="--insecure";;

    -b|--bitbucket) BITBUCKET_URL="$2"; shift;;
    -b=*|--bitbucket=*) BITBUCKET_URL="${1#*=}";;

    -u|--user) BITBUCKET_USER="$2"; shift;;
    -u=*|--user=*) BITBUCKET_USER="${1#*=}";;

    -p|--password) BITBUCKET_PWD="$2"; shift;;
    -p=*|--password=*) BITBUCKET_PWD="${1#*=}";;

    -t|--project) BITBUCKET_PROJECT="$2"; shift;;
    -t=*|--project=*) BITBUCKET_PROJECT="${1#*=}";;

    -r|--repository) REPOSITORY="$2"; shift;;
    -r=*|--repository=*) REPOSITORY="${1#*=}";;

    -f|--file) FILE="$2"; shift;;
    -f=*|--file=*) FILE="${1#*=}";;

    -n|--filename) REPO_FILE="$2"; shift;;
    -n=*|--filename=*) REPO_FILE="${1#*=}";;

  *) echo_error "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

lastCommit=$(curl --insecure -sS \
    -u "${BITBUCKET_USER}:${BITBUCKET_PWD}" \
    "${BITBUCKET_URL}/rest/api/latest/projects/${BITBUCKET_PROJECT}/repos/${REPOSITORY}/commits" | jq .values[0].id | sed 's|\"||g')

echo "last commit: ${lastCommit}"

httpCode=$(curl --insecure -sS \
    -u "${BITBUCKET_USER}:${BITBUCKET_PWD}" \
    -X PUT \
    -F branch=$BRANCH \
    -F sourceCommitId=$lastCommit \
    -F "comment=ods test" \
    -F "content=@${FILE}" \
    -F filename=blob \
    "${BITBUCKET_URL}/rest/api/latest/projects/${BITBUCKET_PROJECT}/repos/${REPOSITORY}/browse/${REPO_FILE}" \
    -w "%{http_code}")

if [ $httpCode != "200" ]; then
    echo "An error occured during update of ${BITBUCKET_URL}/rest/api/latest/projects/${BITBUCKET_PROJECT}/repos/${REPOSITORY}/browse/${REPO_FILE} - error:$httpCode"
    exit 1
fi
