FROM adoptopenjdk/openjdk11:alpine-jre

ARG sonarDistributionUrl
ARG sonarVersion
ARG APP_DNS

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
    && apk add --no-cache libressl wget \
    && apk add --no-cache su-exec \
    && apk add --no-cache bash \
    && mkdir -p /opt \
    && cd /opt \
    && wget -O sonarqube.zip --no-verbose $sonarDistributionUrl \
    && unzip sonarqube.zip \
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
ADD https://github.com/vaulttec/sonar-auth-oidc/releases/download/v1.1.0/sonar-auth-oidc-plugin-1.1.0.jar /opt/configuration/sonarqube/plugins/
ADD https://binaries.sonarsource.com/Distribution/sonar-scm-git-plugin/sonar-scm-git-plugin-1.9.1.1834.jar /opt/configuration/sonarqube/plugins/
# Language plugins
ADD https://binaries.sonarsource.com/Distribution/sonar-java-plugin/sonar-java-plugin-6.2.0.21135.jar /opt/configuration/sonarqube/plugins/
ADD https://binaries.sonarsource.com/Distribution/sonar-jacoco-plugin/sonar-jacoco-plugin-1.0.2.475.jar /opt/configuration/sonarqube/plugins/
ADD https://binaries.sonarsource.com/Distribution/sonar-go-plugin/sonar-go-plugin-1.6.0.719.jar /opt/configuration/sonarqube/plugins/
ADD https://binaries.sonarsource.com/Distribution/sonar-javascript-plugin/sonar-javascript-plugin-6.1.0.11503.jar /opt/configuration/sonarqube/plugins/
ADD https://binaries.sonarsource.com/Distribution/sonar-python-plugin/sonar-python-plugin-2.1.0.5269.jar /opt/configuration/sonarqube/plugins/
ADD https://binaries.sonarsource.com/Distribution/sonar-typescript-plugin/sonar-typescript-plugin-2.1.0.4359.jar /opt/configuration/sonarqube/plugins/
ADD https://binaries.sonarsource.com/Distribution/sonar-scala-plugin/sonar-scala-plugin-1.5.0.315.jar /opt/configuration/sonarqube/plugins/
ADD https://binaries.sonarsource.com/Distribution/sonar-php-plugin/sonar-php-plugin-3.3.0.5166.jar /opt/configuration/sonarqube/plugins/
ADD https://github.com/Inform-Software/sonar-groovy/releases/download/1.6/sonar-groovy-plugin-1.6.jar /opt/configuration/sonarqube/plugins/

RUN chown -R :0 /opt/configuration/sonarqube/plugins; \
    chmod -R g=u /opt/configuration/sonarqube/plugins; \
    chown -R :0 $SONARQUBE_HOME/bin; \
    chmod g+w $JAVA_HOME/lib/security/cacerts; \
    chmod -R g+x $SONARQUBE_HOME/bin/run.sh

USER sonarqube

ENTRYPOINT ["./bin/run.sh"]
