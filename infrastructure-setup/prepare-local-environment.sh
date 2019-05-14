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
vagrant ssh atlcon -c "cd /vagrant/ansible/ && export ANSIBLE_VAULT_PASSWORD_FILE=/vagrant/ansible/.vault_pass.txt && ansible-playbook -v -i inventories/dev playbooks/jira-enable-sso.yml"

echo "Step 2/10: Enable Confluence SSO"
cd ${cwd}
vagrant ssh atlcon -c "cd /vagrant/ansible/ && export ANSIBLE_VAULT_PASSWORD_FILE=/vagrant/ansible/.vault_pass.txt && ansible-playbook -v -i inventories/dev playbooks/confluence-enable-sso.yml"

echo "Step 3/10: Mirror repositories to ${TARGET_REPO_BASE}"
cd ${cwd}/scripts
./mirror-repositories-to-gitserver.sh

echo "Step 4/10: Connect to openshift VM and prepare OpenShift cluster"
vagrant ssh openshift -c "sudo /ods/ods-core/infrastructure-setup/scripts/prepare-openshift-cluster.sh"

sleep 5s

echo "Step 5/10: Add OpenShift certificate to atlassian VM"
vagrant ssh atlassian -c "sudo /ods/ods-core/infrastructure-setup/scripts/import-certificate-to-atlassian-jvm.sh"

echo "Step 6/10: Prepare Nexus"
vagrant ssh openshift -c "sudo /ods/ods-core/infrastructure-setup/scripts/prepare-nexus.sh"

echo "Step 7/10: Prepare Sonarqube"
vagrant ssh openshift -c "sudo /ods/ods-core/infrastructure-setup/scripts/prepare-sonarqube.sh"

echo "Step 8/10: Prepare Jenkins Builds"
vagrant ssh openshift -c "sudo /ods/ods-core/infrastructure-setup/scripts/prepare-jenkins-builds.sh"

echo "Step 9/10: Prepare Provisioning App"
vagrant ssh openshift -c "sudo /ods/ods-core/infrastructure-setup/scripts/prepare-provisioning-app.sh"

echo "Step 10/10: Prepare Rundeck"
vagrant ssh atlassian -c "sudo /ods/ods-core/infrastructure-setup/scripts/prepare-rundeck.sh"
