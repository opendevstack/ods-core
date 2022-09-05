#!/bin/bash
set -eu

# Initialize JAVA_HOME if not set.
JAVA_HOME=${JAVA_HOME:-""}

if [ -f /etc/profile.d/set-default-java.sh ]; then
    source /etc/profile.d/set-default-java.sh
else
    echo "WARNING: Not setting default java version."
fi

if [[ ! -z ${APP_DNS:=""} ]]; then
    echo "Setting up certificates from APP_DNS=${APP_DNS} ..."; \

    KEYSTORE="$JAVA_HOME/lib/security/cacerts"

    arrIN=(${APP_DNS//;/ })
    for val in "${arrIN[@]}";
    do
        dnsPortTuple=(${val//:/ })
        DNS=${dnsPortTuple[0]}
        PORT=${dnsPortTuple[1]:=443}

        echo "Importing DNS=$DNS PORT=$PORT"
        cert_bundle_path="/etc/pki/ca-trust/source/anchors/${DNS}.pem"
        openssl s_client -showcerts -host ${DNS} -port ${PORT} </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > "${cert_bundle_path}"
        $JAVA_HOME/bin/keytool -import -noprompt -trustcacerts -file ${cert_bundle_path} -alias ${DNS} -keystore ${KEYSTORE} -storepass changeit
    done
    update-ca-trust
    echo "Done with certificate setup"
else
    echo 'No certificates to import'
fi

echo "Trying to setup correct permissions for cacerts folder... "
if [ ! -z "${JAVA_HOME}" ] && [ "" != "${JAVA_HOME}" ]; then
    chmod -c g+w $JAVA_HOME/lib/security/cacerts
else
    echo "WARNING: Cannot apply permissions 'chmod g+w' to JAVA_HOME/lib/security/cacerts "
    echo "WARNING: JAVA_HOME=${JAVA_HOME}"
fi
