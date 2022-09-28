#!/bin/bash
set -eu -o pipefail

FILEPATH=${1-"/usr/local/bin/openshift-run-jnlp-client"}

if [ ! -f ${FILEPATH} ]; then
    echo " "
    echo "ERROR: File does not exist: ${FILEPATH}"
    echo " "
    exit 1
fi

sed -i 's|\#\!/bin/bash|\#\!/bin/bash -x|g' ${FILEPATH}
sed -i "s|^\s*JAVA_TOOL_OPTIONS\s*=.*|    echo 'WARNING: JAVA_TOOL_OPTIONS env variable is UNSET.'|g" \
    ${FILEPATH}
sed -i "s|^\s*export\s*JAVA_TOOL_OPTIONS.*|    echo 'WARNING: JAVA_TOOL_OPTIONS env variable is UNSET.'|g" \
    ${FILEPATH}
sed -i 's|^\(\s*\)JAVA_GC_OPTS\s*=.*|\1JAVA_GC_OPTS=|g' ${FILEPATH}
sed -i 's|curl\s*-sS\s*|curl -sSLv |g' ${FILEPATH}

grep -B 3 -A 3 -i '\(bash\|JAVA_TOOL_OPTIONS\|JAVA_GC_OPTS\|curl\)' ${FILEPATH}


