#!/usr/bin/env bash
set -eu
set -o pipefail

JENKINS_LOG_FILE="jenkins-downloaded-log.txt"
JENKINS_SERVER_LOG_FILE="jenkins-server-log.txt"
WAIT_FOR_MANUAL_INTERVENTION="false"

echo " "
echo " "
echo " "
PROJECT=$1
BUILD_NAME=$2
BUILD_SEEMS_TO_BE_COMPLETE=${3:-"false"}
ME="$(basename $0)[${BUILD_NAME}]"
echo "${ME}: Project: ${PROJECT} BuildName: ${BUILD_NAME} BuildSeemsToBeComplete: ${BUILD_SEEMS_TO_BE_COMPLETE} "
echo " "

LOG_URL=$(oc -n ${PROJECT} get build ${BUILD_NAME} -o jsonpath='{.metadata.annotations.openshift\.io/jenkins-log-url}')
echo " "
echo "${ME}: Jenkins log url: ${LOG_URL}"
echo " "
TOKEN=$(oc -n ${PROJECT} get sa/jenkins --template='{{range .secrets}}{{ .name }} {{end}}' | xargs -n 1 oc -n ${PROJECT} get secret --template='{{ if .data.token }}{{ .data.token }}{{end}}' | head -n 1 | base64 -d -)

if [ -f ${JENKINS_LOG_FILE} ]; then
    rm -fv ${JENKINS_LOG_FILE} || echo "Problem removing existing log file (${JENKINS_LOG_FILE})."
fi

echo "${ME}: Retrieving logs from url: ${LOG_URL}"
curl --insecure -sSL --header "Authorization: Bearer ${TOKEN}" ${LOG_URL} > ${JENKINS_LOG_FILE} || \
    echo "${ME}: Error retrieving jenkins logs of job run in ${BUILD_NAME} with curl."

# | xargs -n 1 echo "${BUILD_NAME}: " || \
# echo "Error retrieving jenkins logs of job run in ${BUILD_NAME} with curl."

NO_JOB_LOGS="true"
echo " "
echo " "
# Appends current ${BUILD_NAME} to each log line. Improves readability.
while read -r line; do
    if [ ! -z "$line" ] && [ "" != "${line}" ]; then
        NO_JOB_LOGS="false"
    fi
    echo -e "${BUILD_NAME}: $line ";
done < ${JENKINS_LOG_FILE}

echo " "
sleep 5

if [ -f ${JENKINS_SERVER_LOG_FILE} ]; then
    rm -fv ${JENKINS_SERVER_LOG_FILE} || \
        echo "${ME}: Problem removing existing log file (${JENKINS_SERVER_LOG_FILE})."
fi

# Does not work :-(
# oc login -u developer -p anypwd
# TOKEN=$(oc -n ${PROJECT} get sa/jenkins --template='{{range .secrets}}{{ .name }} {{end}}' | xargs -n 1 oc -n ${PROJECT} get secret --template='{{ if .data.token }}{{ .data.token }}{{end}}' | head -n 1 | base64 -d -)

JENKINS_SERVER_PROTOCOL="$(echo ${LOG_URL} | cut -d "/" -f 1)"
JENKINS_SERVER_HOSTNAME="$(echo ${LOG_URL} | cut -d "/" -f 3)"
JENKINS_SERVER_LOGS_URL_TAIL="/manage/log/all"
JENKINS_SERVER_LOGS_URL="${JENKINS_SERVER_PROTOCOL}//${JENKINS_SERVER_HOSTNAME}${JENKINS_SERVER_LOGS_URL_TAIL}"

echo "${ME}: WARN: The following functionality is not working well yet... :("
echo "${ME}: Jenkins server log url: ${JENKINS_SERVER_LOGS_URL}"
curl --insecure -sSL --header "Authorization: Bearer ${TOKEN}" ${JENKINS_SERVER_LOGS_URL} > ${JENKINS_SERVER_LOG_FILE} || \
    echo "${ME}: Error retrieving jenkins server logs with curl, needed to eval problem in failed job ( ${BUILD_NAME} ). "

echo " "
echo " "

echo "${ME}: ** JENKINS LOGS (JNK_LOGS) AFTER PROBLEM BUILDING JOB ${BUILD_NAME}: "
echo " "
NO_SERVER_LOGS="true"
while read -r line; do
    if [ ! -z "$line" ] && [ "" != "${line}" ]; then
        NO_SERVER_LOGS="false"
    fi
    echo "JNK_LOGS: $line ";
done < ${JENKINS_SERVER_LOG_FILE}

echo " "
echo "${ME}: ENDS JENKINS LOGS (JNK_LOGS) AFTER PROBLEM BUILDING JOB ${BUILD_NAME}: "
echo " "
echo " "
echo " "
sleep 10

BAD_SERVER_LOGS="false"
if grep -q 'Still waiting to schedule task' ${JENKINS_LOG_FILE} ; then
    if grep -q 'HTTP ERROR' ${JENKINS_SERVER_LOG_FILE} ; then
        BAD_SERVER_LOGS="true"
    fi
fi

echo " "
echo "${ME}: NO_JOB_LOGS=${NO_JOB_LOGS}"
echo "${ME}: NO_SERVER_LOGS=${NO_SERVER_LOGS}"
echo "${ME}: BAD_SERVER_LOGS=${BAD_SERVER_LOGS}"
echo " "
if [ "true" == "${NO_JOB_LOGS}" ] || [ "true" == "${BAD_SERVER_LOGS}" ]; then
    echo " "
    echo "${ME}: A problem was found while retrieving Jenkins job/server logs."
    echo "${ME}: Since we might need to enter the box and see what went wrong, "
    echo "${ME}: this pipeline will wait for manual intervention. "
    echo "${ME}: If you just want to continue, kill the sleep process."
    echo "${ME}: Enjoy..."
    WAIT_FOR_MANUAL_INTERVENTION="true"
fi

echo "${BUILD_SEEMS_TO_BE_COMPLETE}" | grep -qi "true" || \
    echo "Build is not complete: ${BUILD_SEEMS_TO_BE_COMPLETE}"
echo "${BUILD_SEEMS_TO_BE_COMPLETE}" | grep -qi "true" || \
    WAIT_FOR_MANUAL_INTERVENTION="true"

if [ "true" == "${WAIT_FOR_MANUAL_INTERVENTION}" ]; then
    echo " "
    echo "${ME}: WAITING FOR MANUAL INTERVENTION ( WAIT_FOR_MANUAL_INTERVENTION = true ) "
    echo "${ME}: sleep 72000 ( 20h )"
    echo " "
    echo " "
    sleep 72000 || echo "${ME}: Sleep returned value != 0. Maybe aborted ?? "
    echo " "
    echo " "
fi
