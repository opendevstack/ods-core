#!/usr/bin/env bash
# This scripts initializes the base varibale to use to setup a local development environment.
#
#Variables
ODS_DIR="../../.."
ODS_BASE_DIR=`realpath ${ODS_DIR}`

#ansible vault
vault_password="opendevstack"

#Openshift ClusterIp
clusterIp="192.168.56.101"
bitbucketHost="http://cd_user@192.168.56.31:7990/scm"

#Openshift local default Docker registry IP
docker_registry_ip=172.30.1.1:5000

#CD User
cd_user_name="cd_user"
cd_user_pw="cd_user"

#Nexus
nexus_password="developer"

#Sonarqube
sonar_admin_password="sonarqube"
sonar_crowd_password="sonarqube"
sonarqube_database_password="sonarqube"
sonar_server_auth_token=${sonar_admin_password}
sonar_crowd_auth=true

#rshiny
crowd_rshiny_realm_user="rshiny"
crowd_rshiny_realm_pw="rshiny"

#Pipeline Secret
pipeline_trigger_secret="secret101"

#Provision Application
provision_crowd_pw="provision"
provision_jasypt_pw="jasypt"
provision_mail_pw="mail"


echo -e "Basic configuration script for installation with vagrant, ansible and tailor\n"
echo -e "The default values reflect the changes, that have to be made to in the OKD templates before importing them with tailor\n"

echo -e "\nConfigure initial vault password (opendevstack) for installation and copy to ansible directory in .vault_pass.txt\n"
read -e -p "Enter your ansible vault password and press [ENTER] (default: $vault_password): " input
echo -e ${input:-$vault_password} > ../ansible/.vault_pass.txt

echo -e "\nOKD IP configuration\n"
read -e -p "Enter your OpenShift Cluster IP and press [ENTER] (default: $clusterIp): " input
clusterIp=${input:-$clusterIp}

echo -e "\nOKD docker registry configuration\n"
read -e -p "Enter your OpenShift Cluster internal Docker registry IP and press [ENTER] (default: $docker_registry_ip): " input
docker_registry_ip=${input:-$docker_registry_ip}

echo -e "\nBitbucket repo configuration\n"
read -e -p "Enter your local Bitbucket installation repository path and press [ENTER] (default: $bitbucketHost): " input
bitbucketHost=${input:-$bitbucketHost}

echo -e "\nCD user configuration\n"
read -e -p "Enter your CD user name [ENTER] (default: $cd_user_name): " input
cd_user_name=${input:-$cd_user_name}
read -e -p "Enter your CD user password [ENTER] (default: $cd_user_pw): " input
cd_user_pw=${input:-$cd_user_pw}

echo -e "\nNexus password configuration\n"
read -e -p "Enter your Nexus developer user password and press [ENTER] (default: $nexus_password): " input
nexus_password=${input:-$nexus_password}

echo -e "\nSonarqube configuration\n"
read -e -p "Enter Sonarqube admin password and press [ENTER] (default: $sonar_admin_password): " input
sonar_admin_password=${input:-$sonar_admin_password}
sonar_server_auth_token=${sonar_admin_password}
read -e -p "Enter Sonarqube Crowd password and press [ENTER] (default: $sonar_crowd_password): " input
sonar_crowd_password=${input:-$sonar_crowd_password}
read -e -p "Enter Sonarqube database password and press [ENTER] (default: $sonarqube_database_password): " input
sonarqube_database_password=${input:-$sonarqube_database_password}
read -e -p "Do you want to use Crowd for Sonarqube authentication (true or false) [ENTER] (default: $sonar_crowd_auth): " input
sonarqube_crowd_auth=${input:-$sonar_crowd_auth}

echo -e "\nRShiny configuration\n"
read -e -p "Enter your RShiny user name and press [ENTER] (default: $crowd_rshiny_realm_user): " input
crowd_rshiny_realm_user=${input:-$crowd_rshiny_realm_user}
read -e -p "Enter your RShiny user name and press [ENTER] (default: $crowd_rshiny_realm_pw): " input
crowd_rshiny_realm_pw=${input:-$crowd_rshiny_realm_pw}

echo -e "Pipeline secret configuration\n"
read -e -p "Enter your pipeline secret and press [ENTER] (default: $pipeline_trigger_secret): " input
pipeline_trigger_secret=${input:-$pipeline_trigger_secret}

echo -e "\nProvision application configuration\n"
read -e -p "Enter your provision application Crowd password and press [ENTER] (default: $provision_crowd_pw): " input
provision_crowd_pw=${input:-$provision_crowd_pw}

read -e -p "Enter your provision application jasypt password and press [ENTER] (default: $provision_jasypt_pw): " input
provision_jasypt_pw=${input:-$provision_jasypt_pw}

read -e -p "Enter your provision application mail password and press [ENTER] (default: $provision_mail_pw): " input
provision_mail_pw=${input:-$provision_mail_pw}

echo -e "\nWrite configuration to ${ODS_BASE_DIR}/local.env.config\n"


#Openshift ClusterIp
echo "#Configuration variables" > ${ODS_BASE_DIR}/local.env.config
echo "ODS_DIR=${ODS_BASE_DIR}" >> ${ODS_BASE_DIR}/local.env.config
echo "docker_registry_ip=${docker_registry_ip}" >> ${ODS_BASE_DIR}/local.env.config
echo "cluster_ip=${clusterIp}" >> ${ODS_BASE_DIR}/local.env.config
echo "bitbucket_host=${bitbucketHost}" >> ${ODS_BASE_DIR}/local.env.config
echo "cd_user_name=${cd_user_name}" >> ${ODS_BASE_DIR}/local.env.config
cd_user_name_base64=`echo -n $cd_user_name | base64`
echo "cd_user_name_base64=${cd_user_name_base64}" >> ${ODS_BASE_DIR}/local.env.config
echo "cd_user_pw=${cd_user_pw}" >> ${ODS_BASE_DIR}/local.env.config
cd_user_pw_base64=`echo -n $cd_user_pw | base64`
echo "cd_user_pw_base64=${cd_user_pw_base64}" >> ${ODS_BASE_DIR}/local.env.config

echo "nexus_password=${nexus_password}" >> ${ODS_BASE_DIR}/local.env.config
nexus_password_base64=`echo -n $nexus_password | base64`
echo "nexus_password_base64=${nexus_password_base64}" >> ${ODS_BASE_DIR}/local.env.config

echo "sonar_admin_password=${sonar_admin_password}" >> ${ODS_BASE_DIR}/local.env.config
sonar_admin_password_base64=`echo -n $sonar_admin_password | base64`
echo "sonar_admin_password_base64=${sonar_admin_password_base64}" >> ${ODS_BASE_DIR}/local.env.config

echo "sonar_crowd_password=${sonar_crowd_password}" >> ${ODS_BASE_DIR}/local.env.config
sonar_crowd_password_base64=`echo -n $sonar_crowd_password | base64`
echo "sonar_crowd_password_base64=${sonar_crowd_password_base64}" >> ${ODS_BASE_DIR}/local.env.config
echo "sonarqube_database_password=${sonarqube_database_password}" >> ${ODS_BASE_DIR}/local.env.config
sonarqube_database_password_base64=`echo -n $sonarqube_database_password | base64`
echo "sonarqube_database_password_base64=${sonarqube_database_password_base64}" >> ${ODS_BASE_DIR}/local.env.config
echo "sonarqube_crowd_auth=${sonarqube_crowd_auth}" >> ${ODS_BASE_DIR}/local.env.config


echo "crowd_rshiny_realm_user=${crowd_rshiny_realm_user}" >> ${ODS_BASE_DIR}/local.env.config
crowd_rshiny_realm_user_base64=`echo -n $crowd_rshiny_realm_user | base64`
echo "crowd_rshiny_realm_user_base64=${crowd_rshiny_realm_user_base64}" >> ${ODS_BASE_DIR}/local.env.config
echo "crowd_rshiny_realm_pw=${crowd_rshiny_realm_pw}" >> ${ODS_BASE_DIR}/local.env.config
crowd_rshiny_realm_pw_base64=`echo -n $crowd_rshiny_realm_pw | base64`
echo "crowd_rshiny_realm_pw_base64=${crowd_rshiny_realm_pw_base64}" >> ${ODS_BASE_DIR}/local.env.config

echo "pipeline_trigger_secret=${pipeline_trigger_secret}" >> ${ODS_BASE_DIR}/local.env.config
pipeline_trigger_secret_base64=`echo -n $pipeline_trigger_secret | base64`
echo "pipeline_trigger_secret_base64=${pipeline_trigger_secret_base64}" >> ${ODS_BASE_DIR}/local.env.config

echo "provision_crowd_pw=${provision_crowd_pw}" >> ${ODS_BASE_DIR}/local.env.config
echo "provision_jasypt_pw=${provision_jasypt_pw}" >> ${ODS_BASE_DIR}/local.env.config
echo "provision_mail_pw=${provision_mail_pw}" >> ${ODS_BASE_DIR}/local.env.config
