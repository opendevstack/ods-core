#!/usr/bin/env bash

#define variables
base_dir="../../.."
cwd=${PWD} 

cd $base_dir

source local.env.config

echo -e "Replace OKD cluster IP, set to $cluster_ip \n"
find . -iname "*.env" -exec sed -i "s|192.168.99.100|$cluster_ip|g" {} \;

echo -e "Replace repository base, set to $bitbucket_host \n"
find . -iname "*.env" -exec sed -i "s|https://github.com|$bitbucket_host|g" {} \;

echo -e "Set base64 encoded CD user name\n"
find . -iname "*.env" -exec sed -i "s|CD_USER_ID=.*$|CD_USER_ID=$cd_user_name_base64|g" {} \;
echo -e "Set base64 encoded CD user password\n"
find . -iname "*.env" -exec sed -i "s|CD_USER_PWD=.*$|CD_USER_PWD=$cd_user_pw_base64|g" {} \;
echo -e "Set base64 encoded Nexus user password\n"
find . -iname "*.env" -exec sed -i "s|NEXUS_PASSWORD=.*$|NEXUS_PASSWORD=$nexus_password_base64|g" {} \;
echo -e "Set base64 encoded sonarqube auth token dummy value. Has to be changed after sonarqube has been installed and a valid token has been generated\n"
find . -iname "*.env" -exec sed -i "s|SONAR_SERVER_AUTH_TOKEN=.*$|SONAR_SERVER_AUTH_TOKEN=$sonar_admin_password_base64|g" {} \;
echo -e "Set if Crowd should be used for authentication\n"
find . -iname "*.env" -exec sed -i "s|SONAR_AUTH_CROWD=.*$|SONAR_AUTH_CROWD=$sonarqube_crowd_auth|g" {} \;

find . -iname "*.env" -exec sed -i "s|AUTH_TOKEN=.*$|AUTH_TOKEN=$sonar_admin_password_base64|g" {} \;
echo -e "Set base64 encoded sonarqube admin password value\n"
find . -iname "*.env" -exec sed -i "s|ADMIN_PASSWORD=.*$|ADMIN_PASSWORD=$sonar_admin_password_base64|g" {} \;
echo -e "Set base64 encoded sonarqube crowd password value\n"
find . -iname "*.env" -exec sed -i "s|CROWD_PASSWORD=.*$|CROWD_PASSWORD=$sonar_crowd_password_base64|g" {} \;
echo -e "Set base64 encoded sonarqube database password value\n"
find . -iname "*.env" -exec sed -i "s|DATABASE_PASSWORD=.*$|DATABASE_PASSWORD=$sonarqube_database_password_base64|g" {} \;

echo -e "Set base64 encoded Crowd RShiny user name value\n"
find . -iname "*.env" -exec sed -i "s|CROWD_RSHINY_REALM_USER=.*$|CROWD_RSHINY_REALM_USER=$crowd_rshiny_realm_user_base64|g" {} \;
echo -e "Set base64 encoded Crowd RShiny user password value\n"
find . -iname "*.env" -exec sed -i "s|CROWD_RSHINY_REALM_PW=.*$|CROWD_RSHINY_REALM_PW=$crowd_rshiny_realm_pw_base64|g" {} \;

echo -e "Set base64 encoded pipeline trigger secret\n"
find . -iname "*.env" -exec sed -i "s|PIPELINE_TRIGGER_SECRET=.*$|PIPELINE_TRIGGER_SECRET=$pipeline_trigger_secret_base64|g" {} \;

echo -e "Set pipeline trigger secret\n"
find . -iname "cm.env" -exec sed -i "s|PIPELINE_TRIGGER_SECRET=.*$|PIPELINE_TRIGGER_SECRET=$pipeline_trigger_secret|g" {} \;
find . -iname "bc.env" -exec sed -i "s|PIPELINE_TRIGGER_SECRET=.*$|PIPELINE_TRIGGER_SECRET=$pipeline_trigger_secret|g" {} \;

echo -e "Set docker registry for local development\n"
find . -iname "*.env" -exec sed -i "s|DOCKER_REGISTRY=docker-registry.default.svc:5000|DOCKER_REGISTRY=$docker_registry_ip|g" {} \;


#Provision Application
echo -e "Set provision application crowd password\n"
find . -iname "cm.env" -exec sed -i "s|CROWD_PASSWORD=.*$|CROWD_PASSWORD=$provision_crowd_pw|g" {} \;
echo -e "Set provision application jasypt password\n"
find . -iname "cm.env" -exec sed -i "s|JASYPT_PASSWORD=.*$|JASYPT_PASSWORD=$provision_jasypt_pw|g" {} \;
echo -e "Set provision application mail password\n"
find . -iname "cm.env" -exec sed -i "s|MAIL_PASSWORD=.*$|MAIL_PASSWORD=$provision_mail_pw|g" {} \;
echo -e "Set provision application developer nexus password\n"
find . -iname "*.env" -exec sed -i "s|NEXUS_AUTH=developer:.*$|NEXUS_AUTH=developer:$nexus_password|g" {} \;

echo -e "Search if there are still values that have to be base64 encoded. This has to be done manually.\n"
find . -iname "*.env" -exec grep -H 'base64' {} \;

echo -n
echo -e "Find entries that have to be changed. This has to be done manually.\n"
find . -iname "*.env" -exec grep -H 'chang*' {} \;

cd $cwd
