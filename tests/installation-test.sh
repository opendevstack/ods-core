#!/usr/bin/env bash
# set -x
set +e
set -o pipefail

source ../../ods-configuration/ods-core.env
export PROVISION_API_HOST=https://prov-app-${ODS_NAMESPACE}${OPENSHIFT_APPS_BASEDOMAIN}
echo "PROVISION_API_HOST = ${PROVISION_API_HOST}"

if [ -f test-installation-results.txt ]; then
    rm test-installation-results.txt
fi
go test -v -count=1 github.com/opendevstack/ods-core/tests/create-projects | tee test-installation-results.txt 2>&1
exitcode=$?
if [ -f test-installation-results.txt ]; then
    set -e
    go-junit-report < test-installation-results.txt > test-installation-report.xml
fi
exit $exitcode
