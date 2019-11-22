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



