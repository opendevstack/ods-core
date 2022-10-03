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
sed -i 's|^\(\s*\)set\s*-x\s*$|\1set -x\n\1echo "JNLP_JAVA_OPTIONS=\$JNLP_JAVA_OPTIONS"|g' ${FILEPATH}
sed -i "s|^\(\s*\)JAVA_TOOL_OPTIONS\s*=.*|\1JAVA_TOOL_OPTIONS=|g" ${FILEPATH}
sed -i 's|^\(\s*\)JAVA_GC_OPTS\s*=.*|\1JAVA_GC_OPTS=|g' ${FILEPATH}
sed -i 's|curl\s*-sS\s*|curl -sSLv |g' ${FILEPATH}

set -x
grep -B 5 -A 5 -i '\(bash\|JAVA_TOOL_OPTIONS\|JAVA_GC_OPTS\|JNLP_JAVA_OPTIONS\|curl\)' ${FILEPATH}


