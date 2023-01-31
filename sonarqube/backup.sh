#!/bin/bash
set -eu

NAMESPACE="ods"
BACKUP_DIR="."

function usage {
  printf "usage: %s [options]\n" "$0"
  printf "\t-h|--help\tPrints the usage\n"
  printf "\t-v|--verbose\tVerbose output\n"
  printf "\t-b|--backup-dir\tLocation of backup directory\n"
  printf "\t-n|--namespace\tNamespace (defaults to '%s')\n" "${NAMESPACE}"
}

while [[ "$#" -gt 0 ]]; do case $1 in
  -v|--verbose) set -x;;

  -h|--help) usage; exit 0;;

  -b=*|--backup-dir=*) BACKUP_DIR="${1#*=}";;
  -b|--backup-dir) BACKUP_DIR="$2"; shift;;

  -n=*|--namespace=*) NAMESPACE="${1#*=}";;
  -n|--namespace) NAMESPACE="$2"; shift;;

  *) echo "Unknown parameter passed: $1"; usage; exit 1;;
esac; shift; done

if ! oc whoami > /dev/null; then
  echo "You need to log into OpenShift first"
  exit 1
fi

# Dump database
destinationFile="${BACKUP_DIR}/sonarqube.sql"
podWithPrefix=$(oc get pods -n "${NAMESPACE}" --selector name=sonarqube-postgresql --no-headers -o name)
pod=${podWithPrefix#"pod/"}
oc rsh -n "${NAMESPACE}" "pod/${pod}" bash -c "mkdir -p /var/lib/pgsql/backup && pg_dump sonarqube > /var/lib/pgsql/backup/sonarqube.sql"
# Copy export
oc -n "${NAMESPACE}" cp "${pod}:/var/lib/pgsql/backup/sonarqube.sql" "${destinationFile}"
# Delete export in pod
oc rsh -n "${NAMESPACE}" "pod/${pod}" bash -c "rm /var/lib/pgsql/backup/sonarqube.sql"

echo "Database 'sonarqube' backed up to ${destinationFile}."
