#!/usr/bin/env bash

#current workdir
cwd=${PWD}

#change to base dir
cd ../..

#set base dir
OPENDEVSTACK_BASE_DIR=${PWD}

#write base dir to local config file
echo "OPENDEVSTACK_BASE_DIR=${PWD}" > ${cwd}/local.config

echo "Step 1/X: Ensure ods-core is up to date"
cd ${cwd}/..
git pull

echo "Step 2/X: Get Configuration Sample Repository from GitHub"
#clone configuration sample repository
cd ${OPENDEVSTACK_BASE_DIR}
if [ ! -d "$OPENDEVSTACK_BASE_DIR/ods-configuration-sample" ] ; then
  #git clone https://github.com/opendevstack/ods-configuration-sample.git
  git clone https://github.com/tjaeschke/ods-configuration-sample.git
  cd ods-configuration-sample
  git fetch origin
  git checkout -b infrastructure-refactoring origin/infrastructure-refactoring
else
  echo "Update configuration sample"
  cd $OPENDEVSTACK_BASE_DIR/ods-configuration-sample
  git pull origin
fi

echo "Step 3/X: Copy configuration"
cd ${cwd}/scripts
./configuration-sample.sh
#cp -rf ./ods-configuration-sample/. ./ods-configuration
#find ods-configuration -name '*.sample' -type f | while read NAME ; do cp -f "${NAME}" "${NAME%.sample}" ; done

echo "Step 4/X: Init local Git repository for configuration"
cd ${OPENDEVSTACK_BASE_DIR}
cd ods-configuration
git init
git add --all
git commit -m "Initial configuration commit"
#git remote add origin http://opendevstack.admin@192.168.56.31:7990/scm/odsst/odsst-occonfig-artifacts.git
#git push -u origin master

echo "Step 2/3: Setup and start VMs from Vagrant"

#start vagrant
cd ${cwd}
vagrant up

cd ${cwd}

echo $PATH
