#!/bin/bash

echo "Patching elastic configuration"

export ELASTICSEARCH_CLUSTERNAME=${ELASTICSEARCH_CLUSTERNAME:="elasticsearch-cluster"}

ELASTICSEARCH_CA_CERTIFICATE_FILE=${CERT_PATH}/elastic-stack-ca.p12
ELASTICSEARCH_CERTIFICATE_FILE=${CERT_PATH}/elastic-certificates.p12

ELASTICSEARCH_SECRET_CA_CERTIFICATE_FILE=${CERT_PATH}/../secrets/elastic-stack-ca.p12
ELASTICSEARCH_CUSTOM_CONFIG_FILE=/usr/share/elasticsearch/config/custom/elasticsearch.yml

if [[ -f "${ELASTICSEARCH_CUSTOM_CONFIG_FILE}" ]]; then
    cp ${ELASTICSEARCH_CUSTOM_CONFIG_FILE} /usr/share/elasticsearch/config/elasticsearch.yml
fi

if [[ -f "${ELASTICSEARCH_SECRET_CA_CERTIFICATE_FILE}" ]]; then
    cp ${ELASTICSEARCH_SECRET_CA_CERTIFICATE_FILE} ${ELASTICSEARCH_CA_CERTIFICATE_FILE}
else
    /usr/share/elasticsearch/bin/elasticsearch-certutil ca --out ${ELASTICSEARCH_CA_CERTIFICATE_FILE} --pass ${ELASTICSEARCH_CERTIFICATE_PASSWORD} -s
fi




/usr/share/elasticsearch/bin/elasticsearch-certutil cert --ca ${ELASTICSEARCH_CA_CERTIFICATE_FILE} --out ${ELASTICSEARCH_CERTIFICATE_FILE} --pass ${ELASTICSEARCH_CERTIFICATE_PASSWORD} --ca-pass ${ELASTICSEARCH_CERTIFICATE_PASSWORD} -s


/usr/share/elasticsearch/bin/elasticsearch-keystore create
echo ${ELASTICSEARCH_CERTIFICATE_PASSWORD} | /usr/share/elasticsearch/bin/elasticsearch-keystore add xpack.security.transport.ssl.keystore.secure_password
echo ${ELASTICSEARCH_CERTIFICATE_PASSWORD} | /usr/share/elasticsearch/bin/elasticsearch-keystore add xpack.security.transport.ssl.truststore.secure_password

/usr/share/elasticsearch/bin/elasticsearch-users useradd ${ELASTICSEARCH_USERNAME} -p ${ELASTICSEARCH_PASSWORD} -r superuser

/usr/share/elasticsearch/bin/post-init.sh &
exec "$@"
