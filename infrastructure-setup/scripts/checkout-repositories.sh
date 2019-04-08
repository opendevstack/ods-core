#!/bin/sh
# This scripts updates and checks out the core ods repos, used to setup the OpenDevStack.
# By default, this is the Bitbucket server on your local machine as created by the getting started guide.
# You can cutomize this by providing an environment variable: "REPO_TARGET_BASE" pointing to your git repo.
# This includes everything before the project / repo part, this means everything before "/opendevstack/..."
#

source ../../../local.config

cwd=${PWD}

if [ ! -d "$OPENDEVSTACK_BASE_DIR" ] ; then
	echo "target directory for cloning OpenDevStack repositories not present: ${OPENDEVSTACK_BASE_DIR}"
	exit 1
fi

cd $BASE_DIR

echo -e "Clone repositories"
echo -e "\nPrepare ods-configuration-sample"
#clone configuration sample repository
cd ${OPENDEVSTACK_BASE_DIR}
if [ ! -d "$OPENDEVSTACK_BASE_DIR/ods-configuration-sample" ] ; then
  git clone https://github.com/opendevstack/ods-configuration-sample.git
  cd ods-configuration-sample
  git fetch origin
  git checkout -b production
else
  echo "Update configuration sample"
  cd $OPENDEVSTACK_BASE_DIR/ods-configuration-sample
  git pull origin
fi

echo -e "\nPrepare ods-jenkins-shared-library"
cd ${OPENDEVSTACK_BASE_DIR}
if [ ! -d "$OPENDEVSTACK_BASE_DIR/ods-jenkins-shared-library" ] ; then
  git clone https://github.com/opendevstack/ods-jenkins-shared-library.git
  cd ods-jenkins-shared-library
  git fetch origin
  git checkout -b production
else
  echo "Update shared library"
  cd $OPENDEVSTACK_BASE_DIR/ods-jenkins-shared-library
  git pull origin
fi

echo -e "\nPrepare ods-provisioning-app"
cd ${OPENDEVSTACK_BASE_DIR}
if [ ! -d "$OPENDEVSTACK_BASE_DIR/ods-provisioning-app" ] ; then
  git clone https://github.com/opendevstack/ods-provisioning-app.git
  cd ods-provisioning-app
  git fetch origin
  git checkout -b production
else
  echo "Update shared library"
  cd $OPENDEVSTACK_BASE_DIR/ods-provisioning-app
  git pull origin
fi

echo -e "\nPrepare ods-project-quickstarters"
cd ${OPENDEVSTACK_BASE_DIR}
if [ ! -d "$OPENDEVSTACK_BASE_DIR/ods-project-quickstarters" ] ; then
  git clone https://github.com/opendevstack/ods-project-quickstarters.git
  cd ods-project-quickstarters
  git fetch origin
  git checkout -b production
else
  echo "Update shared library"
  cd $OPENDEVSTACK_BASE_DIR/ods-project-quickstarters
  git pull origin
fi

cd ${cwd}
