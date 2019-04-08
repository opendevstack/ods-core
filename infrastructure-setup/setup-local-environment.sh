#!/usr/bin/env bash

#current workdir
cwd=${PWD}

#change to base dir
cd ../..

#set base dir
OPENDEVSTACK_BASE_DIR=${PWD}

#write base dir to local config file
echo "Write base directory for installtion to local config file ${OPENDEVSTACK_BASE_DIR}/local.config"
echo "OPENDEVSTACK_BASE_DIR=${PWD}" > ${OPENDEVSTACK_BASE_DIR}/local.config

echo "Step 1/X: Ensure ods-core is up to date"
cd ${cwd}/..
git pull

echo "Step 2/X: Create production branch and work from there"
cd ${cwd}/..
git checkout production

echo "Step 3/X: Clone necessary repositories and create production branch"
cd ${cwd}/scripts
./checkout-repositories.sh

echo "Step 4/X: Configure necessary parameters for the openshift cluster environment and templates"
cd ${cwd}/scripts
./configure-oc-template-variables.sh

echo "Step 5/X: Create configuration"
cd ${cwd}/scripts
./create-configuration-from-sample.sh

echo "Step 6/X: Replace ENV variables with preconfigured values"
cd ${cwd}/scripts
./replace-oc-template-values.sh

echo "Step 7/X: Init local Git repository for configuration"
cd ${OPENDEVSTACK_BASE_DIR}
cd ods-configuration
git init
git add --all
git commit -m "Initial configuration commit"

echo "Step 8/X: Setup and start VMs from Vagrant"
#start vagrant
cd ${cwd}
vagrant up

echo "Step 9/X: Base Installation with ansible"
cd ${cwd}
vagrant ssh atlcon -c "cd /vagrant/ansible/ && export ANSIBLE_VAULT_PASSWORD_FILE=/vagrant/ansible/.vault_pass.txt && ansible-playbook -v -i inventories/dev dev.yml"

cd ${cwd}

echo "Before procedding with the installation in script ${cwd}/prepare-local-environment.sh , you will have to configure the atlassian tools and setup the CD user"
echo "First you will have to configure Atlassian Crowd"
echo "Crowd: http://192.168.56.31:8095/"
echo "Jira: http://192.168.56.31:8080/"
echo "Confluence: http://192.168.56.31:8090/"
echo "Bitbucket: http://192.168.56.31:7990/"
