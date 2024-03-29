#!/bin/bash
set -ue

# Initialize JAVA_HOME if not set.
JAVA_HOME=${JAVA_HOME:-""}

if [ -f /etc/profile.d/set-default-java.sh ]; then
    set -x
    source /etc/profile.d/set-default-java.sh
    set +x
else
    echo "WARNING: Not setting default java version."
fi

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
