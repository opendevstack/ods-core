#!/usr/bin/env bash

set -eu
set -o pipefail

# Setup these variables
# PROVISION_API_HOST=<protocol>://<hostname>:<port>
# BASIC_AUTH_CREDENTIAL=<USERNAME>:<PASSWORD>
# PROVISION_FILE=provision-new-project-payload.json

PROV_APP_CONFIG_FILE="${PROV_APP_CONFIG_FILE:-prov-app-config.txt}"

if [ -f $PROV_APP_CONFIG_FILE ]; then
	source $PROV_APP_CONFIG_FILE
else
	echo "No config file found, assuming defaults, current dir: $(pwd)"
fi

PROVISION_API_HOST="${PROVISION_API_HOST:=http://localhost:8080}"
BASIC_AUTH_CREDENTIAL="${BASIC_AUTH_CREDENTIAL:=openshift:openshift}"
PROVISION_FILE="${PROVISION_FILE:=fixtures/create-project-request.json}"
# not set - use post as operation, creates new project
COMMAND="${1:-POST}"

echo
echo "Started provision project/component script with command (${COMMAND})!"
echo
echo "... encoding basic auth credentials in base64 format"
BASE64_CREDENTIALS=$(echo -n $BASIC_AUTH_CREDENTIAL | base64)
echo
echo "... sending request to '"$PROVISION_API_HOST"' (output will be saved in file './response.txt' and headers in file './headers.txt')"
echo
RESPONSE_FILE=response.txt

if [ -f $RESPONSE_FILE ]; then
	rm -f $RESPONSE_FILE
fi

if [ ${COMMAND} == "POST" ] || [ ${COMMAND} == "PUT" ] || [ ${COMMAND} == "DELETE_COMPONENT" ]; then
echo
	echo "create or update project, or delete component - ${COMMAND}"
	if [ ! -f $PROVISION_FILE ]; then
		echo "Input for provision api (${PROVISION_FILE}) does not EXIST, aborting\ncurrent: $(pwd)"
		exit 1
	fi
	echo "... ${COMMAND} project request payload loaded from '"$PROVISION_FILE"'"
	echo
	echo "... displaying payload file content:"
	cat $PROVISION_FILE
	echo

	if [ ${COMMAND} == "DELETE_COMPONENT" ]; then
		COMMAND=DELETE
	fi

	http_resp_code=$(curl --insecure --request ${COMMAND} "${PROVISION_API_HOST}/api/v2/project" \
	--header "Authorization: Basic ${BASE64_CREDENTIALS}" \
	--header 'Accept: application/json' \
	--header 'Content-Type: application/json' \
	--data @"$PROVISION_FILE" \
	--dump-header headers.txt -o ${RESPONSE_FILE} -w "%{http_code}" )
elif [ ${COMMAND} == "DELETE" ] || [ ${COMMAND} == "GET" ]; then
	echo "delete / get project - ${COMMAND}"
	if [ -z $2 ]; then
		echo "Project Key must be passed as second param in case of command == delete or get!!"
		exit 1
	fi

	http_resp_code=$(curl -vvv --insecure --request ${COMMAND} "${PROVISION_API_HOST}/api/v2/project/$2" \
	--header "Authorization: Basic ${BASE64_CREDENTIALS}" \
	--header 'Accept: application/json' \
	--header 'Content-Type: application/json' \
	--dump-header headers.txt -o ${RESPONSE_FILE} -w "%{http_code}" )
else
	echo "ERROR: Command ${COMMAND} not supported, only GET, POST, PUT, DELETE or DELETE_COMPONENT"
	exit 1
fi

echo "curl ${COMMAND} request successful..."
echo
echo "... displaying HTTP response body (content from './response.txt'):"
if [ -f ${RESPONSE_FILE} ]; then
	cat ${RESPONSE_FILE}
else 
	echo "No request (body) response recorded"
fi

echo
echo "... displaying HTTP response code"
echo "http_resp_code=${http_resp_code}"
echo
if [ $http_resp_code != 200 ]; then
	if [ ${COMMAND} == "DELETE" ] && [ ${http_resp_code} == 404 ]; then
		echo "... DELETE request responded with 404 - continuing as resource does not exist"
	else
		echo "something went wrong... endpoint responded with error code [HTTP CODE="$http_resp_code"] (expected was 200)"
		exit 1
	fi
fi
echo "provision project/component request (${COMMAND}) completed successfully!"
