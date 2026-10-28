#!/usr/bin/env bash
set -euo pipefail

# Migrate webhook-proxy OpenShift secrets to include webhook-hmac-secret.
#
# By default this runs as dry-run and prints what would change.
# Use --apply to perform changes.

APPLY=false
OC_BIN="oc"
PROJECT=""
HMAC_SECRET_B64=""
HMAC_SECRET_RAW=""

usage() {
  cat <<'EOF'
Usage:
  migrate-webhook-proxy-secret.sh [options]

Description:
  Migrates secret/webhook-proxy in one ODS project namespace by setting
  data.webhook-hmac-secret.
  Default mode is dry-run (no changes). Use --apply to execute changes.

Options:
  --apply                         Apply changes. Default is dry-run.
  --oc-bin <path>                 oc binary to use. Default: oc
  --project <project-id>          Single ODS project ID (without -cd suffix).
  --hmac-secret <raw-secret>      Raw HMAC secret value.
  --hmac-secret-b64 <base64>      Base64 encoded HMAC secret value.
  -h, --help                      Show this help.

Selection:
  You must provide --project.

Required:
  - Exactly one of:
      --hmac-secret <raw-secret>
      --hmac-secret-b64 <base64>
  - --project <project-id>

Behavior:
  - Target namespace is always: <project-id>-cd
  - If secret/webhook-proxy does not exist, the namespace is skipped.

Examples:
  scripts/migrate-webhook-proxy-secret.sh --project foo --hmac-secret "$(openssl rand -hex 32)"
  scripts/migrate-webhook-proxy-secret.sh --apply --project foo --hmac-secret-b64 ABCDEF==
EOF
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

require_oc_login() {
  "$OC_BIN" whoami >/dev/null 2>&1 || {
    echo "Not logged in to an OpenShift cluster. Please run: $OC_BIN login" >&2
    exit 1
  }
}

log() {
  printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"
}

usage_error() {
  echo "Error: $*" >&2
  echo >&2
  usage >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    help) usage; exit 0 ;;
    --apply) APPLY=true ;;
    --oc-bin)
      [[ $# -ge 2 ]] || usage_error "Missing value for --oc-bin"
      OC_BIN="$2"
      shift
      ;;
    --project)
      [[ $# -ge 2 ]] || usage_error "Missing value for --project"
      PROJECT="$2"
      shift
      ;;
    --hmac-secret)
      [[ $# -ge 2 ]] || usage_error "Missing value for --hmac-secret"
      HMAC_SECRET_RAW="$2"
      shift
      ;;
    --hmac-secret-b64)
      [[ $# -ge 2 ]] || usage_error "Missing value for --hmac-secret-b64"
      HMAC_SECRET_B64="$2"
      shift
      ;;
    -h|--help) usage; exit 0 ;;
    *)
      usage_error "Unknown option: $1"
      ;;
  esac
  shift
done

require_cmd "$OC_BIN"
require_oc_login
require_cmd jq
require_cmd base64

if [[ -z "$HMAC_SECRET_RAW" && -z "$HMAC_SECRET_B64" ]]; then
  usage_error "Either --hmac-secret or --hmac-secret-b64 is required"
fi

if [[ -n "$HMAC_SECRET_RAW" && -n "$HMAC_SECRET_B64" ]]; then
  usage_error "Use only one of --hmac-secret or --hmac-secret-b64"
fi

if [[ -n "$HMAC_SECRET_RAW" ]]; then
  HMAC_SECRET_B64="$(printf '%s' "$HMAC_SECRET_RAW" | base64 | tr -d '\n')"
fi

if [[ -z "$PROJECT" ]]; then
  usage_error "--project is required"
fi

NAMESPACE="${PROJECT}-cd"

log "Processing namespace: ${NAMESPACE}"

if ! "$OC_BIN" -n "$NAMESPACE" get secret webhook-proxy >/dev/null 2>&1; then
  log "Skipping ${NAMESPACE}: secret/webhook-proxy not found"
  log "Completed"
  exit 0
fi

patch_payload="$(jq -cn --arg value "$HMAC_SECRET_B64" '{data:{"webhook-hmac-secret":$value}}')"

if [[ "$APPLY" == true ]]; then
  "$OC_BIN" -n "$NAMESPACE" patch secret webhook-proxy --type merge -p "$patch_payload" >/dev/null
  log "Patched secret/webhook-proxy in ${NAMESPACE}"
else
  log "DRY-RUN patch secret in ${NAMESPACE}: ${patch_payload}"
fi

log "Completed"
