#!/usr/bin/env bash
# Start build of given image and follows the output.
# After build finishes, we verify status is "Complete".

set -ue

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ODS_CORE_DIR=${SCRIPT_DIR%/*}
ODS_CONFIGURATION_DIR="${ODS_CORE_DIR}/../ods-configuration"

if [ ! -f "${ODS_CONFIGURATION_DIR}/ods-core.env" ]; then
    echo "Configuration could not be located at ${ODS_CONFIGURATION_DIR}/ods-core.env."
    exit 1
fi

PARAM_NAME=${1:-""}

if [ -z "${PARAM_NAME}" ]; then
    echo "No param name given. Usage: $0 <PARAM-NAME>"
    exit 1
fi

if ! grep "${PARAM_NAME}" "${ODS_CONFIGURATION_DIR}/ods-core.env" > /dev/null; then
    echo "No param ${PARAM_NAME} found." 
    exit 1
fi

grep "${PARAM_NAME}" "${ODS_CONFIGURATION_DIR}/ods-core.env" | cut -d "=" -f 2-
