#!/usr/bin/env bash
export PATH=$PATH:/usr/local/bin/

BASE_DIR=${OPENDEVSTACK_BASE_DIR:-"/ods"}
cwd=${pwd}

if [ "$HOSTNAME" != "openshift" ] ; then
	echo "This script has to be executed on the openshift VM"
	exit 1
fi

oc login -u system:admin
oc project cd

echo "Update Jenkins Config"
cd ${BASE_DIR}/ods-core/jenkins/ocp-config
yes 'y' | tailor update -v --force

echo "Start Jenkins Builds"
oc start-build -n cd jenkins-master --follow
oc start-build -n cd jenkins-slave-base --follow
oc start-build -n cd jenkins-webhook-proxy --follow

cd ${BASE_DIR}/ods-project-quickstarters/jenkins-slaves/maven/ocp-config
yes 'y' | tailor update -v --force

cd ${BASE_DIR}/ods-project-quickstarters/jenkins-slaves/nodejs8-angular/ocp-config
yes 'y' | tailor update -v --force

cd ${BASE_DIR}/ods-project-quickstarters/jenkins-slaves/python/ocp-config/
yes 'y' | tailor update -v --force

cd ${BASE_DIR}/ods-project-quickstarters/jenkins-slaves/scala/ocp-config/
yes 'y' | tailor update -v --force

oc start-build -n cd jenkins-slave-maven --follow
oc start-build -n cd jenkins-slave-python --follow
oc start-build -n cd jenkins-slave-scala --follow
oc start-build -n cd jenkins-slave-nodejs8-angular --follow
