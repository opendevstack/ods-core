FROM registry.access.redhat.com/ubi9/openjdk-21-runtime:latest

# Enforce runtime protection for log4j2 CVE-2021-44228 (affected version from 2.0 to 2.14.1) in the affected vesion is used.
# This applies for version from 2.10 and not below.
ENV LOG4J_FORMAT_MSG_NO_LOOKUPS=true

ARG ODS_API_SERVICE_VERSION=latest

RUN curl -L https://github.com/opendevstack/ods-api-service/releases/download/v$ODS_API_SERVICE_VERSION/app.jar -o app.jar

# Environment variable for certificate URLs (comma-separated) ENV CERT_URLS="" it is needed to install the certificates
COPY install-certs.sh /opt/install-certs.sh

USER root
RUN chmod +x /opt/install-certs.sh

USER 1001

EXPOSE 8080

CMD ["/bin/bash", "-c", "/opt/install-certs.sh && java $JAVA_OPTS -jar app.jar"]
