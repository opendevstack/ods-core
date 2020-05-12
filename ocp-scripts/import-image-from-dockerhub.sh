#!/usr/bin/env bash
set -ue

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ODS_CORE_DIR=${SCRIPT_DIR%/*}

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

ODS_AT_DOCKERHUB=docker.io/opendevstackorg
IMAGE_NAME=
IMAGE_VERSION=
NAMESPACE=ods
TARGET_IMAGE_STREAM=

function usage {
    printf "Import dockerhub image/tags.\n\n"
    printf "This script will ask interactively for parameters by default.\n"
    printf "However, you can also pass them directly. Usage:\n\n"
    printf "\t-h|--help\t\tPrint usage\n"
    printf "\t-v|--verbose\t\tEnable verbose mode\n"
    printf "\t-on|--namespace\t\tNamespace, e.g. 'ods'\n"
    printf "\t-in|--imagename\t\tImagename, e.g. 'ods-provisioning-app'\n"
    printf "\t-it|--targetimagestream\t\tTargetImageName, e.g. 'ods-provisioning-app'\n"
    printf "\t-iv|--imageversion\t\tImageversion, e.g. '2.x'\n"
}

while [[ "$#" -gt 0 ]]; do
    case $1 in

    -v|--verbose) set -x;;

    -h|--help) usage; exit 0;;

    -on|--namespace) NAMESPACE="$2"; shift;;
    -on=*|--namespace=*) NAMESPACE="${1#*=}";;

    -in|--imagename) IMAGE_NAME="$2"; shift;;
    -in=*|--imagename=*) IMAGE_NAME="${1#*=}";;

    -iv|--imageversion) IMAGE_VERSION="$2"; shift;;
    -iv=*|--imageversion=*) IMAGE_VERSION="${1#*=}";;

    -it|--targetimagestream) TARGET_IMAGE_STREAM="$2"; shift;;
    -it=*|--targetimagestream=*) TARGET_IMAGE_STREAM="${1#*=}";;

    *) echo_error "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

if ! which jq >/dev/null; then
    echo_warn "Binary 'jq' (https://stedolan.github.io/jq/) is not in your PATH. This will make the script less comfortable to use."
    read -r -e -p "Continue anyway? [y/n] " input
    if [ "${input:-""}" != "y" ]; then
        exit 1
    fi
fi

if [ -z "${NAMESPACE}" ]; then
    odsprojectname="odsst-dev"
    if [ -f "${ODS_CORE_DIR}/../ods-configuration/ods-core.env" ]; then
        echo_info "Configuration located"
        odsprojectname=$(grep NAMESPACE "${ODS_CORE_DIR}/../ods-configuration/ods-core.env" | cut -d "=" -f 2-)
    fi
    read -r -e -p "Enter ods central namespace [${odsprojectname}]: " input
    if [[ -z "${input}" || $(echo -n $input | wc -m) == 0 ]]; then
        NAMESPACE=${odsprojectname}
    else
        NAMESPACE=${input:-""}
    fi
fi

if ! oc project ${NAMESPACE} -q; then
    echo_error "OCP Project ${NAMESPACE} does NOT exist"
    exit 1
fi

if [ -z "${IMAGE_NAME}" ]; then
    read -r -e -p "Enter image name: " input
    if [ -z "${input}" ]; then
        echo_error "Image name is mandatory, aborting without it"
        exit 1
    else
        IMAGE_NAME=${input:-""}
    fi
fi

if [ -z "${TARGET_IMAGE_STREAM}" ]; then
    read -r -e -p "Enter target image stream name: " input
    if [ -z "${input}" ]; then
        TARGET_IMAGE_STREAM=$IMAGE_NAME
        echo "Target not set, defaulting to source: $IMAGE_NAME"
    else
        TARGET_IMAGE_STREAM=${input:-""}
    fi
fi

if ! oc -n ${NAMESPACE} get is ${TARGET_IMAGE_STREAM} >/dev/null; then
	echo_error "Target image stream ${TARGET_IMAGE_STREAM} does not exist in project ${NAMESPACE}. Did you run 'tailor apply'?"
	exit 1
fi

if [ -z "${IMAGE_VERSION}" ]; then
    imageversion="latest"
    if [ -f "${ODS_CORE_DIR}/../ods-configuration/ods-core.env" ]; then
        echo_info "Configuration located"
        imageversion=$(grep ODS_IMAGE_TAG "${ODS_CORE_DIR}/../ods-configuration/ods-core.env" | cut -d "=" -f 2-)
    fi
    read -r -e -p "Enter image version [${imageversion}]: " input
    if [ -z "${input}" ]; then
        IMAGE_VERSION=${imageversion}
    else
        IMAGE_VERSION=${input:-""}
    fi
fi

TAG_SOURCE=${ODS_AT_DOCKERHUB}/${IMAGE_NAME}:${IMAGE_VERSION}
TAG_TARGET=${NAMESPACE}/${TARGET_IMAGE_STREAM}:${IMAGE_VERSION}

echo_info "importing remote image ${TAG_SOURCE} into local ${TAG_TARGET}"

# tag directly - this should fail after a couple seconds, so we can verify
oc tag ${TAG_SOURCE} ${TAG_TARGET} --scheduled

sleep 5

if ! oc -n ${NAMESPACE} get istag ${TARGET_IMAGE_STREAM}:${IMAGE_VERSION} &> /dev/null; then
	echo_error "Could not import tag - please check image stream logs '${TAG_TARGET}'"
	exit 1
fi

echo_done "Remote image ${TAG_SOURCE} imported into ${TAG_TARGET}"
