#!/usr/bin/env bash
# export-assets.sh — Export Sketch slices as PNG/JPG/SVG, convert SVGs to React components.
# Part of: sketch-to-react
#
# Usage: export-assets.sh <path-to-sketch-file> [--dry-run]
#
# Outputs:
#   <assets_dir>/*.{png,jpg}             — raster assets
#   <icons_dir>/<Name>.tsx               — SVG-as-React (via @svgr/cli)
#   work/assets-manifest.json            — map of assetId -> output path
#
# Exit codes: 0 = success, 1 = error, 2 = no exportable slices found
set -euo pipefail

SKILL_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK_DIR="$SKILL_ROOT/work"
CONFIG_FILE="$SKILL_ROOT/config.json"
DRY_RUN=0
SKETCH_FILE=""

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    -*) echo "Unknown flag: $arg" >&2; exit 1 ;;
    *) SKETCH_FILE="$arg" ;;
  esac
done

if [[ -z "$SKETCH_FILE" ]]; then
  echo "Usage: $0 <path-to-sketch-file> [--dry-run]" >&2
  exit 1
fi

if [[ ! -f "$SKETCH_FILE" ]]; then
  echo "ERROR: Sketch file not found: $SKETCH_FILE" >&2
  exit 1
fi

read_config() { node -e "process.stdout.write(require('$CONFIG_FILE')['$1']||'')"; }
SKETCHTOOL=$(read_config sketchtool_path)
OUTPUT_ROOT=$(read_config output_root)
ICONS_DIR=$(read_config icons_dir)
ASSETS_DIR=$(read_config assets_dir)

RASTER_OUT="$OUTPUT_ROOT/$ASSETS_DIR"
SVG_STAGING="$WORK_DIR/svgs"
ICONS_OUT="$OUTPUT_ROOT/$ICONS_DIR"

if [[ $DRY_RUN -eq 1 ]]; then
  echo "Dry run — would export to:"
  echo "  Raster: $RASTER_OUT/"
  echo "  SVGs (staging): $SVG_STAGING/"
  echo "  Icons (TSX):    $ICONS_OUT/"
  exit 0
fi

mkdir -p "$RASTER_OUT" "$SVG_STAGING" "$ICONS_OUT"

# --- Export raster ---
echo "Exporting raster slices (PNG)..."
"$SKETCHTOOL" export slices "$SKETCH_FILE" \
  --formats=png --scales=1,2 --output="$RASTER_OUT" \
  --overwriting=YES 2>/dev/null || true

# --- Export SVG slices ---
echo "Exporting vector slices (SVG)..."
"$SKETCHTOOL" export slices "$SKETCH_FILE" \
  --formats=svg --output="$SVG_STAGING" \
  --overwriting=YES 2>/dev/null || true

SVG_COUNT=$(find "$SVG_STAGING" -name '*.svg' -type f 2>/dev/null | wc -l | tr -d ' ')
RASTER_COUNT=$(find "$RASTER_OUT" -type f \( -name '*.png' -o -name '*.jpg' \) 2>/dev/null | wc -l | tr -d ' ')

if [[ "$SVG_COUNT" -eq 0 ]] && [[ "$RASTER_COUNT" -eq 0 ]]; then
  echo "WARNING: No slices found in Sketch file." >&2
  echo "Hint: in Sketch, mark layers as 'Exportable' (right panel) for them to appear here." >&2
  # Still write an empty manifest so downstream is well-defined
  echo "{}" > "$WORK_DIR/assets-manifest.json"
  exit 2
fi

# --- Convert SVGs to React components via SVGR ---
if [[ "$SVG_COUNT" -gt 0 ]]; then
  echo "Converting $SVG_COUNT SVG(s) to React components via @svgr/cli..."
  npx --yes @svgr/cli@latest \
    --typescript \
    --no-dimensions \
    --out-dir "$ICONS_OUT" \
    "$SVG_STAGING" 1>/dev/null
fi

# --- Build manifest ---
node -e "
const fs = require('fs');
const path = require('path');
const rasterDir = '$RASTER_OUT';
const iconsDir = '$ICONS_OUT';

function walk(dir, ext) {
  if (!fs.existsSync(dir)) return [];
  const out = [];
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) out.push(...walk(p, ext));
    else if (ext.some(x => p.endsWith(x))) out.push(p);
  }
  return out;
}

const manifest = {
  raster: walk(rasterDir, ['.png','.jpg','.jpeg']).map(p => path.relative('$OUTPUT_ROOT', p)),
  icons:  walk(iconsDir, ['.tsx']).map(p => path.relative('$OUTPUT_ROOT', p)),
};
fs.writeFileSync('$WORK_DIR/assets-manifest.json', JSON.stringify(manifest, null, 2));
console.log('Manifest:', JSON.stringify({raster: manifest.raster.length, icons: manifest.icons.length}));
"

echo ""
echo "Assets exported:"
echo "  Raster:  $RASTER_COUNT file(s) in $RASTER_OUT"
echo "  Icons:   $SVG_COUNT SVG(s) → $ICONS_OUT"
echo ""
echo "Next: node scripts/generate-components.js"
