# RedHat image should be specified in the build config
# FROM registry.access.redhat.com/rhscl/python-36-rhel7

# Centos is used for enabling local builds
FROM centos/python-36-centos7

ARG AIRFLOW_VERSION=1.10.3
ARG FILE_BEATS_VERSION=7.0.0

MAINTAINER Hugo Wruck Schneider <hugo.wruck_schneider@boehringer-ingelheim.com>

ENV SUMMARY="OpenDevStack Provided Airflow ${AIRFLOW_VERSION} Base Image compatible with OpenShift"
ENV DESCRIPTION="OpenDevStack Provided Airflow ${AIRFLOW_VERSION} Base Image compatible with OpenShift. This image \
should be used for running airflow's webserver and scheduler and as base image for building the worker's image \
\
Packages being used: \
    - Airflow ${AIRFLOW_VERSION}\
    - FileBeat ${FILE_BEATS_VERSION}\
"
LABEL   "name"="openshift3/airflow" \
        "summary"=$SUMMARY \
        "description"=$DESCRIPTION \
        "version"=$AIRFLOW_VERSION \
        "io.openshift.tags"="python36,python,airflow,airflow1102" \
        "io.k8s.description"=$DESCRIPTION \
        "io.openshift.expose-services"="8080:http" \
        "io.k8s.display-name"="Airflow ${AIRFLOW_VERSION}" \
        "com.redhat.component"="airflow-rhel7-docker"

ARG PYTHON_DEPS=""

ARG AIRFLOW_DEPS=""

ENV AIRFLOW_HOME=$HOME/airflow
ENV SLUGIFY_USES_TEXT_UNIDECODE yes

ARG nexus_username
ARG nexus_password
ARG nexus_url

# Define en_US.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8


USER root

ADD https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-${FILE_BEATS_VERSION}-x86_64.rpm ${HOME}

RUN buildDeps=' \
        freetds-devel \
        krb5-devel \
        cyrus-sasl-devel \
        openssl-devel \
        libffi-devel \
        postgresql-devel \
        git \
    ' \
    && pipDeps="\
       pytz \
       pyOpenSSL \
       ndg-httpsclient \
       pyasn1 \
       requests-oauthlib==1.1.0 \
       apache-airflow[crypto,postgres,hive,jdbc,mysql,ssh,kubernetes,elasticsearch${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}]==${AIRFLOW_VERSION} \
    " \
    && rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
    && yum install --assumeyes \
        $buildDeps \
        freetds \
        mariadb-libs \
        curl \
        rsync \
        nmap-ncat \
    && localedef -c -f UTF-8 -i en_US en_US.UTF-8 \
    && if [[ ! -z ${nexus_url} ]]; \
        then pip install -U -i https://${nexus_username}:${nexus_password}@${nexus_url:8}/repository/pypi-all/simple pip setuptools wheel \
        && pip install -i https://${nexus_username}:${nexus_password}@${nexus_url:8}/repository/pypi-all/simple $pipDeps; \
        else pip install -U pip setuptools wheel \
        && pip install $pipDeps; \
    fi \
    && yum localinstall --assumeyes ${HOME}/filebeat-${FILE_BEATS_VERSION}-x86_64.rpm \
    && yum clean all \
    && rm -rf /var/cache/yum

COPY config/filebeat.yml /etc/filebeat/filebeat.yml

### Log Stash - END

COPY scripts/entrypoint.sh /entrypoint.sh
COPY config/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

RUN mkdir -p ${AIRFLOW_HOME}/dags \
    && mkdir -p ${AIRFLOW_HOME}/plugins \
    && mkdir -p ${AIRFLOW_HOME}/dag_deps

COPY dist/oauth ${HOME}/oauth
COPY dist/openshift_plugin ${HOME}/openshift_plugin

RUN pip install ${HOME}/oauth \
    && pip install ${HOME}/openshift_plugin \
    && chgrp -R 0 ${AIRFLOW_HOME} \
    && chmod -R g=u ${AIRFLOW_HOME} \
    && chmod +x /entrypoint.sh \
    && chmod g+w /etc/passwd \
    && mkdir -p /var/lib/filebeat \
    && chgrp -R 0 /var/lib/filebeat  \
    && chmod -R g=u /var/lib/filebeat  \
    && mkdir -p /var/log/filebeat \
    && chgrp -R 0 /var/log/filebeat  \
    && chmod -R g=u /var/log/filebeat  \
    && chmod g+r /etc/filebeat/filebeat.yml

RUN if [ -n "${PYTHON_DEPS}" ]; then pip install ${PYTHON_DEPS}; fi

USER 1001



# Only the port for the webserver (8080) is exposed. Exposing the ports for flower
# and for the http server on the worker is not advisable but if need this should be changed.
EXPOSE 8080

WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["/entrypoint.sh"]
