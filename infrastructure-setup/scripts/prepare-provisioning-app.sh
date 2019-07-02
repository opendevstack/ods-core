#!/usr/bin/env bash
export PATH=$PATH:/usr/local/bin/
JENKINS_ROLE=admin
PROJECT=prov

BASE_DIR=${OPENDEVSTACK_DIR:-"/ods"}
cwd=${pwd}

if [ "$HOSTNAME" != "openshift" ] ; then
	echo "This script has to be executed on the openshift VM"
	exit
fi

oc login -u system:admin

echo "create projects for Provision Application"
oc new-project ${PROJECT}-cd --display-name="${PROJECT}-cd"
oc new-project ${PROJECT}-dev --display-name="${PROJECT}-dev"
oc new-project ${PROJECT}-test --display-name="${PROJECT}-test"

cd ${BASE_DIR}/ods-provisioning-app/ocp-config/prov-cd
yes 'y' | tailor update serviceaccount,pvc,dc,rolebinding,route,secret,svc --force
yes 'y' | tailor update bc --force

oc policy add-role-to-user ${JENKINS_ROLE} system:serviceaccount:${PROJECT}-cd:jenkins -n ${PROJECT}-dev
oc policy add-role-to-user ${JENKINS_ROLE} system:serviceaccount:${PROJECT}-cd:jenkins -n ${PROJECT}-test
oc policy add-role-to-user ${JENKINS_ROLE} system:serviceaccount:${PROJECT}-cd:default -n ${PROJECT}-dev
oc policy add-role-to-user ${JENKINS_ROLE} system:serviceaccount:${PROJECT}-cd:default -n ${PROJECT}-test

oc policy add-role-to-user system:image-puller system:serviceaccount:prov-cd:jenkins -n cd
oc policy add-role-to-user system:image-puller system:serviceaccount:prov-cd:default -n cd

cd ${BASE_DIR}/ods-provisioning-app/ocp-config/prov-app
yes 'y' | tailor update -f Tailorfile.dev --force
yes 'y' | tailor update -f Tailorfile.test --force

echo "Set higher Timeout for jenkins"
oc annotate route jenkins --overwrite haproxy.router.openshift.io/timeout=600s -n prov-cd

echo "Start initial application build"
oc start-build -n prov-cd ods-provisioning-app-production

