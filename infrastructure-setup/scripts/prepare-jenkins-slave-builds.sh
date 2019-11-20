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

cd ${BASE_DIR}/ods-quickstarters/common/jenkins-slaves/airflow/ocp-config
yes 'y' | tailor update -v --force

cd ${BASE_DIR}/ods-quickstarters/common/jenkins-slaves/golang/ocp-config
yes 'y' | tailor update -v --force

cd ${BASE_DIR}/ods-quickstarters/common/jenkins-slaves/maven/ocp-config
yes 'y' | tailor update -v --force

cd ${BASE_DIR}/ods-quickstarters/common/jenkins-slaves/nodejs8-angular/ocp-config
yes 'y' | tailor update -v --force

cd ${BASE_DIR}/ods-quickstarters/common/jenkins-slaves/nodejs10-angular/ocp-config
yes 'y' | tailor update -v --force

cd ${BASE_DIR}/ods-quickstarters/common/jenkins-slaves/python/ocp-config/
yes 'y' | tailor update -v --force

cd ${BASE_DIR}/ods-quickstarters/common/jenkins-slaves/scala/ocp-config/
yes 'y' | tailor update -v --force

oc start-build -n cd jenkins-slave-airflow --follow
oc start-build -n cd jenkins-slave-golang --follow
oc start-build -n cd jenkins-slave-maven --follow
oc start-build -n cd jenkins-slave-nodejs8-angular --follow
oc start-build -n cd jenkins-slave-nodejs10-angular --follow
oc start-build -n cd jenkins-slave-python --follow
oc start-build -n cd jenkins-slave-scala --follow