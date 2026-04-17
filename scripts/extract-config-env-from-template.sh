#!/bin/bash

set -euo pipefail

if [ -t 0 ]; then
  echo "Usage: <yaml-input> | $(basename "$0")" >&2
  exit 1
fi

yq -r '
  # --- CONFIGMAPS (sin application.yaml) ---
  select(.kind=="ConfigMap")
  | select(.data."application.yaml" == null)
  | .data
  | to_entries[]
  | "\(.key)=\"\(.value)\""

  # --- SECRETS (decodificados base64) ---
  ,
  select(.kind=="Secret")
  | .data
  | to_entries[]
  | "\(.key)=\"\(.value | @base64d)\""
' - | grep -v '^=' | sort
