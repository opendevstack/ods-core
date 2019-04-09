#!/usr/bin/env bash

BASE_DIR=${OPENDEVSTACK_DIR:-"/ods"}
cwd = ${pwd}

if [ $HOSTNAME -ne "openshift" ] ; then
	echo "This script has to be executed on the openshift VM"
	exit 1
fi

sudo -i

oc login -u system:admin
oc project cd
