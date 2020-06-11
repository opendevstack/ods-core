FROM atlassian/bitbucket-server:__version__

ARG APP_DNS

COPY ./import_certs.sh /usr/local/bin/import_certs.sh
RUN mkdir -p "/etc/pki/ca-trust/source/anchors" && import_certs.sh
