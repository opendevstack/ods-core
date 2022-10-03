#!/bin/bash
set -eu -o pipefail

ME="$(basename $0)"

for filepath in $@; do
    if [ -f ${filepath} ]; then
        sed -i 's|enabled\s*=\s*1|enabled=0|g' ${filepath}
        grep --with-filename 'enabled\s*=' ${filepath}
    else
        echo "File does not exist: ${filepath}"
    fi
done
