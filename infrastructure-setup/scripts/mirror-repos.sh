#!/bin/sh
# This scripts mirros the core ods repos into your own Bitbucket server.
# By default, this is the Bitbucket server on your local machine as created by the getting started guide.
# You can cutomize this by providing an environment variable: "REPO_TARGET_BASE" pointing to your git repo.
# This includes everything before the project / repo part, this means everything before "/opendevstack/..."
#
BASE_DIR=${OPENDEVSTACK_DIR:-"/tmp"}
TARGET_REPO_BASE=${REPO_TARGET_BASE:-"http://192.168.56.31:7990/scm/"}
cwd=${PWD}

if [ ! -d "$BASE_DIR" ] ; then
	echo "target directory for cloning OpenDevStack repositories not present: ${BASE_DIR}"
	exit 1
fi

cd $BASE_DIR

git config http.postBuffer 524288000

echo -e "Clone repositories"
echo -e "\nPrepare ods-configuration-sample"
git clone --bare https://github.com/opendevstack/ods-configuration-sample.git
cd ods-configuration-sample.git; git remote add --mirror=push downstream ${TARGET_REPO_BASE}/opendevstack/ods-configuration-sample.git; cd -
cd ods-configuration-sample.git; git branch production; git push downstream; cd -
rm -rf ods-configuration-sample.git

echo -e "\nPrepare ods-core"
git clone --bare https://github.com/opendevstack/ods-core.git
cd ods-core.git; git remote add --mirror=push downstream ${TARGET_REPO_BASE}/opendevstack/ods-core.git; cd -
cd ods-core.git; git branch production; git push downstream; cd -
rm -rf ods-core.git

echo -e "\nPrepare ods-jenkins-shared-library"
git clone --bare https://github.com/opendevstack/ods-jenkins-shared-library.git
cd ods-jenkins-shared-library.git; git remote add --mirror=push downstream ${TARGET_REPO_BASE}/opendevstack/ods-jenkins-shared-library.git; cd -
cd ods-jenkins-shared-library.git; git branch production; git push downstream; cd -
rm -rf ods-jenkins-shared-library.git


echo -e "\nPrepare ods-provisioning-app"
git clone --bare https://github.com/opendevstack/ods-provisioning-app.git
cd ods-provisioning-app.git; git remote add --mirror=push downstream ${TARGET_REPO_BASE}/opendevstack/ods-provisioning-app.git; cd -
cd ods-provisioning-app.git; git branch production; git push downstream; cd -
rm -rf ods-provisioning-app.git

echo -e "\nPrepare ods-project-quickstarters"
git clone --bare https://github.com/opendevstack/ods-project-quickstarters.git
cd ods-project-quickstarters.git; git remote add --mirror=push downstream ${TARGET_REPO_BASE}/opendevstack/ods-project-quickstarters.git; cd -
cd ods-project-quickstarters.git; git branch production; git push downstream; cd -
rm -rf ods-project-quickstarters.git

cd ${cwd}
