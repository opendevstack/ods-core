#!/usr/bin/env bash
# set -x
set +e
set -o pipefail
export CGO_ENABLED=0

THIS_SCRIPT="$(basename ${0})"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ODS_CORE_DIR=${SCRIPT_DIR%/*}

ODS_NAMESPACE=$(${ODS_CORE_DIR}/scripts/get-config-param.sh ODS_NAMESPACE)
OPENSHIFT_APPS_BASEDOMAIN=$(${ODS_CORE_DIR}/scripts/get-config-param.sh OPENSHIFT_APPS_BASEDOMAIN)
export PROVISION_API_HOST=https://prov-app-${ODS_NAMESPACE}${OPENSHIFT_APPS_BASEDOMAIN}
echo "PROVISION_API_HOST = ${PROVISION_API_HOST}"

if ! oc whoami &> /dev/null; then
    echo "${THIS_SCRIPT}: You need to login to OpenShift to run the tests"
    exit 1
fi

if [ -f test-smoketest-results.txt ]; then
    rm test-smoketest-results.txt
fi

sleep 5
echo " "
echo "${THIS_SCRIPT}: go test -v -count=1 -timeout 140m github.com/opendevstack/ods-core/tests/smoketest "
go test -v -count=1 -timeout 140m github.com/opendevstack/ods-core/tests/smoketest | tee test-smoketest-results.txt 2>&1
exit_code=$?
echo "${THIS_SCRIPT}: return value: ${exit_code}"

if [ -f test-smoketest-results.txt ]; then
    set -e
    go-junit-report < test-smoketest-results.txt > test-smoketest-report.xml
fi

exit $exit_code
