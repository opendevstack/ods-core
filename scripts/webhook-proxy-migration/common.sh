#!/usr/bin/env bash
# Common shell functions shared by the webhook-proxy-migration scripts.
#
# Source this file from other scripts, e.g.:
#   source "$(dirname "$0")/common.sh"
#
# Notes:
#   - log() writes to stderr so it never pollutes stdout captured via
#     command substitution (e.g. `value="$(some-script.sh --get ...)"`).
#   - usage_error() expects the sourcing script to define a `usage` function.

log() {
  printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" >&2
}

usage_error() {
  echo "Error: $*" >&2
  echo >&2
  usage >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

require_file() {
  [[ -f "$1" ]] || {
    echo "File not found: $1" >&2
    exit 1
  }
}

require_oc_login() {
  local oc_bin="${1:-oc}"
  "$oc_bin" whoami >/dev/null 2>&1 || {
    echo "Not logged in to an OpenShift cluster. Please run: $oc_bin login" >&2
    exit 1
  }
}

# Removes a single query parameter from a URL, preserving the others.
# Usage: remove_query_param "$url" "param_name"
remove_query_param() {
  local url="$1"
  local param="$2"

  if [[ "$url" != *"?"* ]]; then
    printf '%s\n' "$url"
    return
  fi

  local base="${url%%\?*}"
  local query="${url#*\?}"
  local params=()

  IFS='&' read -ra PARTS <<< "$query"
  for part in "${PARTS[@]}"; do
    local key="${part%%=*}"
    if [[ "$key" != "$param" ]]; then
      params+=("$part")
    fi
  done

  if [[ ${#params[@]} -eq 0 ]]; then
    printf '%s\n' "$base"
  else
    printf '%s?%s\n' "$base" "$(IFS='&'; echo "${params[*]}")"
  fi
}

# Converts a hex-encoded secret to base64.
# Usage: hex_to_base64 "$hex"
hex_to_base64() {
  local hex="$1"
  printf '%s' "$hex" | xxd -r -p | base64 | tr -d '\n'
}
