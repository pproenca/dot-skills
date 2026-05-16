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
# Embedded images go to public/ at the project root so that the generator's
# absolute src="/images/<hash>.ext" paths resolve in Vite/Next/CRA. The
# generator writes paths derived from `image._ref` in the Sketch JSON, which
# always start with "images/" — so we mirror that prefix verbatim.
PROJECT_ROOT="$(cd "$OUTPUT_ROOT/.." 2>/dev/null && pwd || echo "$OUTPUT_ROOT/..")"
EMBEDDED_OUT="$PROJECT_ROOT/public"

if [[ $DRY_RUN -eq 1 ]]; then
  echo "Dry run — would export to:"
  echo "  Embedded images (from .sketch zip): $EMBEDDED_OUT/images/"
  echo "  Sketchtool raster slices:           $RASTER_OUT/"
  echo "  SVGs (staging):                     $SVG_STAGING/"
  echo "  Icons (TSX):                        $ICONS_OUT/"
  exit 0
fi

mkdir -p "$RASTER_OUT" "$SVG_STAGING" "$ICONS_OUT" "$EMBEDDED_OUT"

# --- Step 4a: Extract embedded images from the .sketch ZIP ---
# Sketch stores every bitmap referenced by a layer in `images/<hash>.<ext>`
# inside the .sketch archive. The generator emits `<img src="/<ref>" />` where
# <ref> is `images/<hash>.<ext>`, so we extract them as-is. This catches every
# bitmap actually used in components, regardless of "Exportable" flags.
if command -v unzip >/dev/null 2>&1; then
  echo "Extracting embedded images from .sketch archive..."
  unzip -q -o "$SKETCH_FILE" "images/*" -d "$EMBEDDED_OUT" 2>/dev/null || true
  EMBEDDED_COUNT=$(find "$EMBEDDED_OUT/images" -type f 2>/dev/null | wc -l | tr -d ' ')
  echo "  Extracted $EMBEDDED_COUNT embedded image(s) to $EMBEDDED_OUT/images/"
else
  echo "WARNING: unzip not found — skipping embedded-image extraction." >&2
  EMBEDDED_COUNT=0
fi

# --- Step 4b: Sketchtool slice export (only catches layers marked Exportable) ---
if [[ -x "$SKETCHTOOL" ]]; then
  echo "Exporting raster slices via sketchtool..."
  "$SKETCHTOOL" export slices "$SKETCH_FILE" \
    --formats=png --scales=1,2 --output="$RASTER_OUT" \
    --overwriting=YES 2>/dev/null || true

  echo "Exporting vector slices via sketchtool..."
  "$SKETCHTOOL" export slices "$SKETCH_FILE" \
    --formats=svg --output="$SVG_STAGING" \
    --overwriting=YES 2>/dev/null || true
else
  echo "Skipping sketchtool exports (binary not present at $SKETCHTOOL)."
fi

SVG_COUNT=$(find "$SVG_STAGING" -name '*.svg' -type f 2>/dev/null | wc -l | tr -d ' ')
RASTER_COUNT=$(find "$RASTER_OUT" -type f \( -name '*.png' -o -name '*.jpg' \) 2>/dev/null | wc -l | tr -d ' ')

# A run with zero sketchtool slices is still a success if embedded images were
# extracted — those cover every bitmap actually referenced by components.
if [[ "$SVG_COUNT" -eq 0 ]] && [[ "$RASTER_COUNT" -eq 0 ]] && [[ "$EMBEDDED_COUNT" -eq 0 ]]; then
  echo "WARNING: No images, slices, or SVGs were produced." >&2
  echo "Hint: in Sketch, mark layers as 'Exportable' (right panel) for sketchtool slices," >&2
  echo "or ensure the .sketch file has embedded bitmap layers." >&2
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
RASTER_OUT="$RASTER_OUT" ICONS_OUT="$ICONS_OUT" EMBEDDED_OUT="$EMBEDDED_OUT" \
  OUTPUT_ROOT="$OUTPUT_ROOT" PROJECT_ROOT="$PROJECT_ROOT" WORK_DIR="$WORK_DIR" \
  node -e "
const fs = require('fs');
const path = require('path');

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
  embedded: walk(process.env.EMBEDDED_OUT, ['.png','.jpg','.jpeg','.pdf']).map(p =>
    path.relative(process.env.PROJECT_ROOT, p)),
  raster: walk(process.env.RASTER_OUT, ['.png','.jpg','.jpeg']).map(p =>
    path.relative(process.env.OUTPUT_ROOT, p)),
  icons:  walk(process.env.ICONS_OUT, ['.tsx']).map(p =>
    path.relative(process.env.OUTPUT_ROOT, p)),
};
fs.writeFileSync(path.join(process.env.WORK_DIR, 'assets-manifest.json'),
  JSON.stringify(manifest, null, 2));
console.log('Manifest counts:',
  JSON.stringify({embedded: manifest.embedded.length, raster: manifest.raster.length, icons: manifest.icons.length}));
"

echo ""
echo "Assets exported:"
echo "  Embedded:  $EMBEDDED_COUNT file(s) in $EMBEDDED_OUT/images/"
echo "  Slices:    $RASTER_COUNT raster file(s) in $RASTER_OUT"
echo "  Icons:     $SVG_COUNT SVG(s) → $ICONS_OUT"
echo ""
echo "Next: node scripts/generate-components.js"
