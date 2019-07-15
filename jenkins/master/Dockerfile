FROM registry.access.redhat.com/openshift3/jenkins-2-rhel7
COPY plugins.txt /opt/openshift/configuration/plugins.txt
COPY kube-slave-common.sh /usr/local/bin/kube-slave-common.sh
RUN /usr/local/bin/install-plugins.sh /opt/openshift/configuration/plugins.txt && \
    rm -r /opt/openshift/configuration/jobs/OpenShift* && \
    touch /var/lib/jenkins/configured
COPY configuration/ /opt/openshift/configuration/
COPY openshift-sync.jar /opt/openshift/
COPY ods-run /usr/libexec/s2i/ods-run

ARG APP_DNS=192.168.99.100.nip.io

RUN yum -y install openssl
RUN yum -y install gnutls-utils

#set JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/jre

# fetch certificates and store them in tmp directory
RUN echo ${APP_DNS}
RUN gnutls-cli --insecure --print-cert ${APP_DNS} </dev/null| sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/oc_app.crt

# add root ca into cert store so OC can pick it up.
RUN cat /tmp/oc_app.crt >> /etc/ssl/certs/ca-bundle.trust.crt && \
	cat /tmp/oc_app.crt >> /etc/ssl/certs/ca-bundle.crt

#Import base domain wildcard certificate
RUN echo $JAVA_HOME
RUN cat /tmp/oc_app.crt
RUN $JAVA_HOME/bin/keytool -storepasswd -new mysecretpassword -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit && \
    echo "yes" | $JAVA_HOME/bin/keytool -import -trustcacerts -file /tmp/oc_app.crt -alias oc_app -keystore $JAVA_HOME/lib/security/cacerts -storepass mysecretpassword && \
    echo "yes"

ENV JENKINS_JAVA_OVERRIDES="-Dhudson.tasks.MailSender.SEND_TO_UNKNOWN_USERS=true -Dhudson.tasks.MailSender.SEND_TO_USERS_WITHOUT_READ=true"
CMD ["/usr/libexec/s2i/ods-run"]
