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
IMAGE=
IMAGE_TAG=
NAMESPACE=
TARGET_STREAM=

function usage {
    printf "Import dockerhub image/tags.\n\n"
    printf "This script will ask interactively for parameters by default.\n"
    printf "However, you can also pass them directly. Usage:\n\n"
    printf "\t-h|--help\t\tPrint usage\n"
    printf "\t-v|--verbose\t\tEnable verbose mode\n"
    printf "\t-n|--namespace\t\tNamespace, e.g. 'ods'\n"
    printf "\t-i|--image\t\tImage, e.g. 'ods-provisioning-app'\n"
    printf "\t-t|--image-tag\t\tImagetag, e.g. '2.x'\n"
    printf "\t-s|--target-stream\t\tTarget image, e.g. 'ods-provisioning-app'\n"
}

while [[ "$#" -gt 0 ]]; do
    case $1 in

    -v|--verbose) set -x;;

    -h|--help) usage; exit 0;;

    -n|--namespace) NAMESPACE="$2"; shift;;
    -n=*|--namespace=*) NAMESPACE="${1#*=}";;

    -i|--image) IMAGE="$2"; shift;;
    -i=*|--image=*) IMAGE="${1#*=}";;

    -t|--image-tag) IMAGE_TAG="$2"; shift;;
    -t=*|--image-tag=*) IMAGE_TAG="${1#*=}";;

    -s|--target-stream) TARGET_STREAM="$2"; shift;;
    -s=*|--target-stream=*) TARGET_STREAM="${1#*=}";;

    *) echo_error "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

if [ -z "${NAMESPACE}" ]; then
    odsprojectname=
    if [ -f "${ODS_CORE_DIR}/../ods-configuration/ods-core.env" ]; then
        echo_info "Configuration located"
        odsprojectname=$(grep ODS_NAMESPACE "${ODS_CORE_DIR}/../ods-configuration/ods-core.env" | cut -d "=" -f 2-)
    fi
    read -r -e -p "Enter ods central namespace [${odsprojectname}]: " input
    if [[ -z "${input}" || $(echo -n $input | wc -m) == 0 ]]; then
    	NAMESPACE=$odsprojectname
        echo_info "Setting namespace to ${odsprojectname}"
    else
        NAMESPACE=${input:-""}
    fi
fi

if ! oc project ${NAMESPACE} -q; then
    echo_error "OCP Project ${NAMESPACE} does NOT exist"
    exit 1
fi

if [ -z "${IMAGE}" ]; then
    read -r -e -p "Enter image name: " input
    if [[ -z "${input}" || $(echo -n $input | wc -m) == 0 ]]; then
        echo_error "Image name 'image' is mandatory, aborting without it"
        exit 1
    else
        IMAGE=${input:-""}
    fi
fi

if [ -z "${TARGET_STREAM}" ]; then
    read -r -e -p "Enter target image stream name [${IMAGE}]: " input
    if [[ -z "${input}" || $(echo -n $input | wc -m) == 0 ]]; then
        TARGET_STREAM=$IMAGE
        echo_info "Target image not set, defaulting to source: $IMAGE"
    else
        TARGET_STREAM=${input:-""}
    fi
fi

if ! oc -n ${NAMESPACE} get is ${TARGET_STREAM} >/dev/null; then
	echo_error "Target image stream ${TARGET_STREAM} does not exist in project ${NAMESPACE}. Did you run 'tailor apply'?"
	exit 1
fi

if [ -z "${IMAGE_TAG}" ]; then
    imageversion=
    if [ -f "${ODS_CORE_DIR}/../ods-configuration/ods-core.env" ]; then
        echo_info "Configuration located"
        imageversion=$(grep ODS_IMAGE_TAG "${ODS_CORE_DIR}/../ods-configuration/ods-core.env" | cut -d "=" -f 2-)
    fi
    read -r -e -p "Enter image version [${imageversion}]: " input
    if [[ -z "${input}" || $(echo -n $input | wc -m) == 0 ]]; then
        IMAGE_TAG=${imageversion}
        echo_info "Imagetag not set, setting to: $imageversion"
    else
        IMAGE_TAG=${input:-""}
    fi
fi

TAG_SOURCE=${ODS_AT_DOCKERHUB}/${IMAGE}:${IMAGE_TAG}
TAG_TARGET=${NAMESPACE}/${TARGET_STREAM}:${IMAGE_TAG}

echo_info "importing remote image ${TAG_SOURCE} into local ${TAG_TARGET}"

# this is an async call, so we wait 5 secs and then get the tag, which will fail
# in case errors happened
oc tag ${TAG_SOURCE} ${TAG_TARGET} --scheduled

sleep 5

if ! oc -n ${NAMESPACE} get istag ${TARGET_STREAM}:${IMAGE_TAG} &> /dev/null; then
	echo_error "Could not import tag - please check image stream logs '${TAG_TARGET}'"
	exit 1
fi

echo_done "Remote image ${TAG_SOURCE} imported into ${TAG_TARGET}"
