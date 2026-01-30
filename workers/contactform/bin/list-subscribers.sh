#!/usr/bin/env bash
# ABOUTME: Lists all newsletter subscribers from the Cloudflare KV store.
# ABOUTME: Outputs tab-separated: email, name, subscribed date.

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

usage() {
  cat <<EOF
Usage: $(basename "$0") [-h]

Lists all newsletter subscribers stored in Cloudflare KV.
Must be run from the contactform Worker directory, or the script
resolves the path automatically.

Output: tab-separated lines of email, name, subscribed date.

Requires: npx (Node.js), wrangler, jq
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

for cmd in npx jq; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    printf 'Error: %s is required but not found\n' "$cmd" >&2
    exit 1
  fi
done

keys_json=$(npx --prefix "$SCRIPT_DIR" wrangler kv key list --binding SUBSCRIBERS --remote 2>/dev/null)

count=$(printf '%s' "$keys_json" | jq -r 'length')
if [[ "$count" -eq 0 ]]; then
  printf 'No subscribers found.\n'
  exit 0
fi

printf '%s subscribers:\n\n' "$count"
printf 'Email\tName\tSubscribed\n'
printf -- '-----\t----\t----------\n'

printf '%s' "$keys_json" | jq -r '.[].name' | while IFS= read -r email; do
  value=$(npx --prefix "$SCRIPT_DIR" wrangler kv key get --binding SUBSCRIBERS --remote "$email" 2>/dev/null)
  name=$(printf '%s' "$value" | jq -r '.name // ""')
  subscribed=$(printf '%s' "$value" | jq -r '.subscribed // ""')
  printf '%s\t%s\t%s\n' "$email" "$name" "$subscribed"
done
