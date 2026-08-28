#!/usr/bin/env bash
set -euo pipefail

# Generates a high-entropy secret suitable for WEBHOOK_HMAC_SECRET.
# Usage:
#   bash generate_hmac_secret.sh
#   bash generate_hmac_secret.sh 64

length="${1:-64}"

if ! [[ "$length" =~ ^[0-9]+$ ]]; then
    echo "error: length must be a positive integer" >&2
    exit 1
fi

if (( length < 32 )); then
    echo "error: length must be at least 32 characters" >&2
    exit 1
fi

if command -v openssl >/dev/null 2>&1; then
    secret=$(openssl rand -hex $(((length + 1) / 2)) | cut -c1-"$length")
elif [[ -r /dev/urandom ]]; then
    secret=$(tr -dc 'a-f0-9' </dev/urandom | head -c "$length")
else
    echo "error: neither openssl nor /dev/urandom is available" >&2
    exit 1
fi

printf 'WEBHOOK_HMAC_SECRET=%s\n' "$secret"