#!/usr/bin/env bash
# push-local-repos.sh pushes local repositories to Bitbucket.

set -ue

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ODS_CORE_DIR=${SCRIPT_DIR%/*}
ODS_UMBRELLA_DIR=${ODS_CORE_DIR%/*}
ODS_CONFIGURATION_DIR="${ODS_UMBRELLA_DIR}/ods-configuration"

BITBUCKET_URL=""
ODS_GIT_REF=""
ODS_BITBUCKET_PROJECT=""
REPOS="ods-core, ods-quickstarters, ods-jenkins-shared-library, ods-document-generation-templates"

function usage {
    printf "Push local OpenDevStack repositories to Bitbucket.\n\n"
    printf "This script will read all parameters from ods-configuration.\n"
    printf "However, you can also pass them directly.\n\n"
    printf "Usage:\n\n"
    printf "\t-h|--help\t\t\tPrint usage\n\n"
    printf "\t-v|--verbose\t\t\tEnable verbose mode\n\n"
    printf "\t-b|--bitbucket-url\t\tBitbucket URL, e.g. 'https://bitbucket.example.com'\n\n"
    printf "\t-p|--bitbucket-ods-project\tBitbucket ODS project, e.g. 'OPENDEVSTACK'\n\n"
    printf "\t-r|--repos\t\tRepositories to handle (comma-separated)\n\t\t\t\tDefaults to: %s\n\n" "${REPOS}"
    printf "\t-g|--ods-git-ref\t\tGit ref, e.g. 'v4.0.0' or 'master'\n\n"
    printf "NOTE: Before you run this script, make sure to have at least Git 2.13 in your system.\n"
}

# https://github.com/koalaman/shellcheck/wiki/SC1090
# shellcheck source=/dev/null
source "${ODS_CORE_DIR}/scripts/colored-output.sh"

while [[ "$#" -gt 0 ]]; do
    case $1 in

    -v|--verbose) set -x;;

    -h|--help) usage; exit 0;;

    -b|--bitbucket-url) BITBUCKET_URL="$2"; shift;;
    -b=*|--bitbucket-url=*) BITBUCKET_URL="${1#*=}";;

    -p|--bitbucket-ods-project) ODS_BITBUCKET_PROJECT="$2"; shift;;
    -p=*|--bitbucket-ods-project=*) ODS_BITBUCKET_PROJECT="${1#*=}";;

    -g|--ods-git-ref) ODS_GIT_REF="$2"; shift;;
    -g=*|--ods-git-ref=*) ODS_GIT_REF="${1#*=}";;

    *) echo_error "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

if [ -z "${BITBUCKET_URL}" ] && [ -f "${ODS_CONFIGURATION_DIR}/ods-core.env" ]; then
    BITBUCKET_URL=$(${ODS_CORE_DIR}/scripts/get-config-param.sh BITBUCKET_URL)
fi
if [ -z "${BITBUCKET_URL}" ]; then
    echo_error "Bitbucket URL must not be empty."
    exit 1
fi

if [ -z "${ODS_BITBUCKET_PROJECT}" ] && [ -f "${ODS_CONFIGURATION_DIR}/ods-core.env" ]; then
    ODS_BITBUCKET_PROJECT=$(${ODS_CORE_DIR}/scripts/get-config-param.sh ODS_BITBUCKET_PROJECT)
fi
if [ -z "${ODS_BITBUCKET_PROJECT}" ]; then
    echo_error "Bitbucket ODS project must not be empty."
    exit 1
fi

if [ -z "${ODS_GIT_REF}" ] && [ -f "${ODS_CONFIGURATION_DIR}/ods-core.env" ]; then
    ODS_GIT_REF=$(${ODS_CORE_DIR}/scripts/get-config-param.sh ODS_GIT_REF)
fi
if [ -z "${ODS_GIT_REF}" ]; then
    echo_error "ODS Git ref must not be empty."
    exit 1
fi

cd "${ODS_UMBRELLA_DIR}"

# Ensure all repos exist and have proper remotes before we push anything.
for REPO in ${REPOS//,/ }; do
    if [ ! -d "${REPO}" ] ; then
        echo_error "Directory ${REPO} does not exist."
        exit 1
    fi

    cd "${REPO}"
    if ! git remote get-url origin &> /dev/null; then
        BITBUCKET_REPO="${BITBUCKET_URL}/scm/${ODS_BITBUCKET_PROJECT}/${REPO}.git"
        echo_info "Adding remote 'origin' (${BITBUCKET_REPO})."
        git remote add origin "${BITBUCKET_REPO}"
    fi
    cd - &> /dev/null
done

# Push ODS_GIT_REF of all repos.
for REPO in ${REPOS//,/ }; do
    echo_info "Pushing ${REPO} (${ODS_GIT_REF}) to Bitbucket."
    cd "${REPO}"
    git push -u origin "${ODS_GIT_REF}"
    echo_done "Pushed ${REPO} (${ODS_GIT_REF}) to Bitbucket."

    cd - &> /dev/null
    echo ""
done
