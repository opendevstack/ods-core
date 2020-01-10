#!/bin/sh

oldIFS=$IFS
IFS=';'
KEYSTORE="$JAVA_HOME/lib/security/cacerts"

: "${APP_DNS_PORT:=443}"

if [ "${TARGET_HOSTS}x" == "x" ] ; then
    TARGET_HOSTS=${APP_DNS}
fi

echo "KEYSTORE=${KEYSTORE}"
for dns in $TARGET_HOSTS; do
    cert_bundle_path="/etc/pki/ca-trust/source/anchors/${dns}.pem"
    gnutls-cli --insecure --print-cert ${dns} -p ${APP_DNS_PORT} </dev/null| sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' | tee ${cert_bundle_path}    
    $JAVA_HOME/bin/keytool -import -noprompt -trustcacerts -file ${cert_bundle_path} -alias ${dns} -keystore ${KEYSTORE} -storepass changeit || true
done
update-ca-trust
IFS=$oldIFS


