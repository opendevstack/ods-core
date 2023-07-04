#!/usr/bin/env bash
set -eu
set -o pipefail
export CGO_ENABLED=0

THIS_SCRIPT="$(basename $0)"

# By default we run all quickstarter tests, otherwise just the quickstarter
# passed as the first argument to this script.
BITBUCKET_TEST_PROJECT="unitt"
QUICKSTARTER="ods-quickstarters/..."
PARALLEL="1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ODS_CORE_DIR=${SCRIPT_DIR%/*}

function check_already_logged_in_openshift(){
    if ! oc whoami &> /dev/null; then
        echo "${THIS_SCRIPT}: You need to login to OpenShift to run the tests"
        echo "${THIS_SCRIPT}: Returning with exit code 1"
        exit 1
    fi
}

function cleanup_workspace(){
    if [ -f test-quickstarter-results.txt ]; then
        rm test-quickstarter-results.txt
    fi
}

function generate_results(){
    echo "Process results"
    cd $ODS_CORE_DIR/tests
    if [ -f test-quickstarter-results.txt ]; then
        go-junit-report < test-quickstarter-results.txt > test-quickstarter-report.xml
        cat -v test-quickstarter-results.txt > test-output
        go-junit-report < test-output > test-quickstarter-report.xml
        csplit -z test-quickstarter-results.txt '/=== CONT/' {*}
        rm xx00
        for file in xx*; do
            newName=$(grep -oP -m 1 'TestQuickstarter/\K\w+.*' $file)
            mv $file $newName.txt
        done        
    fi    
}

function run_test(){
    echo " "
    echo "${THIS_SCRIPT}: Running tests (${QUICKSTARTER}). Output will take a while to arrive ..."
    echo " "

    
    # Should fix error " panic: test timed out after "
    echo "${THIS_SCRIPT}: go test -v -count=1 -timeout 30h -parallel ${PARALLEL} github.com/opendevstack/ods-core/tests/quickstarter -args ${QUICKSTARTER}"
    go test -v -count=1 -timeout 30h -parallel ${PARALLEL} github.com/opendevstack/ods-core/tests/quickstarter -args ${QUICKSTARTER} ${BITBUCKET_TEST_PROJECT} | tee test-quickstarter-results.txt 2>&1
    
    exitcode="${PIPESTATUS[0]}"

    echo " "
    echo " "
    echo "${THIS_SCRIPT}: Returning with exit code ${exitcode}"
    echo " "
    echo " "

    generate_results

    exit $exitcode
}


function usage {
    printf "Run quickstarters tests.\n\n"
    printf "\t-h |--help\t\tPrint usage\n"
    printf "\t-p |--project\t\tBitbucket project (* mandatory)\n"
    printf "\t-pa|--parallel\t\tNumber of test executed in parallel\n"
    printf "\t-q |--quickstarter\tQuickStarter to test or Quickstarter folder (default:ods-quickstarters/...)\n"
}

while [[ "$#" -gt 0 ]]; do
    case $1 in

    -h|--help) usage; exit 0;;

    -pa|--parallel) PARALLEL="$2"; shift;;
    -pa=*|--parallel=*) PARALLEL="${1#*=}";;

    -q|--quickstarter) QUICKSTARTER="$2"; shift;;
    -q=*|--quickstarter=*) QUICKSTARTER="${1#*=}";;

    -p|--project) BITBUCKET_TEST_PROJECT="$2"; shift;;
    -p=*|--project=*) BITBUCKET_TEST_PROJECT="${1#*=}";;

  *) echo_error "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

if [ -z "${BITBUCKET_TEST_PROJECT}" ]; then
    echo "--project is mandatory"
    usage
    exit 1
fi

check_already_logged_in_openshift
cleanup_workspace
run_test
