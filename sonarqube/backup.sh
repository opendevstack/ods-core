#!/bin/bash
set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ODS_CORE_DIR=${SCRIPT_DIR%/*}
ODS_CONFIGURATION_DIR="${ODS_CORE_DIR}/../ods-configuration"

NAMESPACE=""
BACKUP_DIR="."
PROGRESS=false
LOCAL=false

function usage {
  printf "usage: %s [options]\n" "$0" 
  printf "\t-h|--help\tPrints the usage\n"
  printf "\t-v|--verbose\tVerbose output\n"
  printf "\t-b|--backup-dir\tLocation of backup directory\n"
  printf "\t-n|--namespace\tNamespace, optional param as it will be read from ods-core.env if available\n"
  printf "\t-p|--progress\tShow progress during transfer (defaults to '%s')\n" "${PROGRESS}"
  printf "\t-l|--local-copy\tCopy the database dump in local (defaults to '%s')\n" "${LOCAL}"
}

while [[ "$#" -gt 0 ]]; do case $1 in
  -v|--verbose) set -x;;

  -h|--help) usage; exit 0;;

  -b=*|--backup-dir=*) BACKUP_DIR="${1#*=}";;
  -b|--backup-dir) BACKUP_DIR="$2"; shift;;

  -n=*|--namespace=*) NAMESPACE="${1#*=}";;
  -n|--namespace) NAMESPACE="$2"; shift;;

  -p=*|--progress=*) PROGRESS="${1#*=}";;
  -p|--progress) PROGRESS="$2"; shift;;

  -l=*|--local-copy=*) LOCAL="${1#*=}";;
  -l|--local-copy) LOCAL="$2"; shift;;

  *) echo "Unknown parameter passed: $1"; usage; exit 1;;
esac; shift; done

if [ -f "${ODS_CONFIGURATION_DIR}/ods-core.env" ] && [ -z "${NAMESPACE}" ]; then
    NAMESPACE=$(../scripts/get-config-param.sh ODS_NAMESPACE)
fi

if ! oc whoami > /dev/null; then
  echo "You need to log into OpenShift first"
  exit 1
fi

# Dump database
podWithPrefix=$(oc get pods -n "${NAMESPACE}" --selector name=sonarqube-postgresql --no-headers -o name)
pod=${podWithPrefix#"pod/"}
oc rsh -n "${NAMESPACE}" "pod/${pod}" bash -c "pg_dump sonarqube > /var/lib/pgsql/backups/sonarqube.sql"
echo "Database 'sonarqube' dumped and stored in /var/lib/pgsql/backups/sonarqube.sql."

if [ "${LOCAL}" == true ]; then
# Copy export locally
oc -n "${NAMESPACE}" rsync --progress="${PROGRESS}" "${pod}:/var/lib/pgsql/backups/sonarqube.sql" "${BACKUP_DIR}"
echo "Database 'sonarqube' backed up to ${BACKUP_DIR}."
fi
