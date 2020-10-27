#!/usr/bin/env bash
set -eu
set -o pipefail
export CGO_ENABLED=0

# By default we run all quickstarter tests, otherwise just the quickstarter
# passed as the first argument to this script.
QUICKSTARTER=${1-"ods-quickstarters/..."}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ODS_CORE_DIR=${SCRIPT_DIR%/*}

if ! oc whoami &> /dev/null; then
    echo "You need to login to OpenShift to run the tests"
    exit 1
fi

if [ -f test-quickstarter-results.txt ]; then
    rm test-quickstarter-results.txt
fi

BITBUCKET_TEST_PROJECT="unitt"
echo "Setup Bitbucket test project ${BITBUCKET_TEST_PROJECT} ..."
BITBUCKET_URL=$(${ODS_CORE_DIR}/scripts/get-config-param.sh BITBUCKET_URL)
CD_USER_ID=$(${ODS_CORE_DIR}/scripts/get-config-param.sh CD_USER_ID)
CD_USER_PWD_B64=$(${ODS_CORE_DIR}/scripts/get-config-param.sh CD_USER_PWD_B64)
./scripts/setup-bitbucket-test-project.sh \
    --bitbucket=${BITBUCKET_URL} \
    --user=${CD_USER_ID} \
    --password=$(base64 -d - <<< ${CD_USER_PWD_B64}) \
    --project=${BITBUCKET_TEST_PROJECT}

echo "Running tests (${QUICKSTARTER}). Output will take a while to arrive ..."

go test -v -count=1 -timeout 3h -p 1 github.com/opendevstack/ods-core/tests/quickstarter -args ${QUICKSTARTER} | tee test-quickstarter-results.txt 2>&1
exitcode="${PIPESTATUS[0]}"
if [ -f test-quickstarter-results.txt ]; then
    go-junit-report < test-quickstarter-results.txt > test-quickstarter-report.xml
fi
exit $exitcode
