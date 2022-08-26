#!/usr/bin/env bash

set -euo pipefail

ME="$(basename ${0})"
echo " "

# Initialize variables
HOURS_LEFT=0
HOURS_ATLASSIAN_CAN_BE_UP=3
FORCE_RESTART="false";
ASSUME_JUST_RESTARTED="false";
LAST_RESTART_FILE_REGISTRY="/tmp/atlassian-suite-restarts-registry.log"
DEPLOY_SCRIPT="/home/openshift/opendevstack/ods-core/ods-devenv/scripts/deploy.sh"

function usage() {
    echo " "
    echo "${ME}: usage: ${ME} [--hours X] "
    echo "${ME}: example: ${ME} --hours-left 1 "
    echo " "
}

function initializeLastRestartFileRegistry() {
    if [ ! -f ${LAST_RESTART_FILE_REGISTRY} ]; then
        touch ${LAST_RESTART_FILE_REGISTRY}
        chmod 777 ${LAST_RESTART_FILE_REGISTRY}
    fi
}

function setCurrenTimeIfAssumeJustRestarted() {
    local just_restarted=${0-"false"}
    local date_string="$(date +'%Y%m%d_%H%M%S')"
    local reason="none"

    if [ "true" == "${ASSUME_JUST_RESTARTED}" ] || [ "true" == "${just_restarted}" ]; then
        if [ "true" == "${ASSUME_JUST_RESTARTED}" ]; then
            echo "${ME}: Setting current time to registry because assuming we just restarted the atlassian stack... "
            reason="assuming just restarted"
        else
            echo "${ME}: Setting current time to registry because we just restarted the atlassian stack... "
            reason="just restarted"
        fi
        echo "${date_string} ${reason}" >> ${LAST_RESTART_FILE_REGISTRY}
    fi
}

function checkIfWeStillHaveTime() {
    local FOUND=""
    local MAX_HOURS_SINCE_LAST_UPDATE=$((HOURS_ATLASSIAN_CAN_BE_UP - HOURS_LEFT))
    echo "MAX_HOURS_SINCE_LAST_UPDATE=${MAX_HOURS_SINCE_LAST_UPDATE} (${HOURS_ATLASSIAN_CAN_BE_UP} - ${HOURS_LEFT})"
    
    if [ "false" == ${FORCE_RESTART} ]; then
        FOUND=find ${LAST_RESTART_FILE_REGISTRY} -mtime ${MAX_HOURS_SINCE_LAST_UPDATE}
        echo "${ME}: FOUND: ${FOUND}"
    fi

    if [ -z "${FOUND}" ] || [ "" == "${FOUND}" ]; then
        echo "Restarting because file was not modified in last ${MAX_HOURS_SINCE_LAST_UPDATE}h."
        ${DEPLOY_SCRIPT} --target restart_atlassian_suite
    else
        echo "Not restarting because the atlassian stack was up less than ${HOURS_LEFT}h."
    fi

}

while [[ "$#" -gt 0 ]]; do
    case $1 in

    -v|--verbose) set -x;;

    -h|--help) usage; exit 0;;

    --hours-left) HOURS_LEFT="$2"; echo "Hours until license expires: $HOURS_LEFT"; shift;;

    --assume-just-restarted) ASSUME_JUST_RESTARTED="true";;

    --force-restart) FORCE_RESTART="true";;

  *) echo_error "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

if [ 0 -eq ]; then
    usage
    echo " "
    echo "${ME}: Please provide the amount of hours you can wait for the stack to restart."
    echo " "
    exit 1
fi

initializeLastRestartFileRegistry
setCurrenTimeIfAssumeJustRestarted
checkIfWeStillHaveTime

echo " "
exit 0
