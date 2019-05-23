#!/usr/bin/env bash

#current workdir
cwd=${PWD}

#change to base dir
cd ../..

#set base dir
OPENDEVSTACK_BASE_DIR=${PWD}

#write base dir to local config file

if [ ! -f "${OPENDEVSTACK_BASE_DIR}/local.config" ] ; then
  echo "Write base directory for installation to local config file ${OPENDEVSTACK_BASE_DIR}/local.config"
  echo "OPENDEVSTACK_BASE_DIR=${PWD}" > ${OPENDEVSTACK_BASE_DIR}/local.config
else
  echo "Local config file exists"
fi

echo "Step 1/9: Ensure ods-core is up to date"
cd ${cwd}/..
git pull

echo "Step 2/9: Create production branch and work from there"
cd ${cwd}/..
git checkout -b production

echo "Step 3/9: Clone necessary repositories and create production branch"
cd ${cwd}/scripts
./checkout-repositories.sh

echo "Step 4/9: Configure necessary parameters for the openshift cluster environment and templates"
cd ${cwd}/scripts
./configure-oc-template-variables.sh

echo "Step 5/9: Create configuration"
cd ${cwd}/scripts
./create-configuration-from-sample.sh

echo "Step 6/9: Replace ENV variables with preconfigured values"
cd ${cwd}/scripts
./replace-oc-template-values.sh

echo "Step 7/9: Init local Git repository for configuration"
cd ${OPENDEVSTACK_BASE_DIR}
cd ods-configuration
git init
git add --all
git commit -m "Initial configuration commit"
git checkout -b production

echo "Step 8/9: Setup and start VMs from Vagrant"
#start vagrant
cd ${cwd}
read -e -n1 -p "Use Vagrant VMs? [y,n] (default: y):" input
input=${input:-"y"}
if [[ $input == "Y" || $input == "y" ]]; then
  vagrant up
fi

echo "Step 9/9: Base Installations with ansible"
cd ${cwd}
read -e -n1 -p "Install the whole stack on hosts defined in ansible inventory? If you want to install the stack step by step, choose n. [y,n] (default: y):" input
input=${input:-"y"}
if [[ $input == "Y" || $input == "y" ]]; then
  vagrant ssh atlcon -c "cd /vagrant/ansible/ && export ANSIBLE_VAULT_PASSWORD_FILE=/vagrant/ansible/.vault_pass.txt && ansible-playbook -v -i inventories/dev dev.yml"
else
  echo "Prepare hosts"
  vagrant ssh atlcon -c "cd /vagrant/ansible/ && export ANSIBLE_VAULT_PASSWORD_FILE=/vagrant/ansible/.vault_pass.txt && ansible-playbook -v -i inventories/dev playbooks/prepare-environment.yml"
  read -e -n1 -p "Install database and create schemas? [y,n] (default: y):" input
  input=${input:-"y"}
  if [[ $input == "Y" || $input == "y" ]]; then
     vagrant ssh atlcon -c "cd /vagrant/ansible/ && export ANSIBLE_VAULT_PASSWORD_FILE=/vagrant/ansible/.vault_pass.txt && ansible-playbook -v -i inventories/dev playbooks/install-database.yml"
  fi
  echo "Install Atlassian tools"
  read -e -n1 -p "Install Atlassian Crowd? [y,n] (default: y):" input
  input=${input:-"y"}
  if [[ $input == "Y" || $input == "y" ]]; then
     vagrant ssh atlcon -c "cd /vagrant/ansible/ && export ANSIBLE_VAULT_PASSWORD_FILE=/vagrant/ansible/.vault_pass.txt && ansible-playbook -v -i inventories/dev playbooks/crowd.yml"
  fi
  read -e -n1 -p "Install Atlassian Jira? [y,n] (default: y):" input
  input=${input:-"y"}
  if [[ $input == "Y" || $input == "y" ]]; then
     vagrant ssh atlcon -c "cd /vagrant/ansible/ && export ANSIBLE_VAULT_PASSWORD_FILE=/vagrant/ansible/.vault_pass.txt && ansible-playbook -v -i inventories/dev playbooks/jira.yml"
  fi
  read -e -n1 -p "Install Atlassian Confluence? [y,n] (default: y):" input
  input=${input:-"y"}
  if [[ $input == "Y" || $input == "y" ]]; then
     vagrant ssh atlcon -c "cd /vagrant/ansible/ && export ANSIBLE_VAULT_PASSWORD_FILE=/vagrant/ansible/.vault_pass.txt && ansible-playbook -v -i inventories/dev playbooks/confluence.yml"
  fi
  read -e -n1 -p "Install Atlassian Bitbucket? [y,n] (default: y):" input
  input=${input:-"y"}
  if [[ $input == "Y" || $input == "y" ]]; then
     vagrant ssh atlcon -c "cd /vagrant/ansible/ && export ANSIBLE_VAULT_PASSWORD_FILE=/vagrant/ansible/.vault_pass.txt && ansible-playbook -v -i inventories/dev playbooks/bitbucket.yml"
  fi
  echo "Rundeck Installation"
  read -e -n1 -p "Install Rundeck? [y,n] (default: y):" input
  input=${input:-"y"}
  if [[ $input == "Y" || $input == "y" ]]; then
     vagrant ssh atlcon -c "cd /vagrant/ansible/ && export ANSIBLE_VAULT_PASSWORD_FILE=/vagrant/ansible/.vault_pass.txt && ansible-playbook -v -i inventories/dev playbooks/rundeck.yml"
  fi
  echo "OKD installation"
  read -e -n1 -p "Install OpenShift? [y,n] (default: y):" input
  input=${input:-"y"}
  if [[ $input == "Y" || $input == "y" ]]; then
     vagrant ssh atlcon -c "cd /vagrant/ansible/ && export ANSIBLE_VAULT_PASSWORD_FILE=/vagrant/ansible/.vault_pass.txt && ansible-playbook -v -i inventories/dev playbooks/install-openshift-dev.yml"
  fi
fi

cd ${cwd}

echo "Before proceeding with the installation in script ${cwd}/prepare-local-environment.sh , ensure your atlassian tools will be configured properly and the CD user has been set up"
echo "Atlassian tool addresses: "
echo "Crowd: http://192.168.56.31:8095/"
echo "Jira: http://192.168.56.31:8080/"
echo "Confluence: http://192.168.56.31:8090/"
echo "Bitbucket: http://192.168.56.31:7990/"
