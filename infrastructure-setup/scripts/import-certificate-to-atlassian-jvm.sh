#!/usr/bin/env bash
# Import certificate to JVM
export PATH=$PATH:/usr/local/bin/

BASE_DIR=${OPENDEVSTACK_DIR:-"/ods"}
cwd=${pwd}

if [ "$HOSTNAME" != "atlassian" ] ; then
	echo "This script has to be executed on the atlassian VM"
	exit 1
fi

openssl s_client -connect 192.168.56.101:8443 -showcerts < /dev/null 2>/dev/null| sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${BASE_DIR}/openshift.crt
yes yes | /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.201.b09-2.el7_6.x86_64/jre/bin/keytool -import -alias openshift -keystore /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.201.b09-2.el7_6.x86_64/jre/lib/security/cacerts -storepass changeit -file ${BASE_DIR}/openshift.crt
