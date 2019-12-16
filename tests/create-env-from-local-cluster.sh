#!/usr/bin/env bash

BASE_OC_DIR="${HOME}/openshift.local.clusterup"

function usage() {

  exit
}

while [ "$1" != "" ]; do
  case $1 in
  -b | --base-oc-dir)
    shift
    BASE_OC_DIR=$1
    ;;
  -o | --output)
    shift
    OUTPUT=$1
    ;;
  -h | --help)
    usage
    exit
    ;;
  *)
    usage
    exit 1
    ;;
  esac
  shift
done

if [[ -z "${BASE_OC_DIR}" && ! -d "${BASE_OC_DIR}" ]]; then
  echo "--base-oc-dir must be provided and pointing to the oc cluster base diretory."
  usage
fi

SUBDOMAIN=$(grep -A 1 routingConfig "${BASE_OC_DIR}/openshift-apiserver/master-config.yaml" | tail -n1 | awk '{print $2}')

echo "ODS_IMAGE_TAG=latest" > ${OUTPUT}
echo "ODS_IMAGE_TAG=production" >> ${OUTPUT}
echo "" >> ${OUTPUT}
echo "#####-#####-#####-#####-#####" >> ${OUTPUT}
echo "#####       NEXUS       #####" >> ${OUTPUT}
echo "#####-#####-#####-#####-#####" >> ${OUTPUT}
echo "" >> ${OUTPUT}
NEXUS_HOST="nexus-cd.${SUBDOMAIN}"
NEXUS_URL="https://${NEXUS_HOST}"
NEXUS_USERNAME=developer
NEXUS_PASSWORD=$(dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64  | rev | cut -b 2- | rev | tr -cd '[:alnum:]')
NEXUS_PASSWORD_B64=$(echo -n "${NEXUS_PASSWORD}" | base64)
NEXUS_AUTH="${NEXUS_USERNAME}:${NEXUS_PASSWORD}"

echo "NEXUS_URL=${NEXUS_URL}" >> ${OUTPUT}
echo "NEXUS_HOST=${NEXUS_HOST}" >> ${OUTPUT}
echo "NEXUS_USERNAME=${NEXUS_USERNAME}" >> ${OUTPUT}
echo "NEXUS_PASSWORD=${NEXUS_PASSWORD}" >> ${OUTPUT}
echo "NEXUS_PASSWORD_B64=${NEXUS_PASSWORD_B64}" >> ${OUTPUT}
echo "NEXUS_AUTH=${NEXUS_AUTH}" >> ${OUTPUT}

echo "" >> ${OUTPUT}
echo "#####-#####-#####-#####-#####" >> ${OUTPUT}
echo "#####     SonarQube     #####" >> ${OUTPUT}
echo "#####-#####-#####-#####-#####" >> ${OUTPUT}
echo "" >> ${OUTPUT}

SONARQUBE_HOST="sonarqube-cd.${SUBDOMAIN}"

# SonarQube URL exposed by the SonarQube route
SONARQUBE_URL="https://${SONARQUBE_HOST}"

# Username and password for SonarQube
SONAR_ADMIN_USERNAME="admin"
SONAR_PASSWORD=$(dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64  | rev | cut -b 2- | rev | tr -cd '[:alnum:]')
SONAR_PASSWORD_B64=$(echo -n "${SONAR_PASSWORD}" | base64)
SONAR_AUTH_TOKEN="${SONAR_ADMIN_USERNAME}:${SONAR_PASSWORD}"
SONAR_AUTH_TOKEN_B64=$(echo -n "${SONAR_AUTH_TOKEN}" | base64)

# Application in Crowd used for authentication
SONAR_CROWD_APPLICATION=sonarqube
SONAR_CROWD_PASSWORD=$(dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64  | rev | cut -b 2- | rev | tr -cd '[:alnum:]')
SONAR_CROWD_PASSWORD_B64=$(echo -n "${SONAR_CROWD_PASSWORD}" | base64)

# Postgres DB for SonarQube
SONAR_DATABASE_JDBC_URL=jdbc:postgresql://sonarqube-postgresql.svc:5432/sonarqube
SONAR_DATABASE_NAME=sonarqube
SONAR_DATABASE_USER=sonarqube
SONAR_DATABASE_PASSWORD=$(dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64  | rev | cut -b 2- | rev | tr -cd '[:alnum:]')
SONAR_DATABASE_PASSWORD_B64=$(echo -n "${SONAR_DATABASE_PASSWORD}" | base64)

#SonarQube Download
SONAR_VERSION=7.9
SONAR_DISTRIBUTION_URL="https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip"
SONAR_AUTH_CROWD=false


echo "SONARQUBE_HOST=${SONARQUBE_HOST}" >> ${OUTPUT}
echo "SONARQUBE_URL=${SONARQUBE_URL}" >> ${OUTPUT}
echo "SONAR_ADMIN_USERNAME=${SONAR_ADMIN_USERNAME}" >> ${OUTPUT}
echo "SONAR_PASSWORD=${SONAR_PASSWORD}" >> ${OUTPUT}
echo "SONAR_PASSWORD_B64=${SONAR_PASSWORD_B64}" >> ${OUTPUT}
echo "SONAR_AUTH_TOKEN=${SONAR_AUTH_TOKEN}" >> ${OUTPUT}
echo "SONAR_AUTH_TOKEN_B64=${SONAR_AUTH_TOKEN_B64}" >> ${OUTPUT}
echo "SONAR_CROWD_APPLICATION=${SONAR_CROWD_APPLICATION}" >> ${OUTPUT}
echo "SONAR_CROWD_PASSWORD=${SONAR_CROWD_PASSWORD}" >> ${OUTPUT}
echo "SONAR_CROWD_PASSWORD_B64=${SONAR_CROWD_PASSWORD_B64}" >> ${OUTPUT}
echo "SONAR_DATABASE_JDBC_URL=${SONAR_DATABASE_JDBC_URL}" >> ${OUTPUT}
echo "SONAR_DATABASE_NAME=${SONAR_DATABASE_NAME}" >> ${OUTPUT}
echo "SONAR_DATABASE_USER=${SONAR_DATABASE_USER}" >> ${OUTPUT}
echo "SONAR_DATABASE_PASSWORD=${SONAR_DATABASE_PASSWORD}" >> ${OUTPUT}
echo "SONAR_DATABASE_PASSWORD_B64=${SONAR_DATABASE_PASSWORD_B64}" >> ${OUTPUT}
echo "SONAR_VERSION=${SONAR_VERSION}" >> ${OUTPUT}
echo "SONAR_DISTRIBUTION_URL=${SONAR_DISTRIBUTION_URL}" >> ${OUTPUT}
echo "SONAR_AUTH_CROWD=${SONAR_AUTH_CROWD}" >> ${OUTPUT}

echo "" >> ${OUTPUT}
echo "#####-#####-#####-#####-#####" >> ${OUTPUT}
echo "#####       Jira        #####" >> ${OUTPUT}
echo "#####-#####-#####-#####-#####" >> ${OUTPUT}
echo "" >> ${OUTPUT}

echo "JIRA_URL=https://jira-cd.${SUBDOMAIN}" >> ${OUTPUT}

echo "" >> ${OUTPUT}
echo "#####-#####-#####-#####-#####" >> ${OUTPUT}
echo "#####       Crowd       #####" >> ${OUTPUT}
echo "#####-#####-#####-#####-#####" >> ${OUTPUT}
echo "" >> ${OUTPUT}

echo "CROWD_URL=https://crowd-cd.${SUBDOMAIN}" >> ${OUTPUT}

echo "" >> ${OUTPUT}
echo "#####-#####-#####-#####-#####" >> ${OUTPUT}
echo "#####     BitBucket     #####" >> ${OUTPUT}
echo "#####-#####-#####-#####-#####" >> ${OUTPUT}
echo "" >> ${OUTPUT}

BITBUCKET_HOST=bitbucket-cd.${SUBDOMAIN}
REPO_BASE=https://bitbucket-cd.${SUBDOMAIN}/scm

CD_USER_ID=cd_user
CD_USER_ID_B64=$(echo -n "${CD_USER_ID}" | base64)
CD_USER_PWD=$(dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64  | rev | cut -b 2- | rev | tr -cd '[:alnum:]')
CD_USER_PWD_B64=$(echo -n "${CD_USER_PWD}" | base64)

echo "BITBUCKET_HOST=${BITBUCKET_HOST}" >> ${OUTPUT}
echo "REPO_BASE=${REPO_BASE}" >> ${OUTPUT}
echo "CD_USER_ID=${CD_USER_ID}" >> ${OUTPUT}
echo "CD_USER_ID_B64=${CD_USER_ID_B64}" >> ${OUTPUT}
echo "CD_USER_PWD=${CD_USER_PWD}" >> ${OUTPUT}
echo "CD_USER_PWD_B64=${CD_USER_PWD_B64}" >> ${OUTPUT}

echo "" >> ${OUTPUT}
echo "#####-#####-#####-#####-#####" >> ${OUTPUT}
echo "#####      Jenkins      #####" >> ${OUTPUT}
echo "#####-#####-#####-#####-#####" >> ${OUTPUT}
echo "" >> ${OUTPUT}

echo "JENKINS_AGENT_BASE_IMAGE=Dockerfile.centos7" >> ${OUTPUT}
echo "JENKINS_AGENT_BASE_FROM_IMAGE=openshift/jenkins-slave-base-centos7" >> ${OUTPUT}
echo "JENKINS_AGENT_BASE_SNYK_DISTRIBUTION_URL=https://github.com/snyk/snyk/releases/download/v1.180.1/snyk-linux" >> ${OUTPUT}


echo "" >> ${OUTPUT}
echo "#####-#####-#####-#####-#####" >> ${OUTPUT}
echo "#####     OpenShift     #####" >> ${OUTPUT}
echo "#####-#####-#####-#####-#####" >> ${OUTPUT}
echo "" >> ${OUTPUT}

DOCKER_REGISTRY=172.30.1.1:5000
APP_DNS="${SUBDOMAIN}"
TARGET_HOSTS=
OPENSHIFT_API_HOST=https://127.0.0.1:8443
OPENSHIFT_CONSOLE_HOST=https://127.0.0.1:8443
OPENSHIFT_APPS_BASEDOMAIN=".${APP_DNS}"
PIPELINE_TRIGGER_SECRET=$(dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64  | rev | cut -b 2- | rev | tr -cd '[:alnum:]')
PIPELINE_TRIGGER_SECRET_B64=$(echo -n "${PIPELINE_TRIGGER_SECRET}" | base64)

echo "DOCKER_REGISTRY=${DOCKER_REGISTRY}" >> ${OUTPUT}
echo "APP_DNS=${APP_DNS}" >> ${OUTPUT}
echo "TARGET_HOSTS=${TARGET_HOSTS}" >> ${OUTPUT}
echo "OPENSHIFT_API_HOST=${OPENSHIFT_API_HOST}" >> ${OUTPUT}
echo "OPENSHIFT_CONSOLE_HOST=${OPENSHIFT_CONSOLE_HOST}" >> ${OUTPUT}
echo "OPENSHIFT_APPS_BASEDOMAIN=${OPENSHIFT_APPS_BASEDOMAIN}" >> ${OUTPUT}
echo "PIPELINE_TRIGGER_SECRET=${PIPELINE_TRIGGER_SECRET}" >> ${OUTPUT}
echo "PIPELINE_TRIGGER_SECRET_B64=${PIPELINE_TRIGGER_SECRET_B64}" >> ${OUTPUT}

echo "" >> ${OUTPUT}
echo "#####-#####-#####-#####-#####" >> ${OUTPUT}
echo "##### Identity Provider #####" >> ${OUTPUT}
echo "#####-#####-#####-#####-#####" >> ${OUTPUT}
echo "" >> ${OUTPUT}

echo "IDP_DNS=${SUBDOMAIN}" >> ${OUTPUT}

echo "" >> ${OUTPUT}
echo "#####-#####-#####-#####-#####" >> ${OUTPUT}
echo "#####      Storage      #####" >> ${OUTPUT}
echo "#####-#####-#####-#####-#####" >> ${OUTPUT}
echo "" >> ${OUTPUT}

echo "STORAGE_PROVISIONER=" >> ${OUTPUT}
echo "STORAGE_CLASS_DATA=" >> ${OUTPUT}
echo "STORAGE_CLASS_BACKUP=" >> ${OUTPUT}
