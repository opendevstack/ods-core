#!/usr/bin/env bash
set -eu
set -o pipefail

JENKINS_LOG_FILE="jenkins-downloaded-log.txt"
JENKINS_SERVER_LOG_FILE="jenkins-server-log.txt"
OC_ERROR="false"
LOG_URL="http://localhost"
TOKEN="none"

echo " "
echo " "
echo " "
PROJECT=$1
BUILD_NAME=$2
ME="$(basename $0)[${BUILD_NAME}]"
echo "${ME}: Project: ${PROJECT} BuildName: ${BUILD_NAME} "
echo " "

LOG_URL=$(oc -n ${PROJECT} get build ${BUILD_NAME} -o jsonpath='{.metadata.annotations.openshift\.io/jenkins-log-url}' || echo "OC_ERROR" )

echo " "
echo "${ME}: Jenkins log url: ${LOG_URL}"
echo " "
if [ "OC_ERROR" == "${LOG_URL}" ]; then
    OC_ERROR="true"
    TOKEN="OC_ERROR"
else
    TOKEN=$(oc -n ${PROJECT} get sa/jenkins --template='{{range .secrets}}{{ .name }} {{end}}' | xargs -n 1 oc -n ${PROJECT} get secret --template='{{ if .data.token }}{{ .data.token }}{{end}}' | head -n 1 | base64 -d -)
fi

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

BAD_SERVER_LOGS="false"
if grep -q 'Still waiting to schedule task' ${JENKINS_LOG_FILE} ; then
    if ! grep -q 'Finished: SUCCESS' ${JENKINS_LOG_FILE} ; then
        BAD_SERVER_LOGS="true"
    fi
fi

echo " "
echo "${ME}: NO_JOB_LOGS=${NO_JOB_LOGS}"
# echo "${ME}: NO_SERVER_LOGS=${NO_SERVER_LOGS}"
echo "${ME}: BAD_SERVER_LOGS=${BAD_SERVER_LOGS}"
echo " "
if [ "true" == "${NO_JOB_LOGS}" ] || [ "true" == "${BAD_SERVER_LOGS}" ]; then
    echo " "
    echo "${ME}: ERROR: Logs retrieved are not good enough."
    echo " "
    # WARNING: If we exit 1, the whole process aborts !!!
    # exit 1
fi

exit 0
