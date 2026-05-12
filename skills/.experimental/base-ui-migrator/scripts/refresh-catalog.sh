#!/usr/bin/env bash
# refresh-catalog.sh — Pull Base UI's llms.txt + each component .md doc
# Part of: base-ui-migrator
#
# Why: Base UI evolves. The skill ships a snapshot so it works offline, but
# this script keeps the catalog current. Run it when:
#   - assets/data/llms.txt is more than 7 days old
#   - Before a large migration on a project you don't know
#   - When a component lookup returns "not in catalog"
#
# Usage:
#   refresh-catalog.sh              # Refresh if stale (>7 days)
#   refresh-catalog.sh --force      # Always refresh
#   refresh-catalog.sh --check      # Print staleness, exit 0 if fresh, 2 if stale

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
DATA_DIR="$SKILL_DIR/assets/data"
COMPONENTS_DIR="$DATA_DIR/components"
LLMS_FILE="$DATA_DIR/llms.txt"
STALENESS_DAYS=7
BASE_URL="https://base-ui.com"

mkdir -p "$COMPONENTS_DIR"

force=0
check_only=0
for arg in "$@"; do
  case "$arg" in
    --force) force=1 ;;
    --check) check_only=1 ;;
    -h|--help)
      sed -n '2,20p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      echo "Usage: $0 [--force | --check]" >&2
      exit 1
      ;;
  esac
done

# --- Staleness check ---
is_stale() {
  [[ ! -f "$LLMS_FILE" ]] && return 0
  if [[ "$(uname)" == "Darwin" ]]; then
    local mtime
    mtime=$(stat -f %m "$LLMS_FILE")
    local now
    now=$(date +%s)
    local age_days=$(( (now - mtime) / 86400 ))
    (( age_days >= STALENESS_DAYS ))
  else
    find "$LLMS_FILE" -mtime +"$STALENESS_DAYS" -print | grep -q .
  fi
}

if (( check_only )); then
  if is_stale; then
    echo "STALE: $LLMS_FILE is older than $STALENESS_DAYS days (or missing). Run refresh-catalog.sh." >&2
    exit 2
  fi
  echo "FRESH: $LLMS_FILE is current."
  exit 0
fi

if (( ! force )) && ! is_stale; then
  echo "Catalog is fresh (<$STALENESS_DAYS days). Use --force to refresh anyway." >&2
  exit 2
fi

# --- Pull llms.txt ---
echo "Fetching $BASE_URL/llms.txt..." >&2
if ! curl -fsSL "$BASE_URL/llms.txt" -o "$LLMS_FILE.tmp"; then
  echo "ERROR: Failed to fetch llms.txt. Check network and try again." >&2
  rm -f "$LLMS_FILE.tmp"
  exit 1
fi
mv "$LLMS_FILE.tmp" "$LLMS_FILE"
echo "  Saved: $LLMS_FILE" >&2

# --- Extract component doc URLs from llms.txt ---
# Pattern: lines that contain /react/components/<name>.md
mapfile -t component_urls < <(
  grep -oE 'https://base-ui\.com/react/components/[a-z0-9-]+\.md' "$LLMS_FILE" | sort -u
)

if [[ ${#component_urls[@]} -eq 0 ]]; then
  echo "ERROR: No component URLs found in llms.txt. Format may have changed." >&2
  echo "  Inspect: $LLMS_FILE" >&2
  exit 1
fi

echo "Found ${#component_urls[@]} component docs. Fetching..." >&2

# --- Fetch each component doc in parallel-ish (5 concurrent) ---
fetched=0
failed=0
fetch_one() {
  local url="$1"
  local name
  name=$(basename "$url" .md)
  local out="$COMPONENTS_DIR/$name.md"
  if curl -fsSL "$url" -o "$out.tmp"; then
    mv "$out.tmp" "$out"
    return 0
  else
    rm -f "$out.tmp"
    return 1
  fi
}

# Sequential fetch (simpler, more reliable than xargs -P with error handling)
for url in "${component_urls[@]}"; do
  name=$(basename "$url" .md)
  if fetch_one "$url"; then
    printf "  [%2d/%2d] %s\n" $((fetched + failed + 1)) ${#component_urls[@]} "$name" >&2
    fetched=$((fetched + 1))
  else
    printf "  [%2d/%2d] FAIL: %s\n" $((fetched + failed + 1)) ${#component_urls[@]} "$name" >&2
    failed=$((failed + 1))
  fi
done

echo "" >&2
echo "Catalog refresh complete:" >&2
echo "  Fetched: $fetched" >&2
echo "  Failed:  $failed" >&2
echo "  Stored:  $COMPONENTS_DIR/" >&2

if (( failed > 0 )); then
  exit 1
fi
exit 0
