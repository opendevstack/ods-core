#!/usr/bin/env bash

################################################################################
#### README!
#### =======
#### This script will check the insecure registries setting in docker and
#### then try and startup the OpenShift cluster. If successful, it will check
#### for the CD namespace and try and set it up if is not there yet.
#### After script execution, an OpenShift cluster should be running providing
#### an ODS application.
################################################################################

set -e -o pipefail

function configure_docker() {
  cwd=$(pwd)
  cd ../tests/scripts/
  "./apply-docker-settings.sh*"
  cd "${cwd}"
}

function startup_openshift_cluster() {
  # work in progress!
  oc cluster up --base-dir="$HOME/openshift.local.clusterup"
}

function main() {
  configure_docker
}

main
