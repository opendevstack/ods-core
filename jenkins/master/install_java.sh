#!/bin/bash
set -eu -o pipefail

ME="$(basename $0)"
JAVA_INSTALLED_PKGS_LOGS="/tmp/java_installed_pkgs.log"

echo "${ME}: Listing versions of java installed: "
yum list installed | grep -i "\(java\|jre\)" | tee -a ${JAVA_INSTALLED_PKGS_LOGS}

if grep -qi "java-1.8" "${JAVA_INSTALLED_PKGS_LOGS}" ; then
    yum -y remove java-1.8*
else
    echo "${ME}: No java 1.8 packages to remove."
fi

rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum -y update
yum clean all
rm -rf /var/cache/yum/*

if grep -qi "java-11" "${JAVA_INSTALLED_PKGS_LOGS}" ; then
    echo "${ME}: Not installing java 11 because already installed. "
else
    yum -y install java-11*
fi

echo " "
echo "${ME}: Checking java tool versions: "
jar --version
java --version
