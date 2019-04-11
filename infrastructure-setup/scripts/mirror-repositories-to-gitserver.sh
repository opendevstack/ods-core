#!/bin/sh
# This scripts mirros the core ods repos into your own Bitbucket server.
# By default, this is the Bitbucket server on your local machine as created by the getting started guide.
# You can cutomize this by providing an environment variable: "REPO_TARGET_BASE" pointing to your git repo.
# This includes everything before the project / repo part, this means everything before "/opendevstack/..."
#
source ../../../local.config

BASE_DIR=${OPENDEVSTACK_BASE_DIR:-"/tmp"}
TARGET_REPO_BASE=${REPO_TARGET_BASE:-"http://192.168.56.31:7990/scm"}
cwd=${PWD}

if [ ! -d "$BASE_DIR" ] ; then
	echo "target directory for cloning OpenDevStack repositories not present: ${BASE_DIR}"
	exit 1
fi

echo -e "Mirror repositories"
echo -e "\nMirror ods-configuration-sample"
cd ${BASE_DIR}
cd ods-configuration-sample; git remote set-url origin ${TARGET_REPO_BASE}/opendevstack/ods-configuration-sample.git; git config http.postBuffer 524288000; git push --all origin;

echo -e "\nMirror ods-configuration"
cd ${BASE_DIR}
cd ods-configuration; git remote add origin ${TARGET_REPO_BASE}/opendevstack/ods-configuration.git; git config http.postBuffer 524288000; git push --all origin;

echo -e "\nMirror ods-core"
cd ${BASE_DIR}
cd ods-core; git remote set-url origin ${TARGET_REPO_BASE}/opendevstack/ods-core.git; git config http.postBuffer 524288000; git push --all origin;

echo -e "\nMirror ods-jenkins-shared-library"
cd ${BASE_DIR}
cd ods-jenkins-shared-library; git remote set-url origin ${TARGET_REPO_BASE}/opendevstack/ods-jenkins-shared-library.git; git config http.postBuffer 524288000; git push --all origin;

echo -e "\nMirror ods-provisioning-app"
cd ${BASE_DIR}
cd ods-provisioning-app; git remote set-url origin ${TARGET_REPO_BASE}/opendevstack/ods-provisioning-app.git; git config http.postBuffer 524288000; git push --all origin;

echo -e "\nMirror ods-project-quickstarters"
cd ${BASE_DIR}
cd ods-project-quickstarters; git remote set-url origin ${TARGET_REPO_BASE}/opendevstack/ods-project-quickstarters.git; git config http.postBuffer 524288000; git push --all origin;


cd ${cwd}
