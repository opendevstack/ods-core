#!/bin/bash
set -eu -o pipefail

ME="$(basename $0)"
JAVA_INSTALLED_PKGS_LOGS="/tmp/java_installed_pkgs.log"
JAVA_11_INSTALLED_PKGS_LOGS="/tmp/java_11_installed_pkgs.log"
rm -fv ${JAVA_INSTALLED_PKGS_LOGS} ${JAVA_11_INSTALLED_PKGS_LOGS}

NEEDS_DEVEL=${1-""}
PKG_NAME_TAIL="headless"
if [ ! -z "${NEEDS_DEVEL}" ] && [ "" != "${NEEDS_DEVEL}" ]; then
    NEEDS_DEVEL="true"
    PKG_NAME_TAIL="devel"
else
    NEEDS_DEVEL="false"
    PKG_NAME_TAIL="headless"
fi

echo "${ME}: Needs development packages? ${NEEDS_DEVEL}"
echo " "
echo "${ME}: Listing versions of java installed: "
yum list installed | grep -i "\(java\|jre\)" | tee -a ${JAVA_INSTALLED_PKGS_LOGS}
touch ${JAVA_11_INSTALLED_PKGS_LOGS}
grep -i "java-11" ${JAVA_INSTALLED_PKGS_LOGS} > ${JAVA_11_INSTALLED_PKGS_LOGS} || echo "No java 11 packages found."

NEEDS_INSTALLATION="true"
if [ -f ${JAVA_11_INSTALLED_PKGS_LOGS} ]; then
    if grep -qi "${PKG_NAME_TAIL}" ${JAVA_11_INSTALLED_PKGS_LOGS} ; then
        NEEDS_INSTALLATION="false"
    fi
fi

# We need devel package in masters to have jar binary.
if [ "true" == "${NEEDS_INSTALLATION}" ]; then
    echo "${ME}:Java-11 is *not* installed. Installing..."
    if [ "true" == "${NEEDS_DEVEL}" ]; then
        yum -y install java-11-openjdk-devel
    else
        yum -y install java-11-openjdk-headless
    fi
else
    echo "${ME}: Java-11 is already installed."
fi

if grep -qi "java-1.8" ${JAVA_INSTALLED_PKGS_LOGS} ; then
    echo "${ME}: Java-8 is installed. Removing..."
    yum -y remove java-1.8*
else
    echo "${ME}: Java-8 is not installed. Correct."
fi

rm -fv ${JAVA_INSTALLED_PKGS_LOGS} ${JAVA_11_INSTALLED_PKGS_LOGS}

NO_JAVA_LINK="false"
java -version || NO_JAVA_LINK="true"
if [ "true" == "${NO_JAVA_LINK}" ]; then
    JAVA_HOME_FOLDER=$(ls -lah /usr/lib/jvm | grep "java-11-openjdk-11.*\.x86_64" | awk '{print $NF}' | head -1)
    JAVA_HOME="/usr/lib/jvm/${JAVA_HOME_FOLDER}"
    alternatives --set java ${JAVA_HOME}/bin/java
fi
java -version
