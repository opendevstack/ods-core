#!/usr/bin/env bash
set -euo pipefail

# Generates a high-entropy secret suitable for WEBHOOK_HMAC_SECRET.
# Usage:
#   bash generate_hmac_secret.sh

if command -v openssl >/dev/null 2>&1; then
    secret=$(openssl rand -base64 32)
else
    echo "error: openssl is not available" >&2
    exit 1
fi

printf 'WEBHOOK_HMAC_SECRET=%s\n' "$secret"
