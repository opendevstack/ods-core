# Copyright 2018 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
# in compliance with the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
# or implied. See the License for the specific language governing permissions and limitations under
# the License.
 
FROM ubuntu:16.04

MAINTAINER Piotr Radkowski <piotr.radkowski@ardigen.com>

ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No

# Dockerize container
RUN echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/02apt-speedup && \
    echo 'DPkg::Post-Invoke {"/bin/rm -f /var/cache/apt/archives/*.deb || true";};' > /etc/apt/apt.conf.d/00no-cache && \
    /usr/bin/dpkg-divert --local --rename --add /usr/bin/ischroot && \
    rm -f /usr/bin/ischroot && \
    ln -s /bin/true /usr/bin/ischroot && \
    /usr/bin/dpkg-divert --local --rename --add /sbin/initctl && \
    rm -f /sbin/initctl && \
    ln -s /bin/true /sbin/initctl

# Setup locales
RUN apt-get update && \
    apt-get install -yqq locales apt-transport-https && \
    /usr/sbin/locale-gen en_US.UTF-8 && \
    /usr/sbin/update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
ENV LANGUAGE en
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

ENV BUILD_DIR /tmp/nginx-custom
RUN mkdir -p ${BUILD_DIR}
ADD rules.patch ${BUILD_DIR}/rules.patch
# git
RUN sed -i -e 's/# deb-src/deb-src/' /etc/apt/sources.list && \
    apt-get update && apt-get -y install build-essential git zip unzip wget libcurl4-openssl-dev && \
    dpkg -l | grep libgnutls && \
    cd ${BUILD_DIR} && apt-get source nginx && \
    echo "building starts" && \
    apt-get build-dep -y nginx && \
    cd ${BUILD_DIR}/nginx-1.10.3/debian/modules/ && \
    wget https://codeload.github.com/kare/ngx_http_auth_crowd_module/zip/master -O master.zip && \
    unzip master.zip && \
    mv ngx_http_auth_crowd_module-master/ ngx_http_auth_crowd_module && \
    cat ${BUILD_DIR}/rules.patch | patch -p0 ${BUILD_DIR}/nginx-1.10.3/debian/rules && \
    cd ${BUILD_DIR}/nginx-1.10.3 && dpkg-buildpackage -b && \
    dpkg -i ${BUILD_DIR}/nginx-common_1.10.3-0ubuntu0.16.04.3_all.deb && \
    dpkg -i ${BUILD_DIR}/nginx-full_1.10.3-0ubuntu0.16.04.3_amd64.deb && \
    rm -rf ${BUILD_DIR}

RUN apt-get install -y curl

# Cleanup apt
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

ADD nginx.sh /nginx.sh
ADD default /etc/nginx/sites-enabled/default
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i 's/user /#user /' /etc/nginx/nginx.conf

RUN chmod -R 777 /var/log/nginx /var/lib/nginx /var/run && \
    chgrp -R 0 /etc/nginx && \
    chmod -R g+rwX /etc/nginx && \
    chmod 777 /nginx.sh

EXPOSE 8080
CMD /nginx.sh
