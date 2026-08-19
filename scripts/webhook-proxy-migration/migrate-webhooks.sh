#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

APPLY=false
BASE_URL=""
PROJECTS_FILE=""
TOKEN=""
USERNAME=""
PASSWORD=""
OC_BIN="oc"
URL_MATCH="webhook-proxy-"
JIRA_INSTANCE=""
JIRA_TOKEN=""
PROXY_SCRIPT="$(dirname "$0")/migrate-openshift-webhook-secret.sh"
BITBUCKET_SCRIPT="$(dirname "$0")/migrate-bitbucket-webhook-hmac.sh"
JIRA_SCRIPT="$(dirname "$0")/migrate-jira-webhook-properties.sh"
ALLOWED_IP_RANGES=""

usage() {
  cat <<'EOF'
Usage:
  migrate-webhooks.sh [options]

Description:
  Reads project keys from a file and, for each project:
    1) Generates a new HMAC secret
    2) Runs webhook proxy secret migration
    3) Runs Bitbucket webhook migration
    4) Updates Jira project properties with webhook secret and URL

Required:
  --projects-file <path>          File with project keys, one per line
  --base-url <url>                Bitbucket base URL
  --jira-instance <url>           Jira instance URL (e.g., https://jira.example.com)
  --jira-token <token>            Jira API token for authentication
  --allowed-ip-ranges <ip-ranges> A comma-separated list of allowed IP ranges

Authentication for Bitbucket (choose one):
  --token <token>                 Personal access token for Bitbucket
  --username <user> --password <pass>

Optional:
  --oc-bin <path>                 oc binary to use for proxy migration. Default: oc
  --url-match <substring>         URL filter for Bitbucket migration. Default: webhook-proxy-
  --proxy-script <path>           Override proxy migration script path
  --bitbucket-script <path>       Override Bitbucket migration script path
  --jira-script <path>            Override Jira webhook properties script path
  --apply                         Apply changes. Default is dry-run
  -h, --help                      Show help

Notes:
  - Empty lines and lines starting with # are ignored in the projects file.
  - The same generated HMAC is used for steps 2 and 3 per project.
  - Jira properties WEBHOOK_PROXY.SECRET and WEBHOOK_PROXY.URL are updated in step 4.
EOF
}

run_jira_migration() {
  local project="$1"
  local hmac_secret="$2"

  jira_cmd=(
    "$JIRA_SCRIPT"
    --jira-instance "$JIRA_INSTANCE"
    --jira-token "$JIRA_TOKEN"
    --project-key "$project"
    --hmac-secret "$hmac_secret"
  )
  if [[ "$APPLY" == true ]]; then
    jira_cmd+=(--apply)
  fi

  log "Running Jira webhook properties migration for ${project}"
  "${jira_cmd[@]}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --projects-file)
      [[ $# -ge 2 ]] || usage_error "Missing value for --projects-file"
      PROJECTS_FILE="$2"
      shift
      ;;
    --base-url)
      [[ $# -ge 2 ]] || usage_error "Missing value for --base-url"
      BASE_URL="$2"
      shift
      ;;
    --token)
      [[ $# -ge 2 ]] || usage_error "Missing value for --token"
      TOKEN="$2"
      shift
      ;;
    --username)
      [[ $# -ge 2 ]] || usage_error "Missing value for --username"
      USERNAME="$2"
      shift
      ;;
    --password)
      [[ $# -ge 2 ]] || usage_error "Missing value for --password"
      PASSWORD="$2"
      shift
      ;;
    --oc-bin)
      [[ $# -ge 2 ]] || usage_error "Missing value for --oc-bin"
      OC_BIN="$2"
      shift
      ;;
    --url-match)
      [[ $# -ge 2 ]] || usage_error "Missing value for --url-match"
      URL_MATCH="$2"
      shift
      ;;
    --proxy-script)
      [[ $# -ge 2 ]] || usage_error "Missing value for --proxy-script"
      PROXY_SCRIPT="$2"
      shift
      ;;
    --bitbucket-script)
      [[ $# -ge 2 ]] || usage_error "Missing value for --bitbucket-script"
      BITBUCKET_SCRIPT="$2"
      shift
      ;;
    --jira-script)
      [[ $# -ge 2 ]] || usage_error "Missing value for --jira-script"
      JIRA_SCRIPT="$2"
      shift
      ;;
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
    --allowed-ip-ranges)
      [[ $# -ge 2 ]] || usage_error "Missing value for --allowed-ip-ranges"
      ALLOWED_IP_RANGES="$2"
      shift
      ;;
    --apply)
      APPLY=true
      ;;
    -h|--help|help)
      usage
      exit 0
      ;;
    *)
      usage_error "Unknown option: $1"
      ;;
  esac
  shift
done

[[ -n "$PROJECTS_FILE" ]] || usage_error "--projects-file is required"
[[ -n "$BASE_URL" ]] || usage_error "--base-url is required"
[[ -n "$JIRA_INSTANCE" ]] || usage_error "--jira-instance is required"
[[ -n "$JIRA_TOKEN" ]] || usage_error "--jira-token is required"
[[ -n "$ALLOWED_IP_RANGES" ]] || usage_error "--allowed-ip-ranges is required"

if [[ -n "$TOKEN" && ( -n "$USERNAME" || -n "$PASSWORD" ) ]]; then
  usage_error "Use either --token or --username/--password, not both"
fi

if [[ -z "$TOKEN" && ( -z "$USERNAME" || -z "$PASSWORD" ) ]]; then
  usage_error "Authentication is required: use --token or --username/--password"
fi

require_cmd openssl
require_cmd "$OC_BIN"
require_file "$PROJECTS_FILE"
require_file "$PROXY_SCRIPT"
require_file "$BITBUCKET_SCRIPT"
require_file "$JIRA_SCRIPT"

mapfile -t PROJECTS < <(grep -Ev '^\s*(#|$)' "$PROJECTS_FILE" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')

if [[ ${#PROJECTS[@]} -eq 0 ]]; then
  usage_error "No projects found in file: $PROJECTS_FILE"
fi

log "Projects loaded: ${#PROJECTS[@]}"
log "Mode: $( [[ "$APPLY" == true ]] && echo apply || echo dry-run )"

for project in "${PROJECTS[@]}"; do
  log "Processing project: ${project}"

  hmac_secret="$(openssl rand -base64 32)"
  log "Generated HMAC secret for project ${project}"

  proxy_cmd=(
    "$PROXY_SCRIPT"
    --oc-bin "$OC_BIN"
    --project "$project"
    --hmac-secret "$hmac_secret"
    --allowed-ip-ranges "$ALLOWED_IP_RANGES"
  )
  if [[ "$APPLY" == true ]]; then
    proxy_cmd+=(--apply)
  fi

  log "Running proxy secret migration for ${project}"
  "${proxy_cmd[@]}"

  bitbucket_cmd=(
    "$BITBUCKET_SCRIPT"
    --base-url "$BASE_URL"
    --project "$project"
    --webhook-secret "$hmac_secret"
    --url-match "$URL_MATCH"
  )
  if [[ -n "$TOKEN" ]]; then
    bitbucket_cmd+=(--token "$TOKEN")
  else
    bitbucket_cmd+=(--username "$USERNAME" --password "$PASSWORD")
  fi
  if [[ "$APPLY" == true ]]; then
    bitbucket_cmd+=(--apply)
  fi

  log "Running Bitbucket webhook migration for ${project}"
  "${bitbucket_cmd[@]}"

  run_jira_migration "$project" "$hmac_secret"
done

log "All projects processed"
