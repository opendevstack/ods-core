#!/usr/bin/env bash
set -eu
set -o pipefail

curl -sS --insecure -u $1: $2/api/navigation/component?component=$3 | \
jq 'del(.analysisDate)' | \
jq 'del(.version)' | \
jq 'del(.id)' | \
jq 'del(.qualityProfiles[].key)' | \
jq 'del(.qualityGate.key)' | \
jq 'del(.extensions[] | select(.))' | \
jq 'del(.qualityProfiles[] | select(.language == "xml"))' | \
jq 'del(.organization)'
