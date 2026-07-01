#!/bin/bash
set -eu -o pipefail

JAVA_VERSION="21"
JAVA_HOME_FOLDER=$(ls -lah /usr/lib/jvm | grep "java-${JAVA_VERSION}-openjdk-.*\.x86_64" | awk '{print $NF}' | head -1)
export JAVA_HOME="/usr/lib/jvm/${JAVA_HOME_FOLDER}"
export USE_JAVA_VERSION=java-${JAVA_VERSION}
alternatives --set java ${JAVA_HOME}/bin/java
