FROM openshift/jenkins-2-centos7

ENV JAVA_HOME /usr/lib/jvm/jre
ARG APP_DNS=192.168.99.100.nip.io

USER root
RUN yum -y install openssl gnutls-utils && \
    $JAVA_HOME/bin/keytool -storepasswd -new mysecretpassword -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit 

# fetch certificates and store them in tmp directory
COPY ./import_certs.sh /usr/local/bin/import_certs.sh
RUN import_certs.sh

COPY plugins.txt /opt/openshift/configuration/plugins.txt
COPY kube-slave-common.sh /usr/local/bin/kube-slave-common.sh
RUN /usr/local/bin/install-plugins.sh /opt/openshift/configuration/plugins.txt && \
    rm -r /opt/openshift/configuration/jobs/OpenShift* && \
    touch /var/lib/jenkins/configured
COPY configuration/ /opt/openshift/configuration/
COPY openshift-sync.jar /opt/openshift/
COPY ods-run /usr/libexec/s2i/ods-run

USER jenkins
ENV JENKINS_JAVA_OVERRIDES="-Dhudson.tasks.MailSender.SEND_TO_UNKNOWN_USERS=true -Dhudson.tasks.MailSender.SEND_TO_USERS_WITHOUT_READ=true"
CMD ["/usr/libexec/s2i/ods-run"]
