#!/usr/bin/env bash

source ../../local.config

#current workdir
cwd=${PWD}
if [ ! -d "$OPENDEVSTACK_BASE_DIR/certs" ] ; then
  mkdir $OPENDEVSTACK_BASE_DIR/certs
fi

echo "Enable Jira SSO"
cd ${cwd}
read -e -n1 -p "Enable Jira SSO with Crowd? [y,n] (default: y):" input
input=${input:-"y"}
if [[ $input == "Y" || $input == "y" ]]; then
  vagrant ssh atlcon -c "cd /vagrant/ansible/ && export ANSIBLE_VAULT_PASSWORD_FILE=/vagrant/ansible/.vault_pass.txt && ansible-playbook -v -i inventories/dev playbooks/jira-enable-sso.yml"
fi

echo "Enable Confluence SSO"
cd ${cwd}
read -e -n1 -p "Enable Confluence SSO with Crowd? [y,n] (default: y):" input
input=${input:-"y"}
if [[ $input == "Y" || $input == "y" ]]; then
  vagrant ssh atlcon -c "cd /vagrant/ansible/ && export ANSIBLE_VAULT_PASSWORD_FILE=/vagrant/ansible/.vault_pass.txt && ansible-playbook -v -i inventories/dev playbooks/confluence-enable-sso.yml"
fi

echo "Add OpenShift certificate to atlassian VM"
read -e -n1 -p "Configure OpenShift certificates? [y,n] (default: y):" input
input=${input:-"y"}
if [[ $input == "Y" || $input == "y" ]]; then
  vagrant ssh atlassian -c "sudo /ods/ods-core/infrastructure-setup/scripts/import-certificate-to-atlassian-jvm.sh"
fi
