#!/usr/bin/env bash
# set -x
set +e
set -o pipefail
export CGO_ENABLED=0

if [ -f test-create-projects-results.txt ]; then
    rm test-create-projects-results.txt
fi
go test -v -count=1 github.com/opendevstack/ods-core/tests/create-projects | tee test-create-projects-results.txt 2>&1
exitcode=$?
if [ -f test-create-projects-results.txt ]; then
    set -e
    go-junit-report < test-create-projects-results.txt > test-create-projects-report.xml
fi
exit $exitcode
