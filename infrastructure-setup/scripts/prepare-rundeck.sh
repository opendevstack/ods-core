#!/usr/bin/env bash
# Prepare rundeck JVM
export PATH=$PATH:/usr/local/bin/

RUNDECK_URL="http://192.168.56.31:4440"
RUNDECK_USER="opendevstack.admin"
RUNDECK_PW="admin"

BASE_DIR=${OPENDEVSTACK_DIR:-"/ods"}
cwd=${pwd}
CURLOPTS="-s -S -L -c ${BASE_DIR}/.cookies -b ${BASE_DIR}/.cookies"

echo ${CURLOPTS}
#curl command to use with opts
CURL="curl $CURLOPTS"

if [ "$HOSTNAME" != "atlassian" ] ; then
	echo "This script has to be executed on the atlassian VM"
	exit
fi

cd /ods/ods-core/infrastructure-setup/scripts/

echo "Login to rundeck"
$CURL -d j_username=$RUNDECK_USER -d j_password=$RUNDECK_PW "$RUNDECK_URL/j_security_check" > /dev/null

echo "Create project"
#$CURL --header 'Content-Type: application/x-rundeck-data-password' "${RUNDECK_URL}/api/23/storage/keys/openshift-api-token" -d @/ods/openshift-api-token
$CURL --header 'Content-Type: application/json' "${RUNDECK_URL}/api/23/projects" -d @json/create-rundeck-project.json

echo -e "\n"
cd ${cwd}
