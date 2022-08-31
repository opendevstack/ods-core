#!/usr/bin/env bash
set -eu
set -o pipefail

ME="$(basename $0)"
JENKINS_LOG_FILE="jenkins-downloaded-log.txt"

echo " "
echo " "
echo " "
PROJECT=$1
BUILD_NAME=$2
LOG_URL=$(oc -n ${PROJECT} get build ${BUILD_NAME} -o jsonpath='{.metadata.annotations.openshift\.io/jenkins-log-url}')
echo " "
echo "${ME}: Jenkins log url: ${LOG_URL}"
echo " "
TOKEN=$(oc -n ${PROJECT} get sa/jenkins --template='{{range .secrets}}{{ .name }} {{end}}' | xargs -n 1 oc -n ${PROJECT} get secret --template='{{ if .data.token }}{{ .data.token }}{{end}}' | head -n 1 | base64 -d -)

if [ -f ${JENKINS_LOG_FILE} ]; then
    rm -fv ${JENKINS_LOG_FILE} || echo "Problem removing existing log file."
fi

echo "${ME}: Retrieving logs from url: ${LOG_URL}"
curl --insecure -sSL --header "Authorization: Bearer ${TOKEN}" ${LOG_URL} > ${JENKINS_LOG_FILE} || \
    echo "${ME}: Error retrieving jenkins logs of job run in ${BUILD_NAME} with curl."

# | xargs -n 1 echo "${BUILD_NAME}: " || \
# echo "Error retrieving jenkins logs of job run in ${BUILD_NAME} with curl."

echo " "
echo " "
# Appends current ${BUILD_NAME} to each log line. Improves readability.
while read -r line; do
    echo -e "${BUILD_NAME}: $line ";
done < ${JENKINS_LOG_FILE}

echo " "
echo " "
echo " "
sleep 5
