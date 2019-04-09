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
