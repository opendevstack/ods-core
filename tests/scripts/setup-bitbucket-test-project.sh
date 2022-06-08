#!/usr/bin/env bash
set -ue
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
REPOSITORY=""

function usage {
    printf "Initialise a Bitbucket project with optional repository.\n\n"
    printf "This script will ask interactively for parameters by default.\n"
    printf "However, you can also pass them directly. Usage:\n\n"
    printf "\t-h|--help\t\tPrint usage\n"
    printf "\t-v|--verbose\t\tEnable verbose mode\n"
    printf "\t-i|--insecure\t\tAllow insecure server connections when using SSL\n"
    printf "\n"
    printf "\t-b|--bitbucket\t\tBitbucket URL, e.g. 'https://bitbucket.example.com'\n"
    printf "\t-u|--user\t\tBitbucket user\n"
    printf "\t-p|--password\t\tBitbucket password\n"
    printf "\t-t|--project\tName of Bitbucket project (defaults to '%s')\n" "${BITBUCKET_PROJECT}"
    printf "\t-p|--repository\t\tName of repository to create in project\n"
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


  *) echo_error "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

# Create bitbucket project if it does not exist yet
httpCode=$(curl ${INSECURE} -sS -o /dev/null -w "%{http_code}" \
    --user "${BITBUCKET_USER}:${BITBUCKET_PWD}" \
    "${BITBUCKET_URL}/rest/api/1.0/projects/${BITBUCKET_PROJECT}")
if [ "${httpCode}" == "404" ]; then
    echo_info "Creating project ${BITBUCKET_PROJECT} in Bitbucket"
    httpCodeCreate=$(curl ${INSECURE} -sS -o /dev/null -w "%{http_code}" -X POST \
        --user "${BITBUCKET_USER}:${BITBUCKET_PWD}" \
        -H "Content-Type: application/json" \
        -d "{\"key\":\"${BITBUCKET_PROJECT}\", \"name\": \"${BITBUCKET_PROJECT}\", \"description\": \"testproject\"}" \
        "${BITBUCKET_URL}/rest/api/1.0/projects")
    if [[ "${httpCodeCreate}" != "409" && "${httpCodeCreate}" != "201" ]]; then
        echo_error "Could not create bitbucket project ${BITBUCKET_PROJECT}, error: ${httpCodeCreate}"
        exit 1
    fi
elif [ "${httpCode}" == "200" ]; then
    echo_info "Found project ${BITBUCKET_PROJECT} in Bitbucket."
else
    echo_error "Could not determine state of project ${BITBUCKET_PROJECT} on Bitbucket, got ${httpCode}."
    exit 1
fi

# (Re-)Create repository if given
if [ -n "${REPOSITORY}" ]; then
    httpCode=$(curl ${INSECURE} -sS -o /dev/null -w "%{http_code}" \
        --user "${BITBUCKET_USER}:${BITBUCKET_PWD}" \
        "${BITBUCKET_URL}/rest/api/1.0/projects/${BITBUCKET_PROJECT}/repos/${REPOSITORY}")
    if [ "${httpCode}" == "200" ]; then
        echo "Found repository, will delete it"
        curl ${INSECURE} -sS -X DELETE \
            --user "${BITBUCKET_USER}:${BITBUCKET_PWD}" \
            "${BITBUCKET_URL}/rest/api/1.0/projects/${BITBUCKET_PROJECT}/repos/${REPOSITORY}"
    fi
    echo_info "Creating repository ${BITBUCKET_PROJECT}/${REPOSITORY} on Bitbucket."
    curl ${INSECURE} -sSf -X POST \
        --user "${BITBUCKET_USER}:${BITBUCKET_PWD}" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"${REPOSITORY}\", \"scmId\": \"git\", \"forkable\": true}" \
        "${BITBUCKET_URL}/rest/api/1.0/projects/${BITBUCKET_PROJECT}/repos"
fi

echo_done "Bitbucket project ${BITBUCKET_PROJECT} configured"
