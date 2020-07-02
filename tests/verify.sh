#!/usr/bin/env bash
# set -x
set +e
set -o pipefail

if [ -f test-results.txt ]; then
    rm test-results.txt
fi
go test -v -timeout 30s github.com/opendevstack/ods-core/tests/ods-verify | tee test-results.txt 2>&1
exitcode=$?
if [ -f test-results.txt ]; then
    set -e
    go-junit-report < test-results.txt > test-report.xml
fi
exit $exitcode
