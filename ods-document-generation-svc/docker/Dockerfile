FROM  opendevstackorg/ods-document-generation-svc

USER root

ARG APP_DNS

COPY ./import_certs.sh /usr/local/bin/import_certs.sh
RUN import_certs.sh

USER 1001