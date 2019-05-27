#!/usr/bin/env bash

export PATH=$PATH:/usr/local/bin/
BASE_DIR=${OPENDEVSTACK_BASE_DIR:-"/ods"}

source ${BASE_DIR}/local.env.config

cwd=${pwd}

if [ "$HOSTNAME" != "openshift" ] ; then
	echo "This script has to be executed on the openshift VM"
	exit
fi

oc login -u system:admin
oc project cd
cd /ods/ods-core/sonarqube/ocp-config
yes 'y' | tailor update -v --force

oc start-build -n cd sonarqube --follow

echo "Waiting for Sonarqube to get available"
while [ "$STATUS_CODE" != "200" ]
do
  sleep 5s
  echo -n "."
  STATUS_CODE=$(curl --insecure -s -o /dev/null -w %{http_code} https://sonarqube-cd.192.168.56.101.nip.io/)
done

echo -e "\nGo to https://sonarqube-cd.192.168.56.101.nip.io and log in with your crowd credentials."
echo "Generate a token in your Profile > Security Settings and proceed"
SONAR_TOKEN_INPUT=""
read -e -p "Enter your Sonar Auth Token and press [ENTER]: " input
SONAR_TOKEN_INPUT=${input:-""}

TOKEN_BASE64=`echo -n $SONAR_TOKEN_INPUT | base64`
echo ${sonar_admin_password_base64}
echo ${TOKEN_BASE64}

cd ${BASE_DIR}
find . -iname "sonarqube.env" -exec sed -i "s|AUTH_TOKEN=$sonar_admin_password_base64|AUTH_TOKEN=$TOKEN_BASE64|g" {} \;
find . -iname "templates.env" -exec sed -i "s|SONAR_SERVER_AUTH_TOKEN=$sonar_admin_password_base64|SONAR_SERVER_AUTH_TOKEN=$TOKEN_BASE64|g" {} \;
find . -iname "secret.env" -exec sed -i "s|SONAR_SERVER_AUTH_TOKEN=$sonar_admin_password_base64|SONAR_SERVER_AUTH_TOKEN=$TOKEN_BASE64|g" {} \;

cd ${BASE_DIR}/ods-project-quickstarters/ocp-templates/scripts/
./upload-templates.sh

oc project cd
cd /ods/ods-core/sonarqube/ocp-config
yes 'y' | tailor update -v --force
