#!/usr/bin/env bash
export PATH=$PATH:/usr/local/bin/


BASE_DIR=${OPENDEVSTACK_DIR:-"/ods"}
cwd=${pwd}

if [ "$HOSTNAME" != "openshift" ] ; then
	echo "This script has to be executed on the openshift VM"
	exit 1
fi

oc login -u system:admin
oc project cd

oc /ods/ods-workshop/ods-core/nexus/ocp-config
yes 'y' | tailor update --force

cd ${cwd}

#curl -s -o /dev/null -w "%{http_code}" https://nexus-cd.192.168.56.101.nip.io/

cd ${BASE_DIR}



