#!/usr/bin/env bash
set -euo pipefail

# Migrate Bitbucket repository webhooks from trigger_secret URL param to
# webhook secret + clean URL query string.
#
# Default mode is dry-run.

source "$(dirname "$0")/common.sh"

APPLY=false
BASE_URL=""
PROJECT_KEY=""
TOKEN=""
USERNAME=""
PASSWORD=""
WEBHOOK_SECRET=""
SECRET_CONFIG_KEY=""
SECRET_CONFIG_KEY_EXPLICIT=false
URL_MATCH="webhook-proxy-"
REPO=""
REPOS_FILE=""
BACKUP_FILE="bitbucket-webhook-backup-$(date +%Y%m%d-%H%M%S).jsonl"
BACKUP_FILE_EXPLICIT=false

usage() {
  cat <<'EOF'
Usage:
  migrate-bitbucket-webhook-hmac.sh [options]

Required:
  --base-url <url>                Bitbucket base URL, e.g. https://bitbucket.example.com
  --project <key>                 Bitbucket project key
  --webhook-secret <secret>       HMAC secret to set in each webhook config

Authentication (choose one):
  --token <token>                 Personal access token (Bearer)
  --username <user> --password <pass>

Scope:
  --repo <slug>                   Process a single repository
  --repos-file <path>             Process repository slugs from file (one per line)
                                  If neither is provided, all repos in the project are scanned.

Optional:
  --secret-config-key <key>       Force key in webhook configuration for secret.
                                  If omitted, the key is auto-detected per webhook:
                                  prefers 'secret', else first existing key containing 'secret',
                                  else falls back to 'secret'.
  --url-match <substring>         Only process webhooks whose URL contains this text. Default: webhook-proxy-
  --backup-file <path>            JSONL backup file for current webhook objects
  --apply                         Apply updates. Default is dry-run
  -h, --help                      Show help

Notes:
  - This script removes trigger_secret query parameter from webhook URLs.
  - It preserves other query parameters and existing webhook properties.
  - Keep a backup before applying (backup is always written).
  - If your Bitbucket/plugin stores webhook secret in a non-standard key,
    pass --secret-config-key explicitly.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base-url) BASE_URL="$2"; shift ;;
    --project) PROJECT_KEY="$2"; shift ;;
    --token) TOKEN="$2"; shift ;;
    --username) USERNAME="$2"; shift ;;
    --password) PASSWORD="$2"; shift ;;
    --webhook-secret) WEBHOOK_SECRET="$2"; shift ;;
    --secret-config-key) SECRET_CONFIG_KEY="$2"; SECRET_CONFIG_KEY_EXPLICIT=true; shift ;;
    --url-match) URL_MATCH="$2"; shift ;;
    --repo) REPO="$2"; shift ;;
    --repos-file) REPOS_FILE="$2"; shift ;;
    --backup-file) BACKUP_FILE="$2"; BACKUP_FILE_EXPLICIT=true; shift ;;
    --apply) APPLY=true ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
  shift
done

require_cmd curl
require_cmd jq

if [[ -z "$BASE_URL" || -z "$PROJECT_KEY" || -z "$WEBHOOK_SECRET" ]]; then
  echo "Missing required options" >&2
  usage
  exit 1
fi

if [[ -n "$TOKEN" && ( -n "$USERNAME" || -n "$PASSWORD" ) ]]; then
  echo "Use either token or username/password auth, not both" >&2
  exit 1
fi

if [[ -z "$TOKEN" && ( -z "$USERNAME" || -z "$PASSWORD" ) ]]; then
  echo "Authentication is required: use --token or --username/--password" >&2
  exit 1
fi

if [[ -n "$REPO" && -n "$REPOS_FILE" ]]; then
  echo "Use either --repo or --repos-file, not both" >&2
  exit 1
fi

BASE_URL="${BASE_URL%/}"

if [[ "$BACKUP_FILE_EXPLICIT" == false ]]; then
  BACKUP_FILE="bitbucket-webhook-backup-${PROJECT_KEY}-$(date +%Y%m%d-%H%M%S).jsonl"
fi

curl_api() {
  local method="$1"
  local path="$2"
  local data="${3:-}"
  local url="${BASE_URL}${path}"

  if [[ -n "$TOKEN" ]]; then
    if [[ -n "$data" ]]; then
      curl -fsS -X "$method" "$url" \
        -H "Authorization: Bearer ${TOKEN}" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        --data "$data"
    else
      curl -fsS -X "$method" "$url" \
        -H "Authorization: Bearer ${TOKEN}" \
        -H "Accept: application/json"
    fi
  else
    if [[ -n "$data" ]]; then
      curl -fsS -X "$method" "$url" \
        -u "${USERNAME}:${PASSWORD}" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        --data "$data"
    else
      curl -fsS -X "$method" "$url" \
        -u "${USERNAME}:${PASSWORD}" \
        -H "Accept: application/json"
    fi
  fi
}

list_repos() {
  if [[ -n "$REPO" ]]; then
    printf '%s\n' "$REPO"
    return
  fi

  if [[ -n "$REPOS_FILE" ]]; then
    grep -Ev '^\s*(#|$)' "$REPOS_FILE" | sed 's/[[:space:]]*$//'
    return
  fi

  local start=0
  local limit=100
  while true; do
    local response
    response="$(curl_api GET "/rest/api/latest/projects/${PROJECT_KEY}/repos?limit=${limit}&start=${start}")"

    jq -r '.values[].slug' <<<"$response"

    if [[ "$(jq -r '.isLastPage' <<<"$response")" == "true" ]]; then
      break
    fi

    start="$(jq -r '.nextPageStart' <<<"$response")"
  done
}

remove_trigger_secret() {
  jq -Rr '
    def drop_qparam($k):
      if (contains("?") | not) then .
      else
        (split("?") | .[0]) as $base |
        (split("?") | .[1]) as $query |
        ($query | split("&")
          | map(select(length > 0))
          | map(select((split("=")[0]) != $k))) as $pairs |
        if ($pairs | length) == 0 then $base
        else ($base + "?" + ($pairs | join("&")))
        end
      end;
    drop_qparam("trigger_secret")
  '
}

detect_secret_config_key() {
  local hook_obj="$1"

  if [[ "$SECRET_CONFIG_KEY_EXPLICIT" == true ]]; then
    printf '%s\n' "$SECRET_CONFIG_KEY"
    return
  fi

  # Common case first.
  if jq -e '(.configuration // {}) | has("secret")' <<<"$hook_obj" >/dev/null; then
    printf 'secret\n'
    return
  fi

  # Otherwise, reuse an existing configuration key containing "secret".
  local detected
  detected="$(jq -r '
    (.configuration // {})
    | to_entries
    | map(select((.key | ascii_downcase | contains("secret")) and ((.value | type) == "string")))
    | sort_by(.key)
    | .[0].key // empty
  ' <<<"$hook_obj")"

  if [[ -n "$detected" ]]; then
    printf '%s\n' "$detected"
    return
  fi

  # Safe fallback.
  printf 'secret\n'
}

extract_proxy_project_key() {
  local webhook_url="$1"

  # Expected host pattern contains: webhook-proxy-{projectkey}-
  if [[ "$webhook_url" =~ webhook-proxy-([A-Za-z0-9]+)- ]]; then
    printf '%s\n' "${BASH_REMATCH[1]}"
    return
  fi

  printf '\n'
}

: > "$BACKUP_FILE"
log "Backup file: $BACKUP_FILE"

processed_repos=0
updated_hooks=0

while IFS= read -r repo_slug; do
  repo_slug=${repo_slug%$'\r'}
  [[ -z "$repo_slug" ]] && continue
  processed_repos=$((processed_repos + 1))
  log "Scanning repo: ${repo_slug}"

  hooks_json="$(curl_api GET "/rest/api/latest/projects/${PROJECT_KEY}/repos/${repo_slug}/webhooks")"

  # Some Bitbucket/plugin setups may return non-JSON bodies for specific repos.
  # Skip those repos with a clear log instead of aborting the whole migration.
  if ! jq -e . >/dev/null 2>&1 <<<"$hooks_json"; then
    preview="$(printf '%s' "$hooks_json" | tr '\n\r' '  ' | cut -c1-200)"
    log "Skipping repo ${repo_slug}: webhook API returned non-JSON payload"
    log "Payload preview: ${preview}"
    continue
  fi

  if ! jq -e 'has("values") and ((.values | type) == "array")' >/dev/null 2>&1 <<<"$hooks_json"; then
    log "Skipping repo ${repo_slug}: webhook API payload does not contain a values array"
    continue
  fi

  # Process only webhooks that target the webhook proxy host pattern.
  mapfile -t hook_objs < <(jq -c --arg m "$URL_MATCH" '.values[] | select((.url // "") | contains($m))' <<<"$hooks_json")

  if [[ ${#hook_objs[@]} -eq 0 ]]; then
    log "No matching webhooks in ${repo_slug}"
    continue
  fi

  for hook_obj in "${hook_objs[@]}"; do
    hook_id="$(jq -r '.id | tostring' <<<"$hook_obj")"
    old_url="$(jq -r '.url' <<<"$hook_obj")"
    proxy_project_key="$(extract_proxy_project_key "$old_url")"

    if [[ -n "$proxy_project_key" && "${proxy_project_key,,}" != "${PROJECT_KEY,,}" ]]; then
      log "Skipping webhook ${hook_id} in ${repo_slug}: proxy project '${proxy_project_key}' differs from current project '${PROJECT_KEY}'"
      jq -cn --arg repo "$repo_slug" --argjson hook "$hook_obj" '{repo:$repo,hook:$hook}' >> "$BACKUP_FILE"
      continue
    fi

    new_url="$(printf '%s' "$old_url" | remove_trigger_secret)"
    hook_secret_key="$(detect_secret_config_key "$hook_obj")"

    payload="$(jq -cn \
      --argjson src "$hook_obj" \
      --arg newUrl "$new_url" \
      --arg key "$hook_secret_key" \
      --arg secret "$WEBHOOK_SECRET" '
        {
          name: $src.name,
          url: $newUrl,
          active: $src.active,
          events: $src.events,
          sslVerificationRequired: $src.sslVerificationRequired,
          configuration: (($src.configuration // {}) + {($key): $secret}),
          credentials: $src.credentials
        }
        | with_entries(select(.value != null))
      ')"

    jq -cn --arg repo "$repo_slug" --argjson hook "$hook_obj" '{repo:$repo,hook:$hook}' >> "$BACKUP_FILE"

    if [[ "$old_url" != "$new_url" ]]; then
      log "Webhook ${hook_id} URL cleanup in ${repo_slug}: ${old_url} -> ${new_url}"
    else
      log "Webhook ${hook_id} in ${repo_slug}: trigger_secret not present in URL"
    fi

    if [[ "$SECRET_CONFIG_KEY_EXPLICIT" == true ]]; then
      log "Webhook ${hook_id} in ${repo_slug}: secret config key forced to '${hook_secret_key}'"
    else
      log "Webhook ${hook_id} in ${repo_slug}: auto-detected secret config key '${hook_secret_key}'"
    fi

    if [[ "$APPLY" == true ]]; then
      curl_api PUT "/rest/api/latest/projects/${PROJECT_KEY}/repos/${repo_slug}/webhooks/${hook_id}" "$payload" >/dev/null
      updated_hooks=$((updated_hooks + 1))
      log "Updated webhook ${hook_id} in ${repo_slug}"
    else
      log "DRY-RUN would update webhook ${hook_id} in ${repo_slug}"
    fi
  done
done < <(list_repos)

log "Processed repositories: ${processed_repos}"
log "Updated webhooks: ${updated_hooks}"
log "Done"
