#!/usr/bin/env bash
set -eu
set -o pipefail

curl -sS --insecure -u $1: $2/api/navigation/component?componentKey=$3 | jq 'del(.analysisDate)' | jq 'del(.version)' | jq  'del(.id)' | jq 'del(.qualityProfiles[].key)' | jq 'del(.qualityGate.key)'
