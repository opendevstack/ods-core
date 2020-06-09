FROM opendevstackorg/ods-provisioning-app

ARG APP_DNS

COPY ./import_certs.sh /usr/local/bin/import_certs.sh
RUN import_certs.sh