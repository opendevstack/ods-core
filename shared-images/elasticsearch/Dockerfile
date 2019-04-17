FROM docker.elastic.co/elasticsearch/elasticsearch:7.0.0

ARG ELASTIC_CERT_PASSWORD

# ---------------------------------------------------------------------
# Variables for elastic build. These values are not used during runtime
ARG ELASTIC_CLUSTERNAME="build"
# ---------------------------------------------------------------------

COPY ./config/* /usr/share/elasticsearch/config/
COPY ./scripts/* /usr/share/elasticsearch/bin/

ENV CERT_PATH=/usr/share/elasticsearch/config/certs

# In order to create a Elastic Search Cluster the certificates should be created and copyed into the 
# docker images instead of beeing created during the docker build process

RUN mkdir -p ${CERT_PATH} && \
    chmod +x /usr/share/elasticsearch/bin/* && \
	yum -y --quiet install rsync && \
	chgrp -R 0 /usr/share/elasticsearch && \
    chmod -R g=u /usr/share/elasticsearch

USER 1001

EXPOSE 9200
EXPOSE 9300

ENTRYPOINT ["/usr/share/elasticsearch/bin/entrypoint.sh"]
CMD ["/usr/share/elasticsearch/bin/elasticsearch"]
