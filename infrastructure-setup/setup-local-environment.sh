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
vagrant up

echo "Step 9/9: Base Installation with ansible"
cd ${cwd}
vagrant ssh atlcon -c "cd /vagrant/ansible/ && export ANSIBLE_VAULT_PASSWORD_FILE=/vagrant/ansible/.vault_pass.txt && ansible-playbook -v -i inventories/dev dev.yml"

cd ${cwd}

echo "Before procedding with the installation in script ${cwd}/prepare-local-environment.sh , you will have to configure the atlassian tools and setup the CD user"
echo "First you will have to configure Atlassian Crowd"
echo "Crowd: http://192.168.56.31:8095/"
echo "Jira: http://192.168.56.31:8080/"
echo "Confluence: http://192.168.56.31:8090/"
echo "Bitbucket: http://192.168.56.31:7990/"
