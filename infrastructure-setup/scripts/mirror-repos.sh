#!/bin/sh
# This scripts mirros the core ods repos into your own Bitbucket server.
# By default, this is the Bitbucket server on your local machine as created by the getting started guide.
# You can cutomize this by providing an environment variable: "REPO_TARGET_BASE" pointing to your git repo.
# This includes everything before the project / repo part, this means everything before "/opendevstack/..."
#
BASE_DIR=${REPO_MIRROR_DIR:-"/tmp"}
TARGET_REPO_BASE=${REPO_TARGET_BASE:-"http://192.168.56.31:7990/scm/"}
cwd=${PWD}

if [ ! -d "$BASE_DIR" ] ; then
	echo "target directory for cloning OpenDevStack repositories not present: ${BASE_DIR}"
	exit 1
fi

cd $BASE_DIR

git clone --bare https://github.com/opendevstack/ods-configuration-sample.git
git clone --bare https://github.com/opendevstack/ods-core.git
git clone --bare https://github.com/opendevstack/ods-jenkins-shared-library.git
git clone --bare https://github.com/opendevstack/ods-provisioning-app.git
git clone --bare https://github.com/opendevstack/ods-project-quickstarters.git
#!/bin/sh
cd ods-configuration-sample.git; git remote add --mirror=push downstream ${TARGET_REPO_BASE}/opendevstack/ods-configuration-sample.git; cd -
cd ods-core.git; git remote add --mirror=push downstream ${TARGET_REPO_BASE}/opendevstack/ods-core.git; cd -
cd ods-jenkins-shared-library.git; git remote add --mirror=push downstream ${TARGET_REPO_BASE}/opendevstack/ods-jenkins-shared-library.git; cd -
cd ods-project-quickstarters.git; git remote add --mirror=push downstream ${TARGET_REPO_BASE}/opendevstack/ods-project-quickstarters.git; cd -
cd ods-provisioning-app.git; git remote add --mirror=push downstream ${TARGET_REPO_BASE}/opendevstack/ods-provisioning-app.git; cd -
#!/bin/sh
cd ods-configuration-sample.git; git push downstream; cd -
cd ods-core.git; git push downstream; cd -
cd ods-jenkins-shared-library.git; git push downstream; cd -
cd ods-project-quickstarters.git; git push downstream; cd -
cd ods-provisioning-app.git; git push downstream; cd -

cd ${cwd}
