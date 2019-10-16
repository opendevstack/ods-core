#!/usr/bin/env bash

source ../../local.config

#current workdir
cwd=${PWD}
if [ ! -d "$OPENDEVSTACK_BASE_DIR/certs" ] ; then
  mkdir $OPENDEVSTACK_BASE_DIR/certs
fi

#Activate single sign on
echo "Step 1/10: Enable Jira SSO"
cd ${cwd}
read -e -n1 -p "Enable Jira SSO with Crowd? [y,n] (default: y):" input
input=${input:-"y"}
if [[ $input == "Y" || $input == "y" ]]; then
  vagrant ssh atlcon -c "cd /vagrant/ansible/ && export ANSIBLE_VAULT_PASSWORD_FILE=/vagrant/ansible/.vault_pass.txt && ansible-playbook -v -i inventories/dev playbooks/jira-enable-sso.yml"
fi


echo "Step 2/10: Enable Confluence SSO"
cd ${cwd}
read -e -n1 -p "Enable Confluence SSO with Crowd? [y,n] (default: y):" input
input=${input:-"y"}
if [[ $input == "Y" || $input == "y" ]]; then
  vagrant ssh atlcon -c "cd /vagrant/ansible/ && export ANSIBLE_VAULT_PASSWORD_FILE=/vagrant/ansible/.vault_pass.txt && ansible-playbook -v -i inventories/dev playbooks/confluence-enable-sso.yml"
fi

echo "Step 3/10: Mirror repositories to ${TARGET_REPO_BASE}"
cd ${cwd}/scripts
./mirror-repositories-to-gitserver.sh

echo "Step 4/10: Connect to openshift VM and prepare OpenShift cluster"
read -e -n1 -p "Configure OpenShift Cluster? [y,n] (default: y):" input
input=${input:-"y"}
if [[ $input == "Y" || $input == "y" ]]; then
  vagrant ssh openshift -c "sudo /ods/ods-core/infrastructure-setup/scripts/prepare-openshift-cluster.sh"
fi

sleep 5s

echo "Step 5/10: Add OpenShift certificate to atlassian VM"
read -e -n1 -p "Configure OpenShift certificates? [y,n] (default: y):" input
input=${input:-"y"}
if [[ $input == "Y" || $input == "y" ]]; then
  vagrant ssh atlassian -c "sudo /ods/ods-core/infrastructure-setup/scripts/import-certificate-to-atlassian-jvm.sh"
fi

echo "Step 6/10: Create local persistent volumes at openshift host"
read -e -n1 -p "Create local persistent volumes? [y,n] (default: y):" input
input=${input:-"y"}
if [[ $input == "Y" || $input == "y" ]]; then
  vagrant ssh openshift -c "sudo /ods/ods-core/infrastructure-setup/scripts/create-local-pv.sh"
fi


echo "Step 6/10: Prepare Nexus"
read -e -n1 -p "Prepare Nexus? [y,n] (default: y):" input
input=${input:-"y"}
if [[ $input == "Y" || $input == "y" ]]; then
  vagrant ssh openshift -c "sudo /ods/ods-core/infrastructure-setup/scripts/prepare-nexus.sh"
fi

echo "Step 7/10: Prepare Sonarqube"
read -e -n1 -p "Prepare Sonarqube? [y,n] (default: y):" input
input=${input:-"y"}
if [[ $input == "Y" || $input == "y" ]]; then
  vagrant ssh openshift -c "sudo /ods/ods-core/infrastructure-setup/scripts/prepare-sonarqube.sh"
fi

echo "Step 8/10: Prepare Jenkins Builds"
read -e -n1 -p "Prepare basic Jenkins Builds? [y,n] (default: y):" input
input=${input:-"y"}
if [[ $input == "Y" || $input == "y" ]]; then
  vagrant ssh openshift -c "sudo /ods/ods-core/infrastructure-setup/scripts/prepare-jenkins-builds.sh"
fi

echo "Step 9/11: Prepare Jenkins Slave Builds"
read -e -n1 -p "Do you want to build all Jenkins slaves? This will take some time. [y,n] (default: n):" input
input=${input:-"n"}
if [[ $input == "Y" || $input == "y" ]]; then
  vagrant ssh openshift -c "sudo /ods/ods-core/infrastructure-setup/scripts/prepare-jenkins-slave-builds.sh"
fi

echo "Step 10/11: Prepare Provisioning App"
read -e -n1 -p "Prepare Provisioning App? [y,n] (default: y):" input
input=${input:-"y"}
if [[ $input == "Y" || $input == "y" ]]; then
  vagrant ssh openshift -c "sudo /ods/ods-core/infrastructure-setup/scripts/prepare-provisioning-app.sh"
fi


echo "Step 11/11: Prepare Rundeck"
read -e -n1 -p "Prepare Rundeck? [y,n] (default: y):" input
input=${input:-"y"}
if [[ $input == "Y" || $input == "y" ]]; then
  vagrant ssh atlassian -c "sudo /ods/ods-core/infrastructure-setup/scripts/prepare-rundeck.sh"
fi

