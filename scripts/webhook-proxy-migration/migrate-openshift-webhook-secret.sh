#!/usr/bin/env bash
set -euo pipefail

# Migrate webhook-proxy OpenShift secrets to include webhook-hmac-secret.
#
# By default this runs as dry-run and prints what would change.
# Use --apply to perform changes.

source "$(dirname "$0")/common.sh"

APPLY=false
OC_BIN="oc"
PROJECT=""
HMAC_SECRET_B64=""
HMAC_SECRET_RAW=""
ALLOWED_IP_RANGES=""

usage() {
  cat <<'EOF'
Usage:
  migrate-openshift-webhook-secret.sh [options]

Description:
  Migrates secret/webhook-proxy in one ODS project namespace by setting
  data.webhook-hmac-secret.
  Adds the allowed IP range list to the dc/webhook-proxy environment.
  Default mode is dry-run (no changes). Use --apply to execute changes.

Options:
  --apply                         Apply changes. Default is dry-run.
  --oc-bin <path>                 oc binary to use. Default: oc
  --project <project-id>          Single ODS project ID (without -cd suffix).
  --hmac-secret <raw-secret>      Raw HMAC secret value.
  --hmac-secret-b64 <base64>      Base64 encoded HMAC secret value.
  --allowed-ip-ranges <ip-ranges> Comma-separated list of allowed IP ranges.
  -h, --help                      Show this help.

Selection:
  You must provide --project.

Required:
  - Exactly one of:
      --hmac-secret <raw-secret>
      --hmac-secret-b64 <base64>
  - --project <project-id>
  - --allowed-ip-ranges <ip-ranges>

Behavior:
  - Target namespace is always: <project-id>-cd
  - If secret/webhook-proxy does not exist, it will be created.

Examples:
  scripts/migrate-openshift-webhook-secret.sh --project foo --hmac-secret "$(openssl rand -hex 32)" --allowed-ip-ranges 10.0.0.0/8
  scripts/migrate-openshift-webhook-secret.sh --apply --project foo --hmac-secret-b64 ABCDEF== --allowed-ip-ranges 10.0.0.0/8,192.168.0.0/16
EOF
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
    --allowed-ip-ranges)
      [[ $# -ge 2 ]] || usage_error "Missing value for --allowed-ip-ranges"
      ALLOWED_IP_RANGES="$2"
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
require_oc_login "$OC_BIN"
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

if [[ -z "$HMAC_SECRET_RAW" ]]; then
  HMAC_SECRET_RAW="$(printf '%s' "$HMAC_SECRET_B64" | base64 -d)"
fi

if [[ -z "$PROJECT" ]]; then
  usage_error "--project is required"
fi

NAMESPACE="${PROJECT}-cd"

log "Processing namespace: ${NAMESPACE}"

ROLLOUT_PAUSED_BY_SCRIPT=false

rollout() {
  "$OC_BIN" -n "$NAMESPACE" rollout latest dc/webhook-proxy >/dev/null 2>&1 || true
  if [[ "$ROLLOUT_PAUSED_BY_SCRIPT" == true ]]; then
    log "Restarting webhook-proxy in ${NAMESPACE}..."
    "$OC_BIN" -n "$NAMESPACE" rollout resume dc/webhook-proxy >/dev/null 2>&1 || true
    ROLLOUT_PAUSED_BY_SCRIPT=false
  fi
}

trap rollout EXIT

SECRET_EXISTS=true

if ! "$OC_BIN" -n "$NAMESPACE" get secret webhook-proxy >/dev/null 2>&1; then
  SECRET_EXISTS=false
  log "secret/webhook-proxy does not exist in ${NAMESPACE}"
fi

if [[ "$APPLY" == true ]]; then

  if [[ "$SECRET_EXISTS" == true ]]; then
    patch_payload="$(jq -cn --arg value "$HMAC_SECRET_B64" '{data:{"webhook-hmac-secret":$value}}')"
    "$OC_BIN" -n "$NAMESPACE" patch secret webhook-proxy --type merge -p "$patch_payload" >/dev/null
    log "Patched secret/webhook-proxy in ${NAMESPACE}"
  else
    "$OC_BIN" -n "$NAMESPACE" create secret generic webhook-proxy \
      --from-literal=webhook-hmac-secret="$HMAC_SECRET_RAW" \
      >/dev/null

    log "Created secret/webhook-proxy in ${NAMESPACE}"
  fi

  if [[ "$("$OC_BIN" -n "$NAMESPACE" get dc webhook-proxy -o jsonpath='{.spec.paused}' 2>/dev/null)" != "true" ]]; then
    "$OC_BIN" -n "$NAMESPACE" rollout pause dc/webhook-proxy && ROLLOUT_PAUSED_BY_SCRIPT=true
  fi

  "$OC_BIN" -n "$NAMESPACE" set env dc/webhook-proxy ALLOWED_WEBHOOK_IP_RANGES="${ALLOWED_IP_RANGES}"
  log "Added environment variable ALLOWED_WEBHOOK_IP_RANGES=${ALLOWED_IP_RANGES} to deployment config webhook-proxy in ${NAMESPACE}"

  "$OC_BIN" -n "$NAMESPACE" set env dc/webhook-proxy WEBHOOK_HMAC_SECRET- || true

  patch_payload='[{ "op": "add", "path": "/spec/template/spec/containers/0/env/-", "value": { "name": "WEBHOOK_HMAC_SECRET", "valueFrom": { "secretKeyRef": { "name": "webhook-proxy", "key": "webhook-hmac-secret" }}}}]'

  "$OC_BIN" -n "$NAMESPACE" patch dc/webhook-proxy --type json -p "$patch_payload"

  log "Added environment variable WEBHOOK_HMAC_SECRET to dc/webhook-proxy in ${NAMESPACE}"

  rollout

else

  if [[ "$SECRET_EXISTS" == true ]]; then
    log "DRY-RUN would patch secret/webhook-proxy in ${NAMESPACE}"
  else
    log "DRY-RUN would create secret/webhook-proxy in ${NAMESPACE}"
  fi

  log "DRY-RUN would add the environment variable ALLOWED_WEBHOOK_IP_RANGES=${ALLOWED_IP_RANGES} to deployment config webhook-proxy in ${NAMESPACE}"
  log "DRY-RUN would add the environment variable WEBHOOK_HMAC_SECRET to deployment config webhook-proxy in ${NAMESPACE}"
  log "DRY-RUN would restart the Webhook Proxy"

fi

log "Completed"
