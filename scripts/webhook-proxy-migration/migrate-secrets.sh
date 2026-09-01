#!/bin/bash

set -euo pipefail

CONFIGMAP_NAME="application.properties"
SECRET_NAME="ods-provisioning-app"

usage() {
    echo "Usage: $0 -n <namespace>"
    exit 1
}

NAMESPACE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

if [[ -z "$NAMESPACE" ]]; then
    echo "Namespace is required."
    usage
fi

# Properties to migrate from ConfigMap to Secret
PROPERTIES=(
  "crowd.application.name"
  "crowd.application.password"
  "jira.admin_user"
  "jira.admin_password"
  "confluence.admin_user"
  "confluence.admin_password"
  "bitbucket.admin_user"
  "bitbucket.admin_password"
  "spring.mail.password"
  "jasypt.encryptor.password"
)

TMP_FILE=$(mktemp)

cleanup() {
  rm -f "$TMP_FILE"
}
trap cleanup EXIT

echo "Reading application.properties from ConfigMap ${CONFIGMAP_NAME}..."

oc get configmap "${CONFIGMAP_NAME}" \
  -n "${NAMESPACE}" \
  -o jsonpath='{.data.properties}' > "${TMP_FILE}"

# Create secret if it does not exist
if ! oc get secret "${SECRET_NAME}" -n "${NAMESPACE}" >/dev/null 2>&1; then
    echo "Creating secret ${SECRET_NAME}..."
    oc create secret generic "${SECRET_NAME}" \
        -n "${NAMESPACE}"
fi

MODIFIED=false

for PROPERTY in "${PROPERTIES[@]}"; do

    # Find first non-commented occurrence
    LINE=$(grep -E "^[[:space:]]*${PROPERTY}[[:space:]]*=" "${TMP_FILE}" || true)

    if [[ -z "${LINE}" ]]; then
        echo "Property ${PROPERTY} not found"
        continue
    fi

    VALUE="${LINE#*=}"

    # Spring relaxed binding:
    # my.property.name -> MY_PROPERTY_NAME
    ENV_VAR=$(echo "${PROPERTY}" | tr '[:lower:].-' '[:upper:]__')

    echo "Found ${PROPERTY} -> ${ENV_VAR}"

    # Check if entry already exists in secret
    if oc get secret "${SECRET_NAME}" \
        -n "${NAMESPACE}" \
        -o jsonpath="{.data.${ENV_VAR}}" 2>/dev/null | grep -q .; then

        echo "Secret key ${ENV_VAR} already exists, leaving untouched"

    else
        echo "Adding ${ENV_VAR} to secret"

        oc patch secret "${SECRET_NAME}" \
          -n "${NAMESPACE}" \
          --type merge \
          -p "$(printf '{"stringData":{"%s":"%s"}}' "${ENV_VAR}" "${VALUE}")"
    fi

    # Remove property from application.properties
    sed -i "/^[[:space:]]*${PROPERTY}[[:space:]]*=/d" "${TMP_FILE}"

    MODIFIED=true

done

if [[ "${MODIFIED}" == "true" ]]; then
    echo "Updating ConfigMap ${CONFIGMAP_NAME}..."

    oc create configmap "${CONFIGMAP_NAME}" \
      --from-file=properties="${TMP_FILE}" \
      -n "${NAMESPACE}" \
      --dry-run=client -o yaml | oc apply -f -

    echo "ConfigMap updated"
else
    echo "No changes required"
fi

echo "Done"
