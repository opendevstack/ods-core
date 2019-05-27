#!/usr/bin/env bash
# Import certificate to JVM
export PATH=$PATH:/usr/local/bin/

BASE_DIR=${OPENDEVSTACK_DIR:-"/ods"}
cwd=${pwd}

if [ "$HOSTNAME" != "atlassian" ] ; then
	echo "This script has to be executed on the atlassian VM"
	exit
fi

openssl s_client -connect 192.168.56.101:8443 -showcerts < /dev/null 2>/dev/null| sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${BASE_DIR}/openshift.crt
yes yes | /etc/alternatives/jre/bin/keytool -delete -alias openshift -keystore /etc/alternatives/jre/lib/security/cacerts -storepass changeit > /dev/null
yes yes | /etc/alternatives/jre/bin/keytool -delete -alias oc_router -keystore /etc/alternatives/jre/lib/security/cacerts -storepass changeit > /dev/null
yes yes | /etc/alternatives/jre/bin/keytool -import -alias openshift -keystore /etc/alternatives/jre/lib/security/cacerts -storepass changeit -file ${BASE_DIR}/openshift.crt
yes yes | /etc/alternatives/jre/bin/keytool -import -alias oc_router -keystore /etc/alternatives/jre/lib/security/cacerts -storepass changeit -file ${BASE_DIR}/certs/router.crt

#restart bitbucket
systemctl restart atlbitbucket
