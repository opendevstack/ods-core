#!/bin/bash
set -eu -o pipefail

ME="$(basename $0)"
echo "${ME}: Upgrading Jenkins to latest LTS version available..."

# sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
# sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
# sudo yum upgrade
# Add required dependencies for the jenkins package
# sudo yum install java-11-openjdk
# sudo yum install jenkins
# sudo systemctl daemon-reload

DEFAULT_TARGET="/usr/lib/jenkins/jenkins.war"
TARGET="${DEFAULT_TARGET}"

curl -sSLO https://get.jenkins.io/war-stable/latest/jenkins.war

if [ ! -f "${TARGET}" ]; then
    echo "${ME}: File does not exist: ${TARGET}"
    TARGET="$(find /usr/ -name jenkins.war)"
    echo "${ME}: New target: ${TARGET}"
fi

if [ -f "${TARGET}" ]; then
    echo "${ME}: Upgrading Jenkins to latest LTS version... "
    rm -fv ${TARGET}
    mv -vf jenkins.war ${TARGET}
    ls -lah ${TARGET}
else
    echo "${ME}: ERROR: Cannot upgrade Jenkins version."
    exit 1
fi

if [ ! -f "${DEFAULT_TARGET}" ]; then
    DEFAULT_TARGET_FOLDER="$(dirname ${DEFAULT_TARGET})"
    if [ ! -d ${DEFAULT_TARGET_FOLDER} ]; then
        mkdir -pv ${DEFAULT_TARGET_FOLDER}
    fi
    cd ${DEFAULT_TARGET_FOLDER} && ln -sv ${TARGET} .
fi
ls -la ${DEFAULT_TARGET} ${TARGET}
echo "${ME}: INFO: Jenkins was upgraded to latest LTS version."

