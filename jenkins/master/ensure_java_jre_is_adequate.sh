#!/bin/bash
set -eu -o pipefail

ME="$(basename $0)"
JAVA_INSTALLED_PKGS_LOGS="/tmp/java_installed_pkgs.log"
JAVA_11_INSTALLED_PKGS_LOGS="/tmp/java_11_installed_pkgs.log"
rm -fv ${JAVA_INSTALLED_PKGS_LOGS} ${JAVA_11_INSTALLED_PKGS_LOGS}

echo "${ME}: Listing versions of java installed: "
yum list installed | grep -i "\(java\|jre\)" | tee -a ${JAVA_INSTALLED_PKGS_LOGS}
grep -i "java-11" ${JAVA_INSTALLED_PKGS_LOGS} > ${JAVA_11_INSTALLED_PKGS_LOGS}

if ! grep -qi "devel" ${JAVA_11_INSTALLED_PKGS_LOGS} ; then
    echo "${ME}:Java-11 is *not* installed. Installing..."
    yum -y install java-11-openjdk-devel
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

echo " "
echo "${ME}: Checking java tool versions: "
jar --version
java -version
