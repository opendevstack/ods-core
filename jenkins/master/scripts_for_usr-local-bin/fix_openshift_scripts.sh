#!/bin/bash
set -eu -o pipefail

ME="$(basename $0)"
echo "${ME}: INFO: Fixing openshift scripts..."

FILE_TO_MODIFY=${1-"/usr/libexec/s2i/run"}

if [ -f ${FILE_TO_MODIFY} ]; then
    sed -i 's|\#\!/bin/bash|\#\!/bin/bash -x|g' ${FILE_TO_MODIFY}
    sed -i "s|^\s*JAVA_TOOL_OPTIONS\s*=.*|    echo 'WARNING: JAVA_TOOL_OPTIONS env variable is UNSET.'|g" \
            ${FILE_TO_MODIFY}
    sed -i "s|^\s*export\s*JAVA_TOOL_OPTIONS.*|    echo 'WARNING: JAVA_TOOL_OPTIONS env variable is UNSET.'|g" \
            ${FILE_TO_MODIFY}
    sed -i 's|^\(\s*\)JAVA_GC_OPTS\s*=.*|\1JAVA_GC_OPTS=|g' ${FILE_TO_MODIFY}
    grep -B 3 -A 3 -i '\(bash\|JAVA_TOOL_OPTIONS\|JAVA_GC_OPTS\)' ${FILE_TO_MODIFY}
else
    echo " "
    echo "${ME}: WARNING: Could not modify file because it does not exist: ${FILE_TO_MODIFY} "
    echo " "
    echo " "
fi

echo "${ME}: INFO: Fixed openshift scripts."

