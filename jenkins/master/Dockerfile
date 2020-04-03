FROM registry.access.redhat.com/openshift3/jenkins-2-rhel7:v3.11
# FROM openshift/jenkins-2-centos7

ENV JAVA_HOME /usr/lib/jvm/jre

ARG APP_DNS=192.168.99.100.nip.io
ARG ODS_GIT_REF
ARG ODS_IMAGE_TAG
ARG SONAR_EDITION
ARG SONAR_VERSION

USER root
RUN yum -y install openssl gnutls-utils \
    && $JAVA_HOME/bin/keytool -storepasswd -new mysecretpassword -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit \
    && yum clean all  \
    && rm -rf /var/cache/yum/*

# Fetch certificates and store them in tmp directory.
COPY ./import_certs.sh /usr/local/bin/import_certs.sh
RUN import_certs.sh

# Copy configuration and plugins.
COPY plugins.txt /opt/openshift/configuration/plugins.txt
COPY kube-slave-common.sh /usr/local/bin/kube-slave-common.sh
RUN /usr/local/bin/install-plugins.sh /opt/openshift/configuration/plugins.txt \
    && rm -r /opt/openshift/configuration/jobs/OpenShift* \
    && touch /var/lib/jenkins/configured
COPY configuration/ /opt/openshift/configuration/
COPY ods-run /usr/libexec/s2i/ods-run

# Add ODS configuration file.
RUN mkdir -p /etc/opendevstack \
    && echo "{" > /etc/opendevstack/config.json \
    && echo "  \"odsGitRef\": \"$ODS_GIT_REF\"," >> /etc/opendevstack/config.json \
    && echo "  \"odsImageTag\": \"$ODS_IMAGE_TAG\"," >> /etc/opendevstack/config.json \
    && echo "  \"sonarqubeEdition\": \"$SONAR_EDITION\"," >> /etc/opendevstack/config.json \
    && echo "  \"sonarqubeVersion\": \"$SONAR_VERSION\"" >> /etc/opendevstack/config.json \
    && echo "}" >> /etc/opendevstack/config.json

USER jenkins
ENV JENKINS_JAVA_OVERRIDES="-Dhudson.tasks.MailSender.SEND_TO_UNKNOWN_USERS=true -Dhudson.tasks.MailSender.SEND_TO_USERS_WITHOUT_READ=true"
CMD ["/usr/libexec/s2i/ods-run"]
