#!/usr/bin/env bash
set -euo pipefail

# Get, set, or update Jira project properties via REST API.
#
# By default this runs as dry-run and prints what would change.
# Use --apply to perform changes.

source "$(dirname "$0")/common.sh"

APPLY=false
MODE="set"  # set, get
JIRA_INSTANCE=""
JIRA_TOKEN=""
PROJECT_KEY=""
PROPERTY_KEY=""
PROPERTY_VALUE=""
DRY_RUN=true

usage() {
  cat <<'EOF'
Usage:
  jira-property-client.sh [options]

Description:
  Gets, sets, or updates a project property in Jira using the REST API.
  Default mode is dry-run (no changes for set/update). Use --apply to execute changes.

Options:
  --get                           Get property mode (returns property value)
  --set                           Set/update property mode (default). Requires --property-value.
  --apply                         Apply changes (only for set mode). Default is dry-run.
  --jira-instance <url>           Jira instance URL (e.g., https://jira.example.com). Required.
  --jira-token <token>            Jira API token for authentication. Required.
  --project-key <key>             Jira project key. Required.
  --property-key <key>            Property key (e.g., PROJECT.IS_GXP). Required.
  --property-value <value>        Property value (required for set mode).
  -h, --help                      Show this help.

Examples:
  # Get a property
  scripts/jira-property-client.sh --get \
    --jira-instance https://jira.example.com --jira-token abc123 \
    --project-key FOO --property-key WEBHOOK_PROXY.URL

  # Set a property (dry-run)
  scripts/jira-property-client.sh --set \
    --jira-instance https://jira.example.com --jira-token abc123 \
    --project-key FOO --property-key PROJECT.IS_GXP --property-value true

  # Apply changes
  scripts/jira-property-client.sh --set --apply \
    --jira-instance https://jira.example.com --jira-token abc123 \
    --project-key FOO --property-key WEBHOOK_PROXY.URL --property-value "https://..."
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --get) MODE="get" ;;
    --set) MODE="set" ;;
    --apply) APPLY=true; DRY_RUN=false ;;
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
    --property-key)
      [[ $# -ge 2 ]] || usage_error "Missing value for --property-key"
      PROPERTY_KEY="$2"
      shift
      ;;
    --property-value)
      [[ $# -ge 2 ]] || usage_error "Missing value for --property-value"
      PROPERTY_VALUE="$2"
      shift
      ;;
    -h|--help) usage; exit 0 ;;
    *)
      usage_error "Unknown option: $1"
      ;;
  esac
  shift
done

require_cmd jq
require_cmd curl

if [[ -z "$JIRA_INSTANCE" ]]; then
  usage_error "--jira-instance is required"
fi

if [[ -z "$JIRA_TOKEN" ]]; then
  usage_error "--jira-token is required"
fi

if [[ -z "$PROJECT_KEY" ]]; then
  usage_error "--project-key is required"
fi

PROJECT_KEY="${PROJECT_KEY^^}"

if [[ -z "$PROPERTY_KEY" ]]; then
  usage_error "--property-key is required"
fi

if [[ "$MODE" == "set" && -z "$PROPERTY_VALUE" ]]; then
  usage_error "--property-value is required for set mode"
fi

# Handle GET mode
if [[ "$MODE" == "get" ]]; then
  log "Fetching property ${PROPERTY_KEY} from project ${PROJECT_KEY}..."

  response=$(curl -s \
    -H "Authorization: Bearer ${JIRA_TOKEN}" \
    -H "Accept: application/json" \
    -X GET \
    "${JIRA_INSTANCE}/rest/platform/1.0/projectproperties/list/${PROJECT_KEY}" \
    --insecure)

  property=$(echo "$response" | jq --arg key "$PROPERTY_KEY" '.[] | select(.propertyKey == $key) | .propertyValue' 2>/dev/null || echo "null")

  if [[ "$property" != "null" && -n "$property" ]]; then
    printf '%s\n' "$property" | sed 's/^"//;s/"$//'
    exit 0
  else
    log "Property ${PROPERTY_KEY} not found for project ${PROJECT_KEY}"
    exit 1
  fi
fi

log "Processing property ${PROPERTY_KEY} for project ${PROJECT_KEY}"

# Get current properties for the project
log "Fetching current properties from Jira..."
current_properties=$(curl -s \
  -H "Authorization: Bearer ${JIRA_TOKEN}" \
  -H "Accept: application/json" \
  -X GET \
  "${JIRA_INSTANCE}/rest/platform/1.0/projectproperties/list/${PROJECT_KEY}" \
  --insecure)

log "Current properties response:"
echo "$current_properties" | jq . >&2 || echo "$current_properties" >&2

# Extract the existing property if it exists
existing_property=$(echo "$current_properties" | jq --arg key "$PROPERTY_KEY" '.[] | select(.propertyKey == $key)' 2>/dev/null || echo "")

if [[ -n "$existing_property" && "$existing_property" != "null" ]]; then
  property_id=$(echo "$existing_property" | jq -r '.propertyId')
  existing_value=$(echo "$existing_property" | jq -r '.propertyValue')
  log "Found existing property ID: ${property_id}, current value: ${existing_value}"
  endpoint="update"
else
  log "Property does not exist, will create new one"
  endpoint="add"
  property_id=""
fi

# Prepare the payload
timestamp=$(date +%s)

if [[ -n "$property_id" ]]; then
  payload=$(jq -cn \
    --arg projectKey "$PROJECT_KEY" \
    --arg propertyKey "$PROPERTY_KEY" \
    --arg propertyValue "$PROPERTY_VALUE" \
    --arg propertyId "$property_id" \
    --arg timestamp "$timestamp" \
    '{
      propertyId: $propertyId,
      projectKey: $projectKey,
      propertyKey: $propertyKey,
      propertyValue: $propertyValue,
      mask: false,
      markup: false,
      lastUpdated: $timestamp,
      lastAuthor: "Automation"
    }')
else
  payload=$(jq -cn \
    --arg projectKey "$PROJECT_KEY" \
    --arg propertyKey "$PROPERTY_KEY" \
    --arg propertyValue "$PROPERTY_VALUE" \
    --arg timestamp "$timestamp" \
    '{
      projectKey: $projectKey,
      propertyKey: $propertyKey,
      propertyValue: $propertyValue,
      mask: false,
      markup: false,
      lastUpdated: $timestamp,
      lastAuthor: "Automation"
    }')
fi

if [[ "$APPLY" == true ]]; then
  log "Applying ${endpoint} for property ${PROPERTY_KEY}..."

  response=$(curl -s -w "\n%{http_code}" \
    -H "Authorization: Bearer ${JIRA_TOKEN}" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -X POST \
    "${JIRA_INSTANCE}/rest/platform/1.0/projectproperties/${endpoint}" \
    -d "$payload" \
    --insecure)

  http_code=$(echo "$response" | tail -n1)
  response_body=$(echo "$response" | head -n-1)

  if [[ "$http_code" == "200" || "$http_code" == "201" ]]; then
    if [[ "$endpoint" == "update" ]]; then
      log "Successfully updated property ${PROPERTY_KEY}"
    else
      log "Successfully added property ${PROPERTY_KEY}"
    fi
  else
    log "Error: HTTP ${http_code}"
    echo "$response_body" >&2
    exit 1
  fi
else
  log "DRY-RUN: Would ${endpoint} property ${PROPERTY_KEY}"
  log "DRY-RUN payload:"
  echo "$payload" | jq . >&2
fi

log "Completed"
