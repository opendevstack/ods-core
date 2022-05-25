#!/usr/bin/env bash
set -eu
set -o pipefail
export CGO_ENABLED=0

THIS_SCRIPT="$(basename $0)"

# By default we run all quickstarter tests, otherwise just the quickstarter
# passed as the first argument to this script.
QUICKSTARTER=${1-"ods-quickstarters/..."}
PARALLEL=${2-"1"}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ODS_CORE_DIR=${SCRIPT_DIR%/*}

if ! oc whoami &> /dev/null; then
    echo "${THIS_SCRIPT}: You need to login to OpenShift to run the tests"
    echo "${THIS_SCRIPT}: Returning with exit code 1"
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

echo " "
echo "${THIS_SCRIPT}: Cleaning a little bit the host machine to not suffer from limitated resources... "
echo " "
docker ps -a | grep 'Exited .* ago' | sed 's/\s\+/ /g' | cut -d ' ' -f 1 | while read id; do echo "docker rm $id"; docker rm $id; done

echo " "
echo "${THIS_SCRIPT}: Running tests (${QUICKSTARTER}). Output will take a while to arrive ..."
echo " "

# Should fix error " panic: test timed out after "
echo "${THIS_SCRIPT}: go test -v -count=1 -timeout 5h -parallel ${PARALLEL} github.com/opendevstack/ods-core/tests/quickstarter -args ${QUICKSTARTER}"
go test -v -count=1 -timeout 5h -parallel ${PARALLEL} github.com/opendevstack/ods-core/tests/quickstarter -args ${QUICKSTARTER} | tee test-quickstarter-results.txt 2>&1
exitcode="${PIPESTATUS[0]}"
if [ -f test-quickstarter-results.txt ]; then
    go-junit-report < test-quickstarter-results.txt > test-quickstarter-report.xml
fi

echo "${THIS_SCRIPT}: Returning with exit code ${exitcode}"
exit $exitcode
