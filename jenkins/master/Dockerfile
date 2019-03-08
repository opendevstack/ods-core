FROM registry.access.redhat.com/openshift3/jenkins-2-rhel7
COPY plugins.txt /opt/openshift/configuration/plugins.txt
COPY kube-slave-common.sh /usr/local/bin/kube-slave-common.sh
RUN /usr/local/bin/install-plugins.sh /opt/openshift/configuration/plugins.txt && \
    rm -r /opt/openshift/configuration/jobs/OpenShift* && \
    touch /var/lib/jenkins/configured
COPY configuration/ /opt/openshift/configuration/
ENV JENKINS_JAVA_OVERRIDES="-Dhudson.tasks.MailSender.SEND_TO_UNKNOWN_USERS=true -Dhudson.tasks.MailSender.SEND_TO_USERS_WITHOUT_READ=true"
