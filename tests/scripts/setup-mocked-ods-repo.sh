#!/usr/bin/env bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ODS_CORE_TESTS_DIR=${SCRIPT_DIR%/*}
ODS_CORE_DIR=${ODS_CORE_TESTS_DIR%/*}

function usage {
   printf "usage: %s [options]\n", $0
   printf "\t-h|--help\tPrints the usage\n"
   printf "\t-v|--verbose\tVerbose output\n"
   printf "\t-b|--ods-ref\tReference to be created in the mocked git repo.\n"

}

urlencode() {
    # urlencode <string>

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done


}

REF=""

URL=$(oc config view --minify -o jsonpath='{.clusters[*].cluster.server}')
if [ ${URL} != "https://172.17.0.1:8443" ]; then
    echo "You are not in a local cluster. Stopping now!!!"
    exit 1
fi

while [[ "$#" -gt 0 ]]; do case $1 in

   -v|--verbose) set -x;;

   -h|--help) usage; exit 0;;

   -b=*|--ods-ref=*) REF="${1#*=}";;
   -b|--ods-ref) REF="$2"; shift;;

   *) echo "Unknown parameter passed: $1"; usage; exit 1;;
 esac; shift; done

if git remote -v | grep mockbucket; then
    git remote remove mockbucket
fi


if [ -z "${REF}" ]; then
    echo "Reference --ods-ref must be provided"
    exit 1
fi

source ${ODS_CORE_DIR}/../ods-configuration/ods-core.env

docker ps | grep mockbucket

cd "${ODS_CORE_DIR}"
ls -lah
if [ ! -d ".git" ]; then
    git init
    git add --all
    git commit -m "Commit rsynced state"
fi
LOCAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)
git remote add mockbucket "http://$(urlencode ${CD_USER_ID}):$(urlencode ${CD_USER_PWD})@${BITBUCKET_HOST}/scm/opendevstack/ods-core.git"
git -c http.sslVerify=false push mockbucket --set-upstream "${LOCAL_BRANCH}:${REF}"
git remote remove mockbucket
cd -

cd "${ODS_CORE_DIR}/../ods-configuration"
git init
git config user.email "test@suite.nip.io"
git config user.name "Test Suite"
git add ods-core.env
git commit -m "Initial Commit"
LOCAL_BRANCH=$(git rev-parse --abbrev-ref HEAD)
git remote add mockbucket "http://$(urlencode ${CD_USER_ID}):$(urlencode ${CD_USER_PWD})@${BITBUCKET_HOST}/scm/opendevstack/ods-configuration.git"
git -c http.sslVerify=false push mockbucket --set-upstream "${LOCAL_BRANCH}:${REF}"
cd -
