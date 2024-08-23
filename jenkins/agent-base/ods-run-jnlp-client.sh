#!/bin/bash
set -ue

# Initialize JAVA_HOME and set alternatives.
NO_JAVA_LINK="false"
java -version || NO_JAVA_LINK="true"
if [ "true" == "${NO_JAVA_LINK}" ]; then
    JAVA_HOME_FOLDER=$(ls -lah /usr/lib/jvm | grep "java-17-openjdk-.*\.x86_64" | awk '{print $NF}' | head -1)
    JAVA_HOME="/usr/lib/jvm/${JAVA_HOME_FOLDER}"
    alternatives --set java ${JAVA_HOME}/bin/java
fi
java -version

# Openshift default CA. See https://docs.openshift.com/container-platform/3.11/dev_guide/secrets.html#service-serving-certificate-secrets
SERVICEACCOUNT_CA='/var/run/secrets/kubernetes.io/serviceaccount/service-ca.crt'
if [[ -f $SERVICEACCOUNT_CA ]]; then
  echo "INFO: found $SERVICEACCOUNT_CA"
  echo "INFO: importing into cacerts"
  $JAVA_HOME/bin/keytool -importcert -v -trustcacerts -alias service-ca -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit -file "$SERVICEACCOUNT_CA" -noprompt
else
  echo "INFO: could not find '$SERVICEACCOUNT_CA'"
  echo "INFO: skip import"
fi

/usr/local/bin/openshift-run-jnlp-client
