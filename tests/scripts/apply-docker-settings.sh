#!/usr/bin/env bash
set -uex

DAEMON_JSON=$(cat ${BASH_SOURCE%/*}/json/daemon.json)
DAEMON_FILE_PATH="/etc/docker/daemon.json"

if [ -f "${DAEMON_FILE_PATH}" ]; then
    cat "${DAEMON_FILE_PATH}"
else
    echo '{}'
fi | jq --argjson daemonJson "${DAEMON_JSON}" '. + $daemonJson' | sudo tee /etc/docker/daemon.json

for i in $(seq 1 5); do
    [ $i -gt 1 ] && sleep 2;
    sudo service docker restart && EXIT_CODE=0 && break || EXIT_CODE=$?;
    if [ ${EXIT_CODE} != 0 ]; then
          sudo systemctl status docker.service
          sudo journalctl -xe
    fi
done;
exit $EXIT_CODE
