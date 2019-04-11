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

echo "Create openshift-api-token"
$CURL --header 'Content-Type: application/x-rundeck-data-password' "${RUNDECK_URL}/api/23/storage/keys/openshift-api-token" -d @/ods/openshift-api-token

echo "Create project"
$CURL --header 'Content-Type: application/json' "${RUNDECK_URL}/api/23/projects" -d @json/create-rundeck-project.json
echo "Add SSH to bitbucket host on bitbucket port"
if [[ ! -d "~/.ssh" ]] ; then
  mkdir ~/.ssh
fi
ssh-keyscan -p 7999 -t rsa localhost > ~/.ssh/known_hosts
ssh-keyscan -p 7999 -t rsa localhost > /var/lib/rundeck/.ssh/known_hosts
chown rundeck:rundeck /var/lib/rundeck/.ssh/known_hosts
echo -e "\nGet SCM information"
$CURL "${RUNDECK_URL}/api/23/project/Quickstarters2/scm/import/config"
echo -e "\nSetup SCM information"
$CURL --header 'Content-Type: application/json' "${RUNDECK_URL}/api/23/project/Quickstarters/scm/import/plugin/git-import/setup" -d @json/setup-scm-rundeck.json
echo -e "\nGet SCM actions"
$CURL --header 'Accept: application/json' "${RUNDECK_URL}/api/23/project/Quickstarters/scm/import/action/import-jobs/input"  | jq '.importItems | { input : null, jobs : null, deleted: null, deletedJobs: null, items : [.[] | { itemId: .itemId }] }' > import_jobs.json
echo -e "\nExecute SCM action"
$CURL -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' "${RUNDECK_URL}/api/23/project/Quickstarters/scm/import/action/import-jobs" -d @import_jobs.json
rm -f import_jobs.json

echo -e "\n"
cd ${cwd}
