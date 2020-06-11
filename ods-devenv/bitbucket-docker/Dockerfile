FROM atlassian/bitbucket-server:6.8.2-jdk11

ARG APP_DNS

COPY ./import_certs.sh /usr/local/bin/import_certs.sh
RUN import_certs.sh
