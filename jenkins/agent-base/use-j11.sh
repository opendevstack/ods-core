#!/bin/bash

JAVA_HOME_FOLDER=$(ls -lah /usr/lib/jvm | grep "java-11-openjdk-11.*\.x86_64" | awk '{print $NF}' | head -1)
JAVA_VERSION="11"

function msg_and_exit() {
  echo "ERROR: ${1}"
  exit 1
}

echo "Switching to java ${JAVA_VERSION}:"
JAVA_HOME="/usr/lib/jvm/${JAVA_HOME_FOLDER}"

alternatives --set java ${JAVA_HOME}/bin/java || \
  msg_and_exit "Cannot configure java ${JAVA_VERSION} as the alternative to use for java."
java -version 2>&1 | grep -q "\s\+${JAVA_VERSION}" || msg_and_exit "Java version is not ${JAVA_VERSION}."

if [ -x ${JAVA_HOME}/bin/javac ]; then
  alternatives --set javac ${JAVA_HOME}/bin/javac || \
    msg_and_exit "Cannot configure javac ${JAVA_VERSION} as the alternative to use for javac."
  javac -version 2>&1 | grep -q "\s\+${JAVA_VERSION}" || msg_and_exit "Javac version is not ${JAVA_VERSION}."
else
  echo "WARNING: Not found binary for javac in path ${JAVA_HOME}/bin/javac "
fi

java -version 2>&1
if which 'javac'; then
  javac -version 2>&1
else
  echo "WARNING: Binary javac is not available."
fi

if [ -d ${JAVA_HOME}/bin/ ]; then
  export JAVA_HOME
else
  msg_and_exit "Cannot configure JAVA_HOME environment variable to ${JAVA_HOME}"
fi
echo "JAVA_HOME: $JAVA_HOME"
