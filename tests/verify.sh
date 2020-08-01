#!/usr/bin/env bash
# set -x
set +e
set -o pipefail

source ../../ods-configuration/ods-core.env
export PROVISION_API_HOST=https://prov-app-${ODS_NAMESPACE}${OPENSHIFT_APPS_BASEDOMAIN}
echo "PROVISION_API_HOST = ${PROVISION_API_HOST}"

if [ -f test-results.txt ]; then
    rm test-results.txt
fi
go test -v -timeout 10m github.com/opendevstack/ods-core/tests/ods-verify | tee test-results.txt 2>&1
exitcode=$?
if [ -f test-results.txt ]; then
    set -e
    go-junit-report < test-results.txt > test-report.xml
fi
exit $exitcode
