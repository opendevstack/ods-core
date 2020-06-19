FROM atlassian/__base-image__:__version__

ARG APP_DNS

COPY ./import_certs.sh /usr/local/bin/import_certs.sh
RUN import_certs.sh
