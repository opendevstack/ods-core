#!/bin/bash
set -eu

# Initialize JAVA_HOME and set alternatives.
NO_JAVA_LINK="false"
java -version || NO_JAVA_LINK="true"
if [ "true" == "${NO_JAVA_LINK}" ]; then
    JAVA_HOME_FOLDER=$(ls -lah /usr/lib/jvm | grep "java-17-openjdk-.*\.x86_64" | awk '{print $NF}' | head -1)
    JAVA_HOME="/usr/lib/jvm/${JAVA_HOME_FOLDER}"
    alternatives --set java ${JAVA_HOME}/bin/java
fi
java -version

echo "Trying to setup correct permissions for cacerts folder... "
if [ ! -z "${JAVA_HOME}" ] && [ "" != "${JAVA_HOME}" ]; then
    chown -c 1001:0 $JAVA_HOME/lib/security/cacerts
    chmod -c g+w $JAVA_HOME/lib/security/cacerts
else
    echo "WARNING: Cannot apply permissions 'chmod g+w' to JAVA_HOME/lib/security/cacerts "
    echo "WARNING: JAVA_HOME=${JAVA_HOME}"
fi
