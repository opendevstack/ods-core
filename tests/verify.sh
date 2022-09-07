#!/usr/bin/env bash
# set -x
set +e
set -o pipefail
export CGO_ENABLED=0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ODS_CORE_DIR=${SCRIPT_DIR%/*}

if ! oc whoami &> /dev/null; then
    echo "You need to login to OpenShift to run the tests"
    exit 1
fi

if [ -f test-verify-results.txt ]; then
    rm test-verify-results.txt
fi
echo "go test -v -count=1 -timeout 10h github.com/opendevstack/ods-core/tests/ods-verify"
go test -v -count=1 -timeout 10h github.com/opendevstack/ods-core/tests/ods-verify | tee test-verify-results.txt 2>&1
exitcode=$?
if [ -f test-verify-results.txt ]; then
    set -e
    go-junit-report < test-verify-results.txt > test-verify-report.xml
fi
exit $exitcode
