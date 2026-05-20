#!/usr/bin/env bash
# 00-plan.sh — turn a transformation goal into a written plan + blast-radius estimate.
# Part of: codemod-react-pipeline  (inner loop, step 0)
#
# Run from the root of the codebase you want to transform.
#
# Usage:   bash 00-plan.sh "<goal>" [codemod-name]
# Example: bash 00-plan.sh "Replace <FieldGroup> with <Fieldset>" rename-fieldgroup
#
# Output:  <state_dir>/<name>/plan.md  — a checklist you fill in before scaffolding.
# Exit:    0 = plan written, 1 = error.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# --- Input validation ------------------------------------------------------
if [[ $# -lt 1 || -z "${1:-}" ]]; then
  echo "Usage: $0 \"<goal>\" [codemod-name]" >&2
  echo "" >&2
  echo "  <goal>         One sentence describing the transformation." >&2
  echo "  codemod-name   kebab-case id for the codemod (default: derived from goal)." >&2
  exit 1
fi

need_cmd git "Run this from inside the target git repository."
need_cmd jq "Install jq (e.g. 'brew install jq') — the pipeline reads config.json with it."

GOAL="$1"
NAME="${2:-}"
if [[ -z "$NAME" ]]; then
  # Derive a kebab-case name from the goal: lowercase, alnum→-, trim, cap length.
  NAME="$(printf '%s' "$GOAL" | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//' | cut -c1-40)"
  [[ -n "$NAME" ]] || NAME="codemod-$(date +%s)"
fi

LANGUAGE="$(config_get '.language' 'tsx')"
STATE="$(state_dir_for "$NAME")"
PLAN="$STATE/plan.md"

log_step "Planning codemod '$NAME' (language: $LANGUAGE)"

# --- Blast radius ----------------------------------------------------------
CANDIDATES="$(count_candidates)"
log_info "Candidate files matching config.src_globs: $CANDIDATES"
if [[ "$CANDIDATES" -eq 0 ]]; then
  log_warn "No files matched src_globs. Check 'src_globs' in config.json before continuing."
fi

# Suggest a tier so the dev knows how much ceremony the outer loop needs.
TIER="small"
if   [[ "$CANDIDATES" -ge 50000 ]]; then TIER="very-large (batched, resumable, expect multi-hour)"
elif [[ "$CANDIDATES" -ge 5000  ]]; then TIER="large (batched + per-batch verify)"
elif [[ "$CANDIDATES" -ge 200   ]]; then TIER="medium (batched recommended)"
else TIER="small (single batch is fine, still dry-run first)"; fi

# --- Write the plan --------------------------------------------------------
cat > "$PLAN" <<EOF
# Codemod plan: $NAME

> Generated $(date -u +%Y-%m-%dT%H:%M:%SZ) by codemod-react-pipeline / 00-plan.sh

## Goal

$GOAL

## Blast radius

- Candidate files (config.src_globs): **$CANDIDATES**
- Scale tier: **$TIER**
- Language: \`$LANGUAGE\`

## Classify the transformation  (decides the engine — see references/inner-outer-loop.md)

- [ ] **Syntactic** — pure pattern → replacement, no type/scope info needed.
      Prefer a declarative **ast-grep rule** (\`01-scaffold.sh $NAME --rule\`). Fast, deterministic.
- [ ] **Programmatic** — conditional logic, derived names, multiple edits per match.
      Use a **JSSG transform.ts** (\`01-scaffold.sh $NAME\`).
- [ ] **Semantic / cross-file** — needs imports, symbol resolution, type info.
      JSSG transform.ts + plan for import fixups; consider an \`ai:\` cleanup step in workflow.yaml.

## Safety pre-checks

- [ ] Is the transform **idempotent**? (running twice must not double-apply) — gate enforced in step 04.
- [ ] Are there **generated / vendored** dirs to exclude? Tighten \`src_globs\` / add \`exclude\`.
- [ ] Any **embedded languages** (e.g. GraphQL in template literals)? They need a separate pass.
- [ ] Minimum **capabilities** the codemod needs (fs, network)? Keep them minimal.

## Edge cases to cover with fixtures  (step 02)

- [ ] Happy path
- [ ] Already-migrated file (idempotency)
- [ ] (add the tricky shapes you know exist in this codebase)

## Next

\`\`\`bash
bash $SCRIPT_DIR/01-scaffold.sh $NAME            # JSSG transform, or
bash $SCRIPT_DIR/01-scaffold.sh $NAME --rule     # declarative ast-grep rule
\`\`\`
EOF

log_ok "Plan written: ${PLAN#"$(target_root)"/}"
echo ""
echo "Review the plan, tick the classification, then scaffold:" >&2
echo "  bash $SCRIPT_DIR/01-scaffold.sh $NAME" >&2
