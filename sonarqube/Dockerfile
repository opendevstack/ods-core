FROM adoptopenjdk/openjdk11:alpine-jre

ENV SONARQUBE_HOME=/opt/sonarqube \
    SONARQUBE_JDBC_USERNAME=sonar \
    SONARQUBE_JDBC_PASSWORD=sonar \
    SONARQUBE_JDBC_URL=

# Http port
EXPOSE 9000

RUN adduser -S -G root sonarqube

RUN set -x \
    && apk update \
    && apk add --no-cache ca-certificates \
    && apk add --no-cache gnutls-utils \
    && apk add --no-cache gnupg unzip \
    && apk add --no-cache libressl wget \
    && apk add --no-cache su-exec \
    && apk add --no-cache bash \
    # pub   2048R/D26468DE 2015-05-25
    #       Key fingerprint = F118 2E81 C792 9289 21DB  CAB4 CFCA 4A29 D264 68DE
    # uid                  sonarsource_deployer (Sonarsource Deployer) <infra@sonarsource.com>
    # sub   2048R/06855C1D 2015-05-25
    # && if [[ $HTTP_PROXY != "" ]]; then gpg --keyserver ha.pool.sks-keyservers.net --keyserver-options "timeout=10 http-proxy=$http_proxy" --recv-keys F1182E81C792928921DBCAB4CFCA4A29D26468DE; else gpg --keyserver ha.pool.sks-keyservers.net --recv-keys F1182E81C792928921DBCAB4CFCA4A29D26468DE; fi \
    && mkdir -p /opt \
    && cd /opt \
    && wget -O sonarqube.zip --no-verbose $SONAR_DISTRIBUTION_URL \
    # && wget -O sonarqube.zip.asc --no-verbose https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip.asc \
    # && gpg --batch --verify sonarqube.zip.asc sonarqube.zip \
    && unzip sonarqube.zip \
    && mv sonarqube-$SONAR_VERSION sonarqube \
    && chown -R sonarqube:root sonarqube \
    && chmod -R g+w sonarqube \
    && rm sonarqube.zip* \
    && rm -rf $SONARQUBE_HOME/bin/* \
    && mkdir -p /opt/configuration/sonarqube \
    && chown -R sonarqube:root /opt/configuration/sonarqube

# fetch certificates and store them in tmp directory
RUN if [ -z $IDP_DNS ]; then echo 'Skipping custom certificate!'; else \
    echo "Setting up custom certificate from ${IDP_DNS} ..."; \
    gnutls-cli --insecure --print-cert ${IDP_DNS} </dev/null| sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/idp.crt; \
    cat /tmp/idp.crt|awk 'split_after==1{n++;split_after=0} /-----END CERTIFICATE-----/ {split_after=1} {print > "/usr/local/share/ca-certificates/mycert" n ".crt"}'; \
    update-ca-certificates; \
    keytool -importcert -keypass changeit -file /tmp/idp.crt -keystore $JAVA_HOME/lib/security/cacerts -noprompt -storepass changeit; \
    fi

VOLUME "$SONARQUBE_HOME/data"

WORKDIR $SONARQUBE_HOME

COPY run.sh $SONARQUBE_HOME/bin/

# Add plugins (mainly from https://docs.sonarqube.org/display/PLUG/Plugin+Library)
RUN mkdir -p /opt/configuration/sonarqube/plugins
# General plugins
ADD https://github.com/deepy/sonar-crowd/releases/download/2.1.3/sonar-crowd-plugin-2.1.3.jar /opt/configuration/sonarqube/plugins/
ADD https://github.com/vaulttec/sonar-auth-oidc/releases/download/v1.1.0/sonar-auth-oidc-plugin-1.1.0.jar /opt/configuration/sonarqube/plugins/
ADD https://github.com/dependency-check/dependency-check-sonar-plugin/releases/download/1.2.6/sonar-dependency-check-plugin-1.2.6.jar /opt/configuration/sonarqube/plugins/
ADD https://github.com/rht-labs/sonar-auth-openshift/releases/download/v1.1.1/sonar-auth-openshift-plugin.jar /opt/configuration/sonarqube/plugins/
# Language plugins
ADD https://binaries.sonarsource.com/Distribution/sonar-java-plugin/sonar-java-plugin-6.2.0.21135.jar /opt/configuration/sonarqube/plugins/
ADD https://binaries.sonarsource.com/Distribution/sonar-go-plugin/sonar-go-plugin-1.6.0.719.jar /opt/configuration/sonarqube/plugins/
ADD https://binaries.sonarsource.com/Distribution/sonar-javascript-plugin/sonar-javascript-plugin-6.1.0.11503.jar /opt/configuration/sonarqube/plugins/
ADD https://binaries.sonarsource.com/Distribution/sonar-python-plugin/sonar-python-plugin-2.1.0.5269.jar /opt/configuration/sonarqube/plugins/
ADD https://binaries.sonarsource.com/Distribution/sonar-typescript-plugin/sonar-typescript-plugin-2.1.0.4359.jar /opt/configuration/sonarqube/plugins/
ADD https://binaries.sonarsource.com/Distribution/sonar-scala-plugin/sonar-scala-plugin-1.5.0.315.jar /opt/configuration/sonarqube/plugins/

RUN chown -R :0 /opt/configuration/sonarqube/plugins; \
    chmod -R g=u /opt/configuration/sonarqube/plugins; \
    chown -R :0 $SONARQUBE_HOME/bin; \
    chmod -R g+x $SONARQUBE_HOME/bin/run.sh

USER sonarqube

ENTRYPOINT ["./bin/run.sh"]
