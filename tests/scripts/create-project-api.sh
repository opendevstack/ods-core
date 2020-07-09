#!/usr/bin/env bash

set -eu

# Setup these variables
# PROVISION_API_HOST=<protocol>://<hostname>:<port>
# BASIC_AUTH_CREDENTIAL=<USERNAME>:<PASSWORD>
# PROVISION_FILE=provision-new-project-payload.json

PROV_APP_CONFIG_FILE=prov-app-config.txt

if [ -f $PROV_APP_CONFIG_FILE ]; then
	cat $PROV_APP_CONFIG_FILE
	source $PROV_APP_CONFIG_FILE
else
	echo "No config file found, assuming defaults, current: $(pwd)"
fi

PROVISION_API_HOST="${PROVISION_API_HOST:=http://localhost:8080}"
BASIC_AUTH_CREDENTIAL="${BASIC_AUTH_CREDENTIAL:=openshift:openshift}"
PROVISION_FILE="${PROVISION_FILE:=golden/create-project-request.json}"

echo
echo "Started provision new project script!"
echo
echo "... encoding basic auth credentials in base64 format"
BASE64_CREDENTIALS=$(echo -n $BASIC_AUTH_CREDENTIAL | base64)
echo
echo
if [ ! -f $PROVISION_FILE ]; then
	echo "Input for provision api (${PROVISION_FILE}) does not EXIST, aborting\ncurrent: $(pwd)"
	exit 1
fi
echo "... new project request payload loaded from '"$PROVISION_FILE"'"
echo "... displaying payload file content:"
cat $PROVISION_FILE
echo
echo "... sending request to '"$PROVISION_API_HOST"' (output will be saved in file './response.txt' and headers in file './headers.txt')"
echo
RESPONSE_FILE=response.txt

http_resp_code=$(curl --fail --insecure --location --request POST "${PROVISION_API_HOST}/api/v2/project" \
--header "Authorization: Basic ${BASE64_CREDENTIALS}" \
--header 'Accept: application/json' \
--header 'Content-Type: application/json' \
--data @"$PROVISION_FILE" \
--dump-header headers.txt -o ${RESPONSE_FILE} -w "%{http_code}" )
exit_status=$?
if [ $exit_status != 0 ]
  then
    echo "something went wrong... curl request failed [status="$exit_status"] http response="$http_resp_code" !!!"
	if [ -f ${RESPONSE_FILE} ]; then
		cat ${RESPONSE_FILE}
	fi
    exit $exit_status
fi

echo "curl request successful..."
echo
echo "... displaying HTTP response body (content from './response.txt'):"
if [ -f ${RESPONSE_FILE} ]; then
	cat ${RESPONSE_FILE}
fi
echo
echo "... displaying HTTP response code"
echo "http_resp_code=${http_resp_code}"
echo
if [ $http_resp_code != 200 ]
  then
    echo "something went wrong... endpoint responded with error code [HTTP CODE="$http_resp_code"] (expected was 200)"
    exit 1
fi
echo "provision new project request completed successfully!!!"
