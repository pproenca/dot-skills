#!/usr/bin/env bash
# parse.sh — Extract document JSON from a .sketch file (which is a ZIP archive).
# Part of: sketch-to-react
#
# Usage: parse.sh <path-to-sketch-file>
#
# A .sketch file contains:
#   document.json         — document-level data (color assets, text styles, page refs)
#   pages/<UUID>.json     — one file per page, with artboards + layers
#   meta.json, user.json  — metadata
#   images/, fonts/       — embedded assets
#
# We parse the JSON directly rather than calling `sketchtool dump`, because
# `dump` was removed in sketchtool 2026. The on-disk format is documented at
# https://github.com/sketch-hq/sketch-file-format and is stable across versions.
#
# Outputs:
#   work/document.json   — unified tree: document fields + all pages inlined
#   work/structure.json  — page + artboard listing for navigation
#
# Exit codes: 0 = success, 1 = error, 2 = cache hit (skipped)
set -euo pipefail

SKILL_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK_DIR="$SKILL_ROOT/work"
CONFIG_FILE="$SKILL_ROOT/config.json"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <path-to-sketch-file>" >&2
  exit 1
fi

SKETCH_FILE="$1"

if [[ ! -f "$SKETCH_FILE" ]]; then
  echo "ERROR: Sketch file not found: $SKETCH_FILE" >&2
  exit 1
fi

if [[ ! -f "$WORK_DIR/.preflight-stamp" ]]; then
  echo "ERROR: preflight.sh has not been run. Run it first." >&2
  exit 1
fi

if ! command -v unzip >/dev/null 2>&1; then
  echo "ERROR: unzip not found in PATH. Install it (it ships with macOS by default)." >&2
  exit 1
fi

# --- Idempotency: skip if input file hash matches cache ---
SKETCH_HASH=$(shasum -a 256 "$SKETCH_FILE" | awk '{print $1}')
CACHE_FILE="$WORK_DIR/.parse-hash"
if [[ -f "$CACHE_FILE" ]] && [[ "$(cat "$CACHE_FILE")" == "$SKETCH_HASH" ]] \
    && [[ -f "$WORK_DIR/document.json" ]] && [[ -f "$WORK_DIR/structure.json" ]]; then
  echo "Parse cache hit (same .sketch hash) — skipping."
  exit 2
fi

# --- Extract JSON entries from the ZIP ---
RAW_DIR="$WORK_DIR/raw"
rm -rf "$RAW_DIR"
mkdir -p "$RAW_DIR"

echo "Extracting document.json and pages/*.json from .sketch archive..."
# -j flattens directory structure for top-level files; we want pages/ preserved.
# Quiet (-q), overwrite (-o), and limit to JSON to skip 100+MB of fonts/images.
unzip -q -o "$SKETCH_FILE" "document.json" "pages/*.json" "meta.json" -d "$RAW_DIR" 2>&1 || {
  echo "ERROR: failed to extract from .sketch file." >&2
  echo "The file may be corrupt. Try opening it in Sketch and re-saving." >&2
  exit 1
}

if [[ ! -f "$RAW_DIR/document.json" ]]; then
  echo "ERROR: document.json not found inside the .sketch archive." >&2
  echo "This is unusual — the file may be an unsupported Sketch version." >&2
  exit 1
fi

PAGE_COUNT=$(find "$RAW_DIR/pages" -name '*.json' 2>/dev/null | wc -l | tr -d ' ')
if [[ "$PAGE_COUNT" -eq 0 ]]; then
  echo "ERROR: no pages found inside the .sketch archive." >&2
  exit 1
fi

# --- Build unified document.json + structure.json ---
# Paths are passed via env vars so a workspace path with quotes can't break the
# node -e string. JSON is read from disk, not splatted inline.
RAW_DIR="$RAW_DIR" WORK_DIR="$WORK_DIR" node -e '
const fs = require("fs"), path = require("path");
const rawDir = process.env.RAW_DIR;
const workDir = process.env.WORK_DIR;

const doc = JSON.parse(fs.readFileSync(path.join(rawDir, "document.json"), "utf8"));
const pagesDir = path.join(rawDir, "pages");
const pageFiles = fs.readdirSync(pagesDir).filter(f => f.endsWith(".json")).sort();

const pages = pageFiles.map(f => JSON.parse(fs.readFileSync(path.join(pagesDir, f), "utf8")));

// Unified tree: the rest of the pipeline walks this looking for artboards.
const unified = { ...doc, pages };
fs.writeFileSync(path.join(workDir, "document.json"), JSON.stringify(unified, null, 2));

// Lightweight structure summary for verify.sh.
const structure = {
  pageCount: pages.length,
  pages: pages.map(p => ({
    name: p.name,
    objectID: p.do_objectID,
    artboards: (p.layers || [])
      .filter(l => l._class === "artboard" || l._class === "symbolMaster")
      .map(a => ({ name: a.name, objectID: a.do_objectID, _class: a._class })),
  })),
};
fs.writeFileSync(path.join(workDir, "structure.json"), JSON.stringify(structure, null, 2));

const totalArtboards = structure.pages.reduce((n, p) => n + p.artboards.length, 0);
console.log(`  Pages:     ${pages.length}`);
console.log(`  Artboards: ${totalArtboards}`);
'

echo "$SKETCH_HASH" > "$CACHE_FILE"

DOC_SIZE=$(wc -c < "$WORK_DIR/document.json" | tr -d ' ')

echo ""
echo "Parsed:"
echo "  Unified document JSON: $WORK_DIR/document.json ($DOC_SIZE bytes)"
echo "  Structure summary:     $WORK_DIR/structure.json"
echo ""
echo "Next: node scripts/extract-tokens.js"
