FROM adoptopenjdk/openjdk11:x86_64-alpine-jre-11.0.10_9

ARG sonarDistributionUrl
ARG sonarVersion
ARG APP_DNS
ARG sonarEdition

ENV SONARQUBE_HOME=/opt/sonarqube \
    SONARQUBE_JDBC_USERNAME=sonar \
    SONARQUBE_JDBC_PASSWORD=sonar \
    SONARQUBE_JDBC_URL= \
    SONAR_VERSION=${sonarVersion}

# Http port
EXPOSE 9000

RUN adduser -S -G root sonarqube

RUN set -x \
    && apk update \
    && apk add --no-cache ca-certificates \
    && apk add --no-cache gnupg unzip \
    && apk add --no-cache openssl wget \
    && apk add --no-cache su-exec \
    && apk add --no-cache bash \
    && apk fix \
    && mkdir -p /opt \
    && cd /opt \
    && wget -O sonarqube.zip --no-verbose $sonarDistributionUrl \
    && unzip -qq sonarqube.zip \
    && mv sonarqube-$SONAR_VERSION sonarqube \
    && chown -R sonarqube:root sonarqube \
    && chmod -R g+w sonarqube \
    && rm sonarqube.zip* \
    && rm -rf $SONARQUBE_HOME/bin/* \
    && mkdir -p /opt/configuration/sonarqube \
    && chown -R sonarqube:root /opt/configuration/sonarqube

COPY ./import_certs.sh /usr/local/bin/import_certs.sh
RUN import_certs.sh

VOLUME "$SONARQUBE_HOME/data"

WORKDIR $SONARQUBE_HOME

# Set proxy settings
COPY set-proxy.sh /tmp/set-proxy.sh
RUN chmod +x /tmp/set-proxy.sh \
    && /tmp/set-proxy.sh conf/sonar.properties

COPY run.sh $SONARQUBE_HOME/bin/

# Add plugins (mainly from https://docs.sonarqube.org/display/PLUG/Plugin+Library)
RUN mkdir -p /opt/configuration/sonarqube/plugins
# General plugins
ADD https://github.com/deepy/sonar-crowd/releases/download/2.1.3/sonar-crowd-plugin-2.1.3.jar /opt/configuration/sonarqube/plugins/
ADD https://github.com/vaulttec/sonar-auth-oidc/releases/download/v2.1.1/sonar-auth-oidc-plugin-2.1.1.jar /opt/configuration/sonarqube/plugins/
# Language plugins not bundled
ADD https://github.com/Inform-Software/sonar-groovy/releases/download/1.7/sonar-groovy-plugin-1.7.jar /opt/configuration/sonarqube/plugins/
ADD https://github.com/Merck/sonar-r-plugin/releases/download/0.2.1/sonar-r-plugin-0.2.1.jar /opt/configuration/sonarqube/plugins/
# When running SonarQube 9.9LTS this plugin can be upgraded to 0.2.x
ADD https://github.com/elegoff/sonar-rust/releases/download/v0.1.0/community-rust-plugin-0.1.0.jar /opt/configuration/sonarqube/plugins/

RUN chown -R :0 /opt/configuration/sonarqube/plugins; \
    chmod -R g=u /opt/configuration/sonarqube/plugins; \
    chown -R :0 $SONARQUBE_HOME/bin; \
    chmod g+w $JAVA_HOME/lib/security/cacerts; \
    chmod -R g+x $SONARQUBE_HOME/bin/run.sh

USER sonarqube

ENTRYPOINT ["./bin/run.sh"]
