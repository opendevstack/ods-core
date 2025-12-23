#!/bin/bash
set -eu -o pipefail

JAVA_HOME_FOLDER=$(ls -lah /usr/lib/jvm | grep "java-17-openjdk-.*\.x86_64" | awk '{print $NF}' | head -1)
export JAVA_HOME="/usr/lib/jvm/${JAVA_HOME_FOLDER}"
export USE_JAVA_VERSION=java-17
alternatives --set java ${JAVA_HOME}/bin/java
