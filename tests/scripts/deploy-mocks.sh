#!/usr/bin/env bash
# (Re)deploys the mocked services for ODS using docker

set -eu

function usage {
   printf "usage: %s [options]\n", $0
   printf "\t-h|--help\tPrints the usage\n"
   printf "\t-v|--verbose\tVerbose output\n"
   printf "\t-w|--wait\tWaits for the service(s). Depends on netcat \n"

}
WAIT=false
while [[ "$#" -gt 0 ]]; do case $1 in

   -v|--verbose) set -x;;

   -h|--help) usage; exit 0;;

   -w|--wait) WAIT=true;;

   *) echo "Unknown parameter passed: $1"; usage; exit 1;;
 esac; shift; done

URL=$(oc config view --minify -o jsonpath='{.clusters[*].cluster.server}')
if [ ${URL} != "https://127.0.0.1:8443" ]; then
    echo "You are not in a local cluster. Stopping now!!!"
fi

if docker ps -a --format "{{.Names}}" | grep mockbucket; then
    docker rm mockbucket --force
fi

source ${BASH_SOURCE%/*}/../../ods-config/ods-core.env
docker run -d -p "8080:8080" \
           --env="BASIC_USERNAME=${CD_USER_ID}" \
           --env="BASIC_PASSWORD=${CD_USER_PWD}" \
           --env="REPOS=opendevstack/ods-core.git;opendevstack/ods-configuration.git;opendevstack/ods-quickstarters.git;opendevstack/ods-jenkins-shared-library.git" \
           --name mockbucket \
           hugowschneider/mockbucket:latest

if [ ${WAIT} == "true" ]; then
  echo "Waiting for mockbucket to launch on 8080..."

  while ! nc -z 172.17.0.1 8080; do
    echo "Port 8080 is not responding..."
    sleep 1 
  done

  while [ "$(curl http://172.17.0.1:8080 -u $CD_USER_ID:$CD_USER_PWD -o /dev/null -w '%{http_code}' -s)" != "200" ]; do 
    echo "Service is still not running..."
    sleep 1 
  done

  echo "Mockbucket is running"
fi
