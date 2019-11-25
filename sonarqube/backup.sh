#!/bin/bash
if [ "$#" -eq 0 ]; then
  echo "Usage: ./backup.sh /path/to/backup/dir"
  exit 1
fi

if ! oc whoami; then
  echo "You need to log into OpenShift first"
  exit 1
fi

set -eux

backup_dir=$1

# Dump database
podWithPrefix=$(oc get pods -n cd --selector name=sonarqube-postgresql --no-headers -o name)
pod=${podWithPrefix#"pod/"}
oc rsh -n cd pod/$pod bash -c "pg_dump sonarqube > sonarqube.sql"
# Copy export
oc cp cd/$pod:/opt/app-root/src/sonarqube.sql $backup_dir/
# Delete export in pod
oc rsh -n cd pod/$pod bash -c "rm sonarqube.sql"

echo "Database 'sonarqube' copied to $backup_dir."
