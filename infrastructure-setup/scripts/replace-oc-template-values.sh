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
find . -iname "*.env" -exec sed -i "s|CD_USER_ID_B64=.*$|CD_USER_ID_B64=$cd_user_name_base64|g" {} \;
echo -e "Set base64 encoded CD user password\n"
find . -iname "*.env" -exec sed -i "s|CD_USER_PWD_B64=.*$|CD_USER_PWD_B64=$cd_user_pw_base64|g" {} \;
echo -e "Set base64 encoded Nexus user password\n"
find . -iname "*.env" -exec sed -i "s|NEXUS_PASSWORD_B64=.*$|NEXUS_PASSWORD_B64=$nexus_password_base64|g" {} \;
echo -e "Set base64 encoded sonarqube auth token dummy value. Has to be changed after sonarqube has been installed and a valid token has been generated\n"
find . -iname "*.env" -exec sed -i "s|SONAR_AUTH_TOKEN_B64=.*$|SONAR_AUTH_TOKEN_B64=$sonar_admin_password_base64|g" {} \;
echo -e "Set if Crowd should be used for authentication\n"
find . -iname "*.env" -exec sed -i "s|SONAR_AUTH_CROWD=.*$|SONAR_AUTH_CROWD=$sonarqube_crowd_auth|g" {} \;
echo -e "Set base64 encoded sonarqube admin password value\n"
find . -iname "*.env" -exec sed -i "s|SONAR_ADMIN_PASSWORD_B64=.*$|SONAR_ADMIN_PASSWORD_B64=$sonar_admin_password_base64|g" {} \;
echo -e "Set base64 encoded sonarqube crowd password value\n"
find . -iname "*.env" -exec sed -i "s|SONAR_CROWD_PASSWORD_B64=.*$|SONAR_CROWD_PASSWORD_B64=$sonar_crowd_password_base64|g" {} \;
echo -e "Set base64 encoded sonarqube database password value\n"
find . -iname "*.env" -exec sed -i "s|SONAR_DATABASE_PASSWORD_B64=.*$|SONAR_DATABASE_PASSWORD_B64=$sonarqube_database_password_base64|g" {} \;

echo -e "Set base64 encoded Crowd RShiny user name value\n"
find . -iname "*.env" -exec sed -i "s|CROWD_RSHINY_REALM_USER_B64=.*$|CROWD_RSHINY_REALM_USER_B64=$crowd_rshiny_realm_user_base64|g" {} \;
echo -e "Set base64 encoded Crowd RShiny user password value\n"
find . -iname "*.env" -exec sed -i "s|CROWD_RSHINY_REALM_PW_B64=.*$|CROWD_RSHINY_REALM_PW_B64=$crowd_rshiny_realm_pw_base64|g" {} \;

echo -e "Set base64 encoded pipeline trigger secret\n"
find . -iname "*.env" -exec sed -i "s|PIPELINE_TRIGGER_SECRET_B64=.*$|PIPELINE_TRIGGER_SECRET_B64=$pipeline_trigger_secret_base64|g" {} \;

echo -e "Set pipeline trigger secret\n"
find . -iname "cm.env" -exec sed -i "s|PIPELINE_TRIGGER_SECRET=.*$|PIPELINE_TRIGGER_SECRET=$pipeline_trigger_secret|g" {} \;
find . -iname "bc.env" -exec sed -i "s|PIPELINE_TRIGGER_SECRET=.*$|PIPELINE_TRIGGER_SECRET=$pipeline_trigger_secret|g" {} \;

echo -e "Set docker registry for local development\n"
find . -iname "*.env" -exec sed -i "s|DOCKER_REGISTRY=docker-registry.default.svc:5000|DOCKER_REGISTRY=$docker_registry_ip|g" {} \;


#Provision Application
echo -e "Set provision application crowd password\n"
find . -iname "cm.env" -exec sed -i "s|PROV_APP_CROWD_PASSWORD=.*$|PROV_APP_CROWD_PASSWORD=$provision_crowd_pw|g" {} \;
echo -e "Set provision application jasypt password\n"
find . -iname "cm.env" -exec sed -i "s|PROV_APP_JASYPT_PASSWORD=.*$|PROV_APP_JASYPT_PASSWORD=$provision_jasypt_pw|g" {} \;
echo -e "Set provision application mail password\n"
find . -iname "cm.env" -exec sed -i "s|PROV_APP_MAIL_PASSWORD=.*$|PROV_APP_MAIL_PASSWORD=$provision_mail_pw|g" {} \;
echo -e "Set provision application developer nexus password\n"
find . -iname "*.env" -exec sed -i "s|NEXUS_AUTH=developer:.*$|NEXUS_AUTH=developer:$nexus_password|g" {} \;

echo -e "Search if there are still values that have to be base64 encoded. This has to be done manually.\n"
find . -iname "*.env" -exec grep -H 'base64' {} \;

echo -n
echo -e "Find entries that have to be changed. This has to be done manually.\n"
find . -iname "*.env" -exec grep -H 'chang*' {} \;

cd $cwd
