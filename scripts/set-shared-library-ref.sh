#!/usr/bin/env bash
# The script checks if a Git ref named ODS_IMAGE_TAG exists in the
# ods-jenkins-shared-library repository in the Bitbucket project.
# If the Git ref does not exist, it is created, pointing to the
# Git ref identified by ODS_GIT_REF.
# If the Git ref does exist, it is verified to point to the Git ref
# identified by ODS_GIT_REF, and if it fails the test, the pointer is moved.

set -ue

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ODS_CORE_DIR=${SCRIPT_DIR%/*}
ODS_UMBRELLA_DIR=${ODS_CORE_DIR%/*}
ODS_CONFIGURATION_DIR="${ODS_UMBRELLA_DIR}/ods-configuration"

REPOSITORY="ods-jenkins-shared-library"
ODS_GIT_REF=""
ODS_IMAGE_TAG=""

function usage {
    printf "Set Git ref equal to ODS_IMAGE_TAG in %s.\n\n" "${REPOSITORY}"
    printf "This script will read all parameters from ods-configuration.\n"
    printf "However, you can also pass them directly.\n\n"
    printf "Usage:\n\n"
    printf "\t-h|--help\t\tPrint usage\n\n"
    printf "\t-v|--verbose\t\tEnable verbose mode\n\n"
    printf "\t-g|--ods-git-ref\tODS Git ref, e.g. 'v4.0.0' or 'master'\n\n"
    printf "\t-i|--ods-image-tag\tODS image tag, e.g. '4.x' or 'latest'\n\n"
}

# https://github.com/koalaman/shellcheck/wiki/SC1090
# shellcheck source=/dev/null
source "${ODS_CORE_DIR}/scripts/colored-output.sh"

while [[ "$#" -gt 0 ]]; do
    case $1 in

    -v|--verbose) set -x;;

    -h|--help) usage; exit 0;;

    -g|--ods-git-ref) ODS_GIT_REF="$2"; shift;;
    -g=*|--ods-git-ref=*) ODS_GIT_REF="${1#*=}";;

    -i|--ods-image-tag) ODS_IMAGE_TAG="$2"; shift;;
    -i=*|--ods-image-tag=*) ODS_IMAGE_TAG="${1#*=}";;

  *) echo_error "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

if [ -z "${ODS_GIT_REF}" ] && [ -f "${ODS_CONFIGURATION_DIR}/ods-core.env" ]; then
    ODS_GIT_REF=$(${ODS_CORE_DIR}/scripts/get-config-param.sh ODS_GIT_REF)
fi
if [ -z "${ODS_GIT_REF}" ]; then
    echo_error "ODS Git ref must not be empty."
    exit 1
fi

if [ -z "${ODS_IMAGE_TAG}" ] && [ -f "${ODS_CONFIGURATION_DIR}/ods-core.env" ]; then
    ODS_IMAGE_TAG=$(${ODS_CORE_DIR}/scripts/get-config-param.sh ODS_IMAGE_TAG)
fi
if [ -z "${ODS_IMAGE_TAG}" ]; then
    echo_error "ODS image tag must not be empty."
    exit 1
fi

cd "${ODS_UMBRELLA_DIR}/${REPOSITORY}"

git fetch origin

if ! git ls-remote --exit-code origin "${ODS_GIT_REF}" &>/dev/null; then
    echo_error "Could not find ref '${ODS_GIT_REF}' in ${REPOSITORY}."
    exit 1
fi
odsGitRefSha=$(git ls-remote origin "${ODS_GIT_REF}" | awk '{print $1}')
echo_info "Resolved ref '${ODS_GIT_REF}' to: ${odsGitRefSha}"
echo_info "Checking out ref '${ODS_GIT_REF}' ..."
git checkout "${ODS_GIT_REF}"

odsImageTagRefSha=""
setRef="n"
if ! git ls-remote --exit-code origin "${ODS_IMAGE_TAG}" &>/dev/null; then
    echo_info "Could not find ref '${ODS_IMAGE_TAG}' in ${REPOSITORY}. It will be created."
    setRef="y"
else
    odsImageTagRefSha=$(git ls-remote origin "${ODS_IMAGE_TAG}" | awk '{print $1}')
    echo_info "Resolved ref '${ODS_IMAGE_TAG}' to: ${odsImageTagRefSha}"
fi

if [ "$odsImageTagRefSha" != "$odsGitRefSha" ]; then
    echo_info "Ref '${ODS_IMAGE_TAG}' exists in ${REPOSITORY}, but does not point to the SHA referenced by '${ODS_GIT_REF}'. It will be updated."
    setRef="y"
fi

if [ "${setRef}" == "y" ]; then
    echo_info "Setting ref '${ODS_IMAGE_TAG}' to: ${odsGitRefSha} ..."
    localTmpBranch="ods_tmp_branch"
    if git show-ref --verify --quiet "refs/heads/${localTmpBranch}"; then
        git branch -D "${localTmpBranch}"
    fi
    git checkout -b "${localTmpBranch}"
    git reset --hard "${odsGitRefSha}"
    git push origin --force "${localTmpBranch}:${ODS_IMAGE_TAG}"
    git checkout "${ODS_GIT_REF}"
    git branch -D "${localTmpBranch}"
fi

echo_done "Ref '${ODS_IMAGE_TAG}' points to same commit as '${ODS_GIT_REF}'."
