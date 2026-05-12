#!/usr/bin/env bash
# fetch-component-doc.sh — Fetch a single Base UI component doc on demand
# Part of: base-ui-migrator
#
# Why: refresh-catalog.sh pulls all components in one go. Use this when you
# only need one (e.g., scan found a Slider but the local cache is missing it).
# Caches the result so subsequent reads are free.
#
# Usage:
#   fetch-component-doc.sh <component-name>      # e.g., "dialog", "popover"
#   fetch-component-doc.sh <name> --force        # re-fetch even if cached
#   fetch-component-doc.sh <name> --print        # write to cache AND stdout
#
# Component name is kebab-case as it appears in base-ui.com URLs.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <component-name> [--force] [--print]" >&2
  echo "  Component names from references/catalog.md (kebab-case)" >&2
  exit 1
fi

name="$1"
shift || true
force=0
print=0
for arg in "$@"; do
  case "$arg" in
    --force) force=1 ;;
    --print) print=1 ;;
    *)
      echo "Unknown argument: $arg" >&2
      exit 1
      ;;
  esac
done

# Validate name shape
if ! [[ "$name" =~ ^[a-z][a-z0-9-]*$ ]]; then
  echo "ERROR: Component name must be kebab-case (e.g., 'dialog', 'alert-dialog'): $name" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
COMPONENTS_DIR="$SKILL_DIR/assets/data/components"
mkdir -p "$COMPONENTS_DIR"

cache_file="$COMPONENTS_DIR/$name.md"

if [[ -f "$cache_file" ]] && (( ! force )); then
  echo "Cached: $cache_file" >&2
  if (( print )); then
    cat "$cache_file"
  fi
  exit 0
fi

url="https://base-ui.com/react/components/$name.md"
echo "Fetching $url..." >&2

if ! curl -fsSL "$url" -o "$cache_file.tmp"; then
  rm -f "$cache_file.tmp"
  echo "ERROR: Could not fetch $url" >&2
  echo "  Possible causes:" >&2
  echo "    - Wrong component name. Check references/catalog.md for valid names." >&2
  echo "    - Network unavailable." >&2
  echo "    - Base UI moved the doc. Run refresh-catalog.sh --force to discover the new URL." >&2
  exit 1
fi

mv "$cache_file.tmp" "$cache_file"
echo "Saved: $cache_file" >&2

if (( print )); then
  cat "$cache_file"
fi
exit 0
