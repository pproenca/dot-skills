#!/usr/bin/env bash
# 01-scaffold.sh — scaffold a codemod project from the pipeline templates.
# Part of: codemod-react-pipeline  (inner loop, step 1)
#
# Creates  codemods/<name>/  in the target repo with:
#   - transform.ts (JSSG)  OR  rule.yml (declarative ast-grep, with --rule)
#   - tests/basic/{input,expected}.<ext>   fixture pair (TDD for the transform)
#   - workflow.yaml         outer-loop orchestration (matrix sharding + checkpoints)
#   - codemod.yaml          package metadata
#
# Usage:   bash 01-scaffold.sh <name> [--rule] [--force]
# Exit:    0 = scaffolded, 1 = error, 2 = already exists (use --force to overwrite).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# --- Input validation ------------------------------------------------------
NAME=""; MODE="jssg"; FORCE=0
for arg in "$@"; do
  case "$arg" in
    --rule)  MODE="rule" ;;
    --force) FORCE=1 ;;
    -*)      die "Unknown flag: $arg" ;;
    *)       [[ -z "$NAME" ]] && NAME="$arg" || die "Unexpected argument: $arg" ;;
  esac
done
[[ -n "$NAME" ]] || { echo "Usage: $0 <name> [--rule] [--force]" >&2; exit 1; }
[[ "$NAME" =~ ^[a-z0-9][a-z0-9-]*$ ]] || die "Name must be kebab-case: '$NAME'"

need_cmd git
need_cmd jq

LANGUAGE="$(config_get '.language' 'tsx')"
case "$LANGUAGE" in
  tsx)        EXT="tsx"; LANG_TYPE="TSX" ;;
  jsx)        EXT="jsx"; LANG_TYPE="JSX" ;;
  typescript) EXT="ts";  LANG_TYPE="TypeScript" ;;
  javascript) EXT="js";  LANG_TYPE="JavaScript" ;;
  *)          EXT="$LANGUAGE"; LANG_TYPE="$(printf '%s' "$LANGUAGE" | tr '[:lower:]' '[:upper:]')" ;;
esac

PROJ="$(codemod_proj_dir "$NAME")"
if [[ -d "$PROJ" && $FORCE -ne 1 ]]; then
  skip "Codemod '$NAME' already exists at ${PROJ#"$(target_root)"/}. Re-run with --force to overwrite."
fi

log_step "Scaffolding codemod '$NAME' ($MODE, language: $LANGUAGE)"
mkdir -p "$PROJ/tests/basic"

# render <template> <dest> — substitute __TOKENS__ and write the file.
render() {
  local tpl="$1" dest="$2"
  [[ -f "$tpl" ]] || die "Missing template: $tpl"
  sed -e "s/__NAME__/$NAME/g" \
      -e "s/__LANGUAGE_TYPE__/$LANG_TYPE/g" \
      -e "s/__LANGUAGE__/$LANGUAGE/g" \
      -e "s/__EXT__/$EXT/g" \
      "$tpl" > "$dest"
}

T="$PIPELINE_TEMPLATES_DIR"
if [[ "$MODE" == "rule" ]]; then
  render "$T/astgrep-rule.yml.template" "$PROJ/rule.yml"
  log_ok "rule.yml"
else
  render "$T/transform.ts.template" "$PROJ/transform.ts"
  log_ok "transform.ts"
fi
render "$T/fixtures/input.tsx.template"    "$PROJ/tests/basic/input.$EXT"
render "$T/fixtures/expected.tsx.template" "$PROJ/tests/basic/expected.$EXT"
render "$T/workflow.yaml.template"         "$PROJ/workflow.yaml"
render "$T/codemod.yaml.template"          "$PROJ/codemod.yaml"
log_ok "tests/basic/{input,expected}.$EXT, workflow.yaml, codemod.yaml"

echo ""
log_step "Next: implement the transform, then iterate"
echo "  1. Explore the AST:   https://ast-grep.github.io/playground.html" >&2
if [[ "$MODE" == "rule" ]]; then
  echo "  2. Edit the rule:     ${PROJ#"$(target_root)"/}/rule.yml" >&2
else
  echo "  2. Edit the transform: ${PROJ#"$(target_root)"/}/transform.ts" >&2
fi
echo "  3. Edit fixtures:     ${PROJ#"$(target_root)"/}/tests/basic/{input,expected}.$EXT" >&2
echo "  4. Tight loop:        bash $SCRIPT_DIR/02-inner-loop.sh $NAME" >&2
