#!/usr/bin/env bash
# preflight.sh — Validate environment and detect overwrites before running pipeline.
# Part of: sketch-to-react
#
# Usage: preflight.sh <path-to-sketch-file> [--dry-run] [--force]
#
# Exit codes:
#   0 = ready to proceed
#   1 = environment problem (missing tool, bad path)
#   2 = overwrite would occur and --force not passed
set -euo pipefail

SKILL_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG_FILE="$SKILL_ROOT/config.json"
DRY_RUN=0
FORCE=0
SKETCH_FILE=""

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --force) FORCE=1 ;;
    -*) echo "Unknown flag: $arg" >&2; exit 1 ;;
    *) SKETCH_FILE="$arg" ;;
  esac
done

if [[ -z "$SKETCH_FILE" ]]; then
  echo "Usage: $0 <path-to-sketch-file> [--dry-run] [--force]" >&2
  echo "Hint: pass the .sketch file you want to convert." >&2
  exit 1
fi

if [[ ! -f "$SKETCH_FILE" ]]; then
  echo "ERROR: Sketch file not found: $SKETCH_FILE" >&2
  echo "Check the path and try again. The file must be a local .sketch file." >&2
  exit 1
fi

if [[ "${SKETCH_FILE##*.}" != "sketch" ]]; then
  echo "ERROR: Expected a .sketch file, got: $SKETCH_FILE" >&2
  echo "Only Sketch binary files are supported. For Figma, use a different skill." >&2
  exit 1
fi

# --- Validate config ---
if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "ERROR: Missing config.json at $CONFIG_FILE" >&2
  echo "The skill needs config.json. Run setup or copy the template and fill it in." >&2
  exit 1
fi

read_config() {
  local key="$1"
  node -e "const c=require('$CONFIG_FILE'); process.stdout.write(c['$key'] || '')"
}

OUTPUT_ROOT="$(read_config output_root)"
COMPONENTS_DIR="$(read_config components_dir)"
ICONS_DIR="$(read_config icons_dir)"
ASSETS_DIR="$(read_config assets_dir)"
TOKENS_PATH="$(read_config tokens_path)"
SKETCHTOOL_PATH="$(read_config sketchtool_path)"

for v in OUTPUT_ROOT COMPONENTS_DIR ICONS_DIR ASSETS_DIR TOKENS_PATH SKETCHTOOL_PATH; do
  if [[ -z "${!v}" ]]; then
    echo "ERROR: config.json is missing required field: $(echo "$v" | tr 'A-Z_' 'a-z_')" >&2
    echo "Edit $CONFIG_FILE and rerun. See _setup_instructions in that file for guidance." >&2
    exit 1
  fi
done

# --- Validate sketchtool ---
if [[ ! -x "$SKETCHTOOL_PATH" ]]; then
  echo "ERROR: sketchtool not found or not executable at: $SKETCHTOOL_PATH" >&2
  if [[ -d "/Applications/Sketch.app" ]]; then
    echo "" >&2
    echo "Sketch.app is installed but sketchtool is not present." >&2
    # The Mac App Store build is sandboxed and does NOT bundle sketchtool.
    # Detect via _MASReceipt (deterministic; faster and more reliable than parsing --version output).
    if [[ -d "/Applications/Sketch.app/Contents/_MASReceipt" ]]; then
      echo "You have the Mac App Store build of Sketch, which is sandboxed and does NOT" >&2
      echo "include sketchtool. To use this skill:" >&2
      echo "  1. Quit the App Store version of Sketch." >&2
      echo "  2. Download Sketch from https://www.sketch.com/downloads/mac/" >&2
      echo "  3. Replace /Applications/Sketch.app with the downloaded build, then retry." >&2
    else
      echo "Your Sketch build appears not to include sketchtool. Reinstall from" >&2
      echo "https://www.sketch.com/downloads/mac/, or set sketchtool_path in config.json" >&2
      echo "to the binary's actual location if installed separately." >&2
    fi
  else
    echo "Install Sketch.app from https://www.sketch.com/downloads/mac/ (macOS only)." >&2
    echo "Then update sketchtool_path in config.json." >&2
  fi
  exit 1
fi

# --- Validate node ---
if ! command -v node >/dev/null 2>&1; then
  echo "ERROR: node not found in PATH." >&2
  echo "Install Node.js >= 18: brew install node" >&2
  exit 1
fi

NODE_MAJOR=$(node -p "process.versions.node.split('.')[0]")
if [[ "$NODE_MAJOR" -lt 18 ]]; then
  echo "ERROR: Node.js >= 18 required, found $(node -v)" >&2
  exit 1
fi

# --- Detect overwrites ---
CONFLICTS=()
check_conflict() {
  local p="$1"
  if [[ -e "$p" ]]; then CONFLICTS+=("$p"); fi
}

check_conflict "$OUTPUT_ROOT/$TOKENS_PATH"
# Components/icons dirs themselves existing is fine — only files inside that the pipeline would write
if [[ -d "$OUTPUT_ROOT/$COMPONENTS_DIR" ]] && [[ -n "$(ls -A "$OUTPUT_ROOT/$COMPONENTS_DIR" 2>/dev/null || true)" ]]; then
  CONFLICTS+=("$OUTPUT_ROOT/$COMPONENTS_DIR (non-empty)")
fi
if [[ -d "$OUTPUT_ROOT/$ICONS_DIR" ]] && [[ -n "$(ls -A "$OUTPUT_ROOT/$ICONS_DIR" 2>/dev/null || true)" ]]; then
  CONFLICTS+=("$OUTPUT_ROOT/$ICONS_DIR (non-empty)")
fi

# --- Report ---
echo "Preflight summary"
echo "  Sketch file:     $SKETCH_FILE"
echo "  Sketchtool:      $SKETCHTOOL_PATH"
echo "  Node:            $(node -v)"
echo "  Output root:     $OUTPUT_ROOT"
echo "  Components dir:  $OUTPUT_ROOT/$COMPONENTS_DIR"
echo "  Icons dir:       $OUTPUT_ROOT/$ICONS_DIR"
echo "  Assets dir:      $OUTPUT_ROOT/$ASSETS_DIR"
echo "  Tokens file:     $OUTPUT_ROOT/$TOKENS_PATH"

if [[ ${#CONFLICTS[@]} -gt 0 ]]; then
  echo ""
  echo "Overwrite would occur at:"
  for c in "${CONFLICTS[@]}"; do echo "  - $c"; done
  if [[ $FORCE -eq 0 ]]; then
    echo ""
    echo "Rerun with --force to overwrite, or move/remove the existing files." >&2
    exit 2
  fi
  echo "(--force passed — will overwrite)"
fi

if [[ $DRY_RUN -eq 1 ]]; then
  echo ""
  echo "Dry run only. No files written. Rerun without --dry-run to proceed."
  exit 0
fi

# --- Stamp work dir ---
WORK_DIR="$SKILL_ROOT/work"
mkdir -p "$WORK_DIR"
echo "$SKETCH_FILE" > "$WORK_DIR/.sketch-path"
date -u +"%Y-%m-%dT%H:%M:%SZ" > "$WORK_DIR/.preflight-stamp"

echo ""
echo "Preflight OK. Ready to run parse.sh."
