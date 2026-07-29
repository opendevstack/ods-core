#!/usr/bin/env bash
set -euo pipefail

# Migrate Jira project properties WEBHOOK_PROXY.SECRET and WEBHOOK_PROXY.URL
# for a single project.
#
# - WEBHOOK_PROXY.SECRET is stored in Jira as a base64-encoded value.
#   The HMAC is generated/used elsewhere as hex (Bitbucket/OpenShift); this
#   script converts it to base64 before storing it in Jira.
# - WEBHOOK_PROXY.URL is fetched from Jira (not from Bitbucket, since the
#   user may have customized it) and has the trigger_secret query parameter
#   removed before being written back.
#
# By default this runs as dry-run and prints what would change.
# Use --apply to perform changes.

source "$(dirname "$0")/common.sh"

APPLY=false
JIRA_INSTANCE=""
JIRA_TOKEN=""
PROJECT_KEY=""
HMAC_SECRET_HEX=""
JIRA_SCRIPT="$(dirname "$0")/jira-property-client.sh"

usage() {
  cat <<'EOF'
Usage:
  migrate-jira-webhook-properties.sh [options]

Description:
  Updates Jira project properties for the webhook proxy migration:
    - WEBHOOK_PROXY.SECRET: set to the HMAC secret, base64-encoded.
    - WEBHOOK_PROXY.URL: existing Jira value with trigger_secret query
      parameter removed. The URL is read from Jira, not from Bitbucket.
  Default mode is dry-run (no changes). Use --apply to execute changes.

Required:
  --jira-instance <url>            Jira instance URL (e.g., https://jira.example.com)
  --jira-token <token>             Jira API token for authentication
  --project-key <key>              Jira project key
  --hmac-secret-hex <hex>          HMAC secret in hex format (as used for Bitbucket/OpenShift)

Optional:
  --jira-script <path>             Override jira-property-client.sh script path
  --apply                          Apply changes. Default is dry-run.
  -h, --help                       Show this help.

Examples:
  scripts/migrate-jira-webhook-properties.sh \
    --jira-instance https://jira.example.com --jira-token abc123 \
    --project-key FOO --hmac-secret-hex "$(openssl rand -hex 32)"

  scripts/migrate-jira-webhook-properties.sh --apply \
    --jira-instance https://jira.example.com --jira-token abc123 \
    --project-key FOO --hmac-secret-hex 0123456789abcdef...
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --jira-instance)
      [[ $# -ge 2 ]] || usage_error "Missing value for --jira-instance"
      JIRA_INSTANCE="$2"
      shift
      ;;
    --jira-token)
      [[ $# -ge 2 ]] || usage_error "Missing value for --jira-token"
      JIRA_TOKEN="$2"
      shift
      ;;
    --project-key)
      [[ $# -ge 2 ]] || usage_error "Missing value for --project-key"
      PROJECT_KEY="$2"
      shift
      ;;
    --hmac-secret-hex)
      [[ $# -ge 2 ]] || usage_error "Missing value for --hmac-secret-hex"
      HMAC_SECRET_HEX="$2"
      shift
      ;;
    --jira-script)
      [[ $# -ge 2 ]] || usage_error "Missing value for --jira-script"
      JIRA_SCRIPT="$2"
      shift
      ;;
    --apply) APPLY=true ;;
    -h|--help) usage; exit 0 ;;
    *)
      usage_error "Unknown option: $1"
      ;;
  esac
  shift
done

require_cmd xxd
require_cmd base64
require_file "$JIRA_SCRIPT"

[[ -n "$JIRA_INSTANCE" ]] || usage_error "--jira-instance is required"
[[ -n "$JIRA_TOKEN" ]] || usage_error "--jira-token is required"
[[ -n "$PROJECT_KEY" ]] || usage_error "--project-key is required"
[[ -n "$HMAC_SECRET_HEX" ]] || usage_error "--hmac-secret-hex is required"

PROJECT_KEY="${PROJECT_KEY^^}"

log "Updating Jira properties for project ${PROJECT_KEY}"

# Get existing WEBHOOK_PROXY.URL (read from Jira, not Bitbucket, since the
# user may have customized it).
log "Fetching existing WEBHOOK_PROXY.URL from Jira..."
existing_url="$("$JIRA_SCRIPT" --get \
  --jira-instance "$JIRA_INSTANCE" \
  --jira-token "$JIRA_TOKEN" \
  --project-key "$PROJECT_KEY" \
  --property-key "WEBHOOK_PROXY.URL" 2>/dev/null || echo "")"

if [[ -z "$existing_url" ]]; then
  log "Warning: WEBHOOK_PROXY.URL property not found in Jira for project ${PROJECT_KEY}. Skipping URL update."
else
  log "Found existing URL: ${existing_url}"

  cleaned_url="$(remove_query_param "$existing_url" "trigger_secret")"

  if [[ "$existing_url" != "$cleaned_url" ]]; then
    log "Cleaned URL (removed trigger_secret): ${cleaned_url}"
  else
    log "URL already clean, no trigger_secret parameter found"
  fi

  jira_url_cmd=(
    "$JIRA_SCRIPT"
    --set
    --jira-instance "$JIRA_INSTANCE"
    --jira-token "$JIRA_TOKEN"
    --project-key "$PROJECT_KEY"
    --property-key "WEBHOOK_PROXY.URL"
    --property-value "$cleaned_url"
  )
  if [[ "$APPLY" == true ]]; then
    jira_url_cmd+=(--apply)
  fi

  log "Updating WEBHOOK_PROXY.URL in Jira..."
  "${jira_url_cmd[@]}"
fi

# Jira stores the secret as base64; HMAC is generated/used as hex elsewhere
# (Bitbucket/OpenShift), so convert it here.
hmac_b64="$(hex_to_base64 "$HMAC_SECRET_HEX")"
log "Converted HMAC to base64 for Jira storage"

jira_secret_cmd=(
  "$JIRA_SCRIPT"
  --set
  --jira-instance "$JIRA_INSTANCE"
  --jira-token "$JIRA_TOKEN"
  --project-key "$PROJECT_KEY"
  --property-key "WEBHOOK_PROXY.SECRET"
  --property-value "$hmac_b64"
)
if [[ "$APPLY" == true ]]; then
  jira_secret_cmd+=(--apply)
fi

log "Updating WEBHOOK_PROXY.SECRET in Jira..."
"${jira_secret_cmd[@]}"

log "Completed"
