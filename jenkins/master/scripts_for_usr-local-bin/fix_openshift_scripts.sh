#!/bin/bash
set -eu -o pipefail

ME="$(basename $0)"
echo "${ME}: INFO: Fixing openshift scripts..."

FILE_TO_MODIFY=${1-"/usr/libexec/s2i/run"}

if [ -f ${FILE_TO_MODIFY} ]; then
    if ! grep -Fq 'KUBERNETES_CONFIG=$(generate_kubernetes_config) || exit 1' "${FILE_TO_MODIFY}"; then
        if ! grep -Fq 'export KUBERNETES_CONFIG=$(generate_kubernetes_config)' "${FILE_TO_MODIFY}"; then
            echo "${ME}: ERROR: Kubernetes cloud configuration generation not found in ${FILE_TO_MODIFY}" >&2
            exit 1
        fi
        sed -i 's/^\([[:space:]]*\)export KUBERNETES_CONFIG=$(generate_kubernetes_config)[[:space:]]*$/\1KUBERNETES_CONFIG=$(generate_kubernetes_config) || exit 1\n\1export KUBERNETES_CONFIG/' "${FILE_TO_MODIFY}"
        if ! grep -Fq 'KUBERNETES_CONFIG=$(generate_kubernetes_config) || exit 1' "${FILE_TO_MODIFY}"; then
            echo "${ME}: ERROR: Unrecognized Kubernetes cloud configuration generation in ${FILE_TO_MODIFY}" >&2
            exit 1
        fi
    fi
    sed -i 's|\#\!/bin/bash|\#\!/bin/bash -x|g' ${FILE_TO_MODIFY}
    sed -i "s|^\s*JAVA_TOOL_OPTIONS\s*=.*|    echo 'WARNING: JAVA_TOOL_OPTIONS env variable is UNSET.'|g" \
            ${FILE_TO_MODIFY}
    sed -i "s|^\s*export\s*JAVA_TOOL_OPTIONS.*|    echo 'WARNING: JAVA_TOOL_OPTIONS env variable is UNSET.'|g" \
            ${FILE_TO_MODIFY}
    sed -i 's|^\(\s*\)JAVA_GC_OPTS\s*=.*|\1JAVA_GC_OPTS=|g' ${FILE_TO_MODIFY}
    bash -n "${FILE_TO_MODIFY}"
    grep -B 3 -A 3 -i '\(bash\|JAVA_TOOL_OPTIONS\|JAVA_GC_OPTS\)' ${FILE_TO_MODIFY}
else
    echo " "
    echo "${ME}: WARNING: Could not modify file because it does not exist: ${FILE_TO_MODIFY} "
    echo " "
    echo " "
fi

KUBE_SLAVE_COMMON=${2-"/usr/local/bin/kube-slave-common.sh"}
if [ ! -f "${KUBE_SLAVE_COMMON}" ]; then
    echo "${ME}: ERROR: Kubernetes cloud configuration script not found: ${KUBE_SLAVE_COMMON}" >&2
    exit 1
fi

OLD_CA_BLOCK='    local crt_contents=$(openssl x509 -in "${KUBE_CA}")
    if [ $? -eq 1 ] ; then
      crt_contents=""
    fi'

if ! grep -Fxq '    crt_contents=$(cat "${KUBE_CA}") || return 1' "${KUBE_SLAVE_COMMON}"; then
    if [ "$(grep -F -A 3 '    local crt_contents=$(openssl x509 -in "${KUBE_CA}")' "${KUBE_SLAVE_COMMON}")" != "${OLD_CA_BLOCK}" ]; then
        echo "${ME}: ERROR: Unrecognized Kubernetes API CA handling in ${KUBE_SLAVE_COMMON}" >&2
        exit 1
    fi

    # openssl x509 emits only the first certificate in a rotating API CA bundle.
    sed -i '/local crt_contents=$(openssl x509 -in "${KUBE_CA}")/,+3c\
    local crt_contents\
    if ! grep -q "^-----BEGIN CERTIFICATE-----$" "${KUBE_CA}" || ! openssl crl2pkcs7 -nocrl -certfile "${KUBE_CA}" > /dev/null; then\
      echo "ERROR: Invalid Kubernetes API CA bundle: ${KUBE_CA}" >\&2\
      return 1\
    fi\
    crt_contents=$(cat "${KUBE_CA}") || return 1' "${KUBE_SLAVE_COMMON}"
fi
bash -n "${KUBE_SLAVE_COMMON}"
echo "${ME}: INFO: Kubernetes cloud configuration preserves the full API CA bundle."

echo "${ME}: INFO: Fixed openshift scripts."

