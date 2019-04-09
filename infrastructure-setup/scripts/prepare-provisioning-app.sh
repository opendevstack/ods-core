#!/usr/bin/env bash
export PATH=$PATH:/usr/local/bin/
JENKINS_ROLE=admin
PROJECT=prov

BASE_DIR=${OPENDEVSTACK_DIR:-"/ods"}
cwd=${pwd}

if [ "$HOSTNAME" != "openshift" ] ; then
	echo "This script has to be executed on the openshift VM"
	exit 1
fi

/usr/local/bin/oc login -u system:admin

/usr/local/bin/oc policy add-role-to-user ${JENKINS_ROLE} system:serviceaccount:${PROJECT}-cd:jenkins -n ${PROJECT}-dev
/usr/local/bin/oc policy add-role-to-user ${JENKINS_ROLE} system:serviceaccount:${PROJECT}-cd:jenkins -n ${PROJECT}-test
/usr/local/bin/oc policy add-role-to-user system:image-puller system:serviceaccount:prov-cd:jenkins -n cd
