#!/bin/sh

set -e

if [ "${SONAR_AUTH_CROWD}" = "true" ]; then
  # Update sonar.properties for crowd plugin
  {
    echo "sonar.security.realm=Crowd"
    echo "crowd.url=$SONARQUBE_CROWD_URL"
    echo "crowd.application=$SONARQUBE_CROWD_APP"
    echo "crowd.password=$SONARQUBE_CROWD_PWD"
    echo "sonar.security.localUsers=admin"
  } >> conf/sonar.properties
fi

# Copy plugins into volume
rm "${SONARQUBE_HOME}"/extensions/plugins/*.jar || true
ls -lah /opt/configuration/sonarqube/plugins
mkdir -p "${SONARQUBE_HOME}/extensions/plugins"
for FILENAME in /opt/configuration/sonarqube/plugins/*; do
  plugin=$(basename "${FILENAME}")
  cp "${FILENAME}" "${SONARQUBE_HOME}/extensions/plugins/${plugin}"
done

# Openshift default CA. See https://docs.openshift.com/container-platform/3.11/dev_guide/secrets.html#service-serving-certificate-secrets
SERVICEACCOUNT_CA='/var/run/secrets/kubernetes.io/serviceaccount/service-ca.crt'
if [[ -f $SERVICEACCOUNT_CA ]]; then
  echo "INFO: found $SERVICEACCOUNT_CA"
  echo "INFO: importing into cacerts"
  keytool -importcert -v -trustcacerts -alias service-ca -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit -file $SERVICEACCOUNT_CA -noprompt
else
  echo "INFO: could not find '$SERVICEACCOUNT_CA'"
  echo "INFO: skip import"
fi

exec java -jar "lib/sonar-application-${SONAR_VERSION}.jar" \
  -Dsonar.log.console=true \
  -Dsonar.jdbc.username="${SONARQUBE_JDBC_USERNAME}" \
  -Dsonar.jdbc.password="${SONARQUBE_JDBC_PASSWORD}" \
  -Dsonar.jdbc.url="${SONARQUBE_JDBC_URL}" \
  -Dsonar.web.javaAdditionalOpts="${SONARQUBE_WEB_JVM_OPTS} -Djava.security.egd=file:/dev/./urandom" \
  "$@"
