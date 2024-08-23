#!/bin/bash
set -eu

# Initialize JAVA_HOME if not set.
JAVA_HOME=${JAVA_HOME:-""}

if [ -f /etc/profile.d/set-default-java.sh ]; then
    source /etc/profile.d/set-default-java.sh
else
    echo "WARNING: Not setting default java version."
fi

echo "Trying to setup correct permissions for cacerts folder... "
if [ ! -z "${JAVA_HOME}" ] && [ "" != "${JAVA_HOME}" ]; then
    chown -c 1001:0 $JAVA_HOME/lib/security/cacerts
    chmod -c g+w $JAVA_HOME/lib/security/cacerts
else
    echo "WARNING: Cannot apply permissions 'chmod g+w' to JAVA_HOME/lib/security/cacerts "
    echo "WARNING: JAVA_HOME=${JAVA_HOME}"
fi
