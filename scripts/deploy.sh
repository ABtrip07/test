#!/usr/bin/env bash
#
# Build the heybud web bundle and produce an archive ready to deploy to
# Hostinger via the hostinger-mcp `hosting_deployStaticWebsite` tool or
# manual SFTP upload.
#
# Usage:
#   bash scripts/deploy.sh
#
# Requires:
#   - .env at repo root with EXPO_PUBLIC_MAPBOX_ACCESS_TOKEN
#   - node + npm available on PATH
#   - zip (macOS/Linux default)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

DOMAIN="heybudhq.com"
ENV_FILE="$REPO_ROOT/.env"
DIST_DIR="$REPO_ROOT/dist"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
ARCHIVE_NAME="heybud_${TIMESTAMP}.zip"
ARCHIVE_PATH="$REPO_ROOT/$ARCHIVE_NAME"

# ---- preflight ----------------------------------------------------------

if [[ ! -f "$ENV_FILE" ]]; then
  echo "error: .env not found at $ENV_FILE"
  echo "  create it with: echo 'EXPO_PUBLIC_MAPBOX_ACCESS_TOKEN=pk.YOURTOKEN' > .env"
  exit 1
fi

if ! grep -q '^EXPO_PUBLIC_MAPBOX_ACCESS_TOKEN=pk\.' "$ENV_FILE"; then
  echo "error: EXPO_PUBLIC_MAPBOX_ACCESS_TOKEN not set (or not a public pk.* token) in .env"
  exit 1
fi

for cmd in node npm npx zip; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "error: required command not found: $cmd"
    exit 1
  fi
done

# ---- install (only if missing) ------------------------------------------

if [[ ! -d "$REPO_ROOT/node_modules" ]]; then
  echo "[deploy] installing dependencies (first run)..."
  npm install
fi

# ---- build --------------------------------------------------------------

echo "[deploy] building web bundle..."
rm -rf "$DIST_DIR"
npx expo export -p web

if [[ ! -d "$DIST_DIR" ]]; then
  echo "error: expo export did not produce a dist/ directory"
  exit 1
fi

# ---- archive ------------------------------------------------------------

echo "[deploy] archiving dist/ -> $ARCHIVE_NAME ..."
rm -f "$ARCHIVE_PATH"
( cd "$DIST_DIR" && zip -qr "$ARCHIVE_PATH" . )

ARCHIVE_SIZE_KB="$(( $(wc -c < "$ARCHIVE_PATH") / 1024 ))"
echo "[deploy] archive ready: $ARCHIVE_PATH (${ARCHIVE_SIZE_KB} KB)"

# ---- next steps ---------------------------------------------------------

cat <<EOF

next steps:

  option A — deploy from local Claude Code (Hostinger MCP must be reachable):

    claude

    # then ask Claude:
    "deploy $ARCHIVE_NAME to $DOMAIN"
    # which invokes mcp__hostinger-mcp__hosting_deployStaticWebsite
    # with archivePath=$ARCHIVE_PATH and domain=$DOMAIN

  option B — manual SFTP / File Manager:

    1. log in to Hostinger hPanel
    2. open File Manager for $DOMAIN -> public_html
    3. delete existing files in public_html (or back them up first)
    4. upload + extract $ARCHIVE_NAME

  cleanup after a successful deploy:

    rm -f "$ARCHIVE_PATH"
    rm -rf "$DIST_DIR"

EOF
