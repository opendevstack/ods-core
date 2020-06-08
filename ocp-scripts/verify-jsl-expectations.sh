#!/bin/bash

# This script verifies that the clone-project.sh and the export-/import
# scripts used by it are not inadvertantly renamed.
# ods-jenkins-shared-library depends on this.

# The script is expected to be exucuted from the project root.

set -e

script_names=(clone-project.sh export-project.sh import-project.sh)

for name in "${script_names[@]}"; do
    script_name="ocp-scripts/$name"
    if [ ! -f "$script_name" ]; then
        echo "$script_name must exist: ods-jenkins-shared-library depends on this"
        exit 1
    fi
done
