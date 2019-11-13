#!/bin/sh

set -e

if [ "${1:0:1}" != '-' ]; then
  exec "$@"
fi

if [ $SONAR_AUTH_CROWD == true ]; then
  # Update sonar.properties for crowd plugin
  echo "sonar.security.realm=Crowd" >> conf/sonar.properties
  echo "crowd.url=$SONARQUBE_CROWD_URL" >> conf/sonar.properties
  echo "crowd.application=$SONARQUBE_CROWD_APP" >> conf/sonar.properties
  echo "crowd.password=$SONARQUBE_CROWD_PWD" >> conf/sonar.properties
  echo "sonar.security.localUsers=admin" >> conf/sonar.properties
elif [ $SONAR_OAUTH_PLUGIN_ENABLED == true ]; then
  echo "sonar.auth.openshift.isEnabled=true" >> conf/sonar.properties
  echo "sonar.auth.openshift.sar.groups=$SONAR_OAUTH_ADMIN_GROUP=sonar-administrators,$SONAR_OAUTH_USERS_GROUP=sonar-users" >> conf/sonar.properties
  echo "oauth.cert=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt" >> conf/sonar.properties
  echo 'kubernetes.service=https://${env:KUBERNETES_SERVICE_HOST}:${env:KUBERNETES_SERVICE_PORT}/' >> conf/sonar.properties
fi

# upgrade to 7.3
rm $SONARQUBE_HOME/extensions/plugins/*.jar || true

# rm $SONARQUBE_HOME/extensions/plugins/sonar-crowd*.jar || true
# rm $SONARQUBE_HOME/extensions/plugins/sonar-scala*.jar || true
# rm $SONARQUBE_HOME/extensions/plugins/sonar-python*.jar || true

# Copy plugins into volume
mkdir -p $SONARQUBE_HOME/extensions/plugins
for FILENAME in /opt/configuration/sonarqube/plugins/*; do
  plugin=$(basename $FILENAME)
  cp $FILENAME $SONARQUBE_HOME/extensions/plugins/$plugin
done

exec java -jar lib/sonar-application-$SONAR_VERSION.jar \
  -Dsonar.log.console=true \
  -Dsonar.jdbc.username="$SONARQUBE_JDBC_USERNAME" \
  -Dsonar.jdbc.password="$SONARQUBE_JDBC_PASSWORD" \
  -Dsonar.jdbc.url="$SONARQUBE_JDBC_URL" \
  -Dsonar.web.javaAdditionalOpts="$SONARQUBE_WEB_JVM_OPTS -Djava.security.egd=file:/dev/./urandom" \
  "$@"
