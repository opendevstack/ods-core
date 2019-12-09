#!/usr/bin/env bash

NEXUS_HOST=$1
NEXUS_ADMIN_USER=$2
ADMIN_PW=$3

echo "Using host: ${NEXUS_HOST}"
echo "Using nexus admin user: ${NEXUS_ADMIN_USER}"
echo "Using nexus admin password: ${ADMIN_PW}"

echo -e "\nInstall Blob Stores\n"
curl -u ${NEXUS_ADMIN_USER}:${ADMIN_PW} --insecure -X POST --header 'Content-Type: application/json' "${NEXUS_HOST}/service/rest/v1/script" -d @json/createBlobStores.json
curl -u ${NEXUS_ADMIN_USER}:${ADMIN_PW} --insecure -X POST --header 'Content-Type: text/plain' "${NEXUS_HOST}/service/rest/v1/script/createBlobStores/run"
sleep 3s
curl -u ${NEXUS_ADMIN_USER}:${ADMIN_PW} --insecure -X DELETE "${NEXUS_HOST}/service/rest/v1/script/createBlobStores"
sleep .5s
echo -e "\nInstall Repositories\n"
curl -u ${NEXUS_ADMIN_USER}:${ADMIN_PW} --insecure -X POST --header 'Content-Type: application/json' "${NEXUS_HOST}/service/rest/v1/script" -d @json/createRepos.json
curl -u ${NEXUS_ADMIN_USER}:${ADMIN_PW} --insecure -X POST --header 'Content-Type: text/plain' "${NEXUS_HOST}/service/rest/v1/script/createRepos/run"
sleep 3s
curl -u ${NEXUS_ADMIN_USER}:${ADMIN_PW} --insecure -X DELETE "${NEXUS_HOST}/service/rest/v1/script/createRepos"
sleep .5s
echo -e "\nDeactivate anonymous access\n"
curl -u ${NEXUS_ADMIN_USER}:${ADMIN_PW} --insecure -X POST --header 'Content-Type: application/json' "${NEXUS_HOST}/service/rest/v1/script" -d @json/deactivateAnonymous.json
curl -u ${NEXUS_ADMIN_USER}:${ADMIN_PW} --insecure -X POST --header 'Content-Type: text/plain' "${NEXUS_HOST}/service/rest/v1/script/deactivateAnonymous/run"
sleep 3s
curl -u ${NEXUS_ADMIN_USER}:${ADMIN_PW} --insecure -X DELETE "${NEXUS_HOST}/service/rest/v1/script/deactivateAnonymous"
sleep .5s
echo -e "\nSetup developer role\n"
curl -u ${NEXUS_ADMIN_USER}:${ADMIN_PW} --insecure -X POST --header 'Content-Type: application/json' "${NEXUS_HOST}/service/rest/v1/script" -d @json/createRole.json
curl -u ${NEXUS_ADMIN_USER}:${ADMIN_PW} --insecure -X POST --header 'Content-Type: text/plain' "${NEXUS_HOST}/service/rest/v1/script/createRole/run" -d @json/developer-role.json
sleep 3s
echo -e "\nSetup developer user\n"
curl -u ${NEXUS_ADMIN_USER}:${ADMIN_PW} --insecure -X POST --header 'Content-Type: application/json' "${NEXUS_HOST}/service/rest/v1/script" -d @json/createUser.json
curl -u ${NEXUS_ADMIN_USER}:${ADMIN_PW} --insecure -X POST --header 'Content-Type: text/plain' "${NEXUS_HOST}/service/rest/v1/script/createUser/run" -d @json/developer-user.json
sleep .5s
echo -e "\nSetup specific access script\n"
curl -u ${NEXUS_ADMIN_USER}:${ADMIN_PW} --insecure -X POST --header 'Content-Type: application/json' "${NEXUS_HOST}/service/rest/v1/script" -d @json/createProjectSpecificAccess.json

