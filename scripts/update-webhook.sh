#!/usr/bin/env bash
set -euo pipefail

REPO="adnanh/webhook"
CACHE_DIR=".cache"
CACHE_FILE="$CACHE_DIR/latest-release.json"
CACHE_TTL=3600
VERSION_FILE="version.txt"
BIN_DIR="bin"
BINARY="$BIN_DIR/webhook"
PREVIOUS="$BIN_DIR/webhook.previous"
OS="linux"
ARCH="amd64"

log()  { echo "[$(date -Iseconds)] $*"; }
err()  { log "ERROR: $*" >&2; }
cleanup() { rm -f /tmp/webhook-*.tar.gz /tmp/webhook-*.sha256; }
trap cleanup EXIT

# Read current version
current_version=""
if [ -f "$VERSION_FILE" ]; then
  current_version=$(cat "$VERSION_FILE")
fi

# Fetch latest release (check cache first)
latest_version=""
now=$(date +%s)

if [ -f "$CACHE_FILE" ]; then
  cached_at=$(jq -r '.cached_at // 0' "$CACHE_FILE")
  age=$((now - cached_at))
  if [ "$age" -lt "$CACHE_TTL" ]; then
    latest_version=$(jq -r '.tag_name // empty' "$CACHE_FILE")
    log "Using cached release info (${age}s old)"
  fi
fi

if [ -z "$latest_version" ]; then
  log "Fetching latest release from GitHub API..."
  response=$(curl -sf "https://api.github.com/repos/$REPO/releases/latest") || {
    # If cache exists and is non-empty, use it as fallback
    if [ -f "$CACHE_FILE" ] && [ -s "$CACHE_FILE" ]; then
      latest_version=$(jq -r '.tag_name // empty' "$CACHE_FILE")
      if [ -n "$latest_version" ]; then
        log "GitHub API unreachable; using cached release (version $latest_version)"
      else
        err "GitHub API unreachable and no valid cache available"
        exit 1
      fi
    else
      err "GitHub API unreachable and no cache available"
      exit 1
    fi
  }

  if [ -n "${response:-}" ]; then
    latest_version=$(echo "$response" | jq -r '.tag_name')
    echo "{\"tag_name\": \"$latest_version\", \"cached_at\": $now}" > "$CACHE_FILE"
  fi
fi

# Strip leading 'v' from version if present
latest_version="${latest_version#v}"

# Idempotency check
if [ "$current_version" = "$latest_version" ]; then
  log "Already up to date (v$latest_version)"
  exit 0
fi

log "Updating: v${current_version:-none} → v$latest_version"

# Download and verify
tarball_name="webhook-${OS}-${ARCH}.tar.gz"
checksum_name="${tarball_name}.sha256"
download_url="https://github.com/$REPO/releases/download/v${latest_version}/$tarball_name"
checksum_url="https://github.com/$REPO/releases/download/v${latest_version}/$checksum_name"

log "Downloading $tarball_name..."
curl -sL -o "/tmp/$tarball_name" "$download_url"

log "Downloading checksum..."
curl -sL -o "/tmp/$checksum_name" "$checksum_url"

log "Verifying SHA256 checksum..."
expected=$(cat "/tmp/$checksum_name" | awk '{print $1}')
actual=$(sha256sum "/tmp/$tarball_name" | awk '{print $1}')
if [ "$expected" != "$actual" ]; then
  err "Checksum mismatch! Expected: $expected, Got: $actual"
  rm -f "/tmp/$tarball_name" "/tmp/$checksum_name"
  exit 2
fi
log "Checksum verified OK"

# Backup existing binary
if [ -f "$BINARY" ]; then
  log "Backing up current binary → $PREVIOUS"
  cp "$BINARY" "$PREVIOUS"
fi

# Install new binary
mkdir -p "$BIN_DIR"
log "Extracting $tarball_name..."
tar -xzf "/tmp/$tarball_name" -C "/tmp/"
# The tarball contains the binary at root; find it
extracted_binary=$(find /tmp -maxdepth 2 -name "webhook" -type f 2>/dev/null | head -1)
if [ -n "$extracted_binary" ]; then
  mv "$extracted_binary" "$BINARY"
else
  err "Could not find webhook binary in extracted tarball"
  exit 3
fi
chmod +x "$BINARY"

# Update version file
echo "$latest_version" > "$VERSION_FILE"

log "Successfully updated to v$latest_version"
