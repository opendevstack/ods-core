ARG sonarVersion=10.8.0
ARG sonarEdition=developer

# For community edition use the following:
# FROM sonarqube:lts-community
FROM sonarqube:${sonarVersion}-${sonarEdition}

ARG APP_DNS

USER root

#Installing certificates

COPY ./import_certs.sh /usr/local/bin/import_certs.sh
RUN chmod -R 755 /usr/local/share/ca-certificates \
    && import_certs.sh

# Set proxy settings
COPY set-proxy.sh /tmp/set-proxy.sh
RUN chmod +x /tmp/set-proxy.sh \
    && /tmp/set-proxy.sh conf/sonar.properties

# Add plugins (mainly from https://docs.sonarqube.org/display/PLUG/Plugin+Library)
RUN mkdir -p /opt/configuration/sonarqube/plugins
# Language plugins not bundled
ADD https://github.com/Inform-Software/sonar-groovy/releases/download/1.8/sonar-groovy-plugin-1.8.jar /opt/configuration/sonarqube/plugins/
ADD https://github.com/Merck/sonar-r-plugin/releases/download/0.2.2/sonar-r-plugin-0.2.2.jar /opt/configuration/sonarqube/plugins/
ADD https://github.com/elegoff/sonar-rust/releases/download/v0.2.5/community-rust-plugin-0.2.5.jar /opt/configuration/sonarqube/plugins/

COPY run.sh $SONARQUBE_HOME/bin/

RUN chmod go+w $JAVA_HOME/lib/security/cacerts; \
    chmod -R go+x $SONARQUBE_HOME/bin/run.sh; \
    chmod -R go+w $SONARQUBE_HOME/conf; \
    chmod -R go=u /opt/configuration/sonarqube/plugins; \
    chmod -R ugo+wrX "${SONARQUBE_HOME}/data" "${SONARQUBE_HOME}/extensions"

USER sonarqube

ENTRYPOINT ["./bin/run.sh"]
