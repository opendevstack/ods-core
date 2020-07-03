#!/usr/bin/env bash
# set -x
set +e
set -o pipefail

if [ -f test-installation-results.txt ]; then
    rm test-installation-results.txt
fi
go test -v github.com/opendevstack/ods-core/tests/create-projects | tee test-installation-results.txt 2>&1
exitcode=$?
if [ -f test-installation-results.txt ]; then
    set -e
    go-junit-report < test-installation-results.txt > test-installation-report.xml
fi
exit $exitcode
