#!/usr/bin/env bash
# guardrail.sh — PreToolUse backend that blocks an unguarded mass codemod apply.
# Part of: codemod-react-pipeline  (hook backend; see hooks/hooks.json)
#
# Fires on every Bash tool call while the skill session is active. It only ever blocks one thing:
# a `codemod jssg run` (or `ast-grep scan --update-all`) that targets a BROAD path WITHOUT
# --dry-run, when no dry-run sentinel exists for that codemod. Everything else is allowed.
#
# Contract (Claude Code hooks): read the tool input on stdin (JSON) or $TOOL_INPUT; print a
# reason to stderr and exit 2 to block; exit 0 to allow.

set -uo pipefail

# --- Obtain the command being run ------------------------------------------
INPUT="${TOOL_INPUT:-}"
if [[ -z "$INPUT" && ! -t 0 ]]; then INPUT="$(cat || true)"; fi

# Pull the bash command string out of the JSON if jq is available; else use raw input.
CMD="$INPUT"
if command -v jq >/dev/null 2>&1; then
  parsed="$(printf '%s' "$INPUT" | jq -r '.command // .tool_input.command // empty' 2>/dev/null || true)"
  [[ -n "$parsed" ]] && CMD="$parsed"
fi

allow() { exit 0; }
block() {
  echo "[codemod-react-pipeline] BLOCKED: $1" >&2
  echo "" >&2
  echo "Mass codemod applies must be preceded by an inspected dry-run." >&2
  echo "  1. bash scripts/03-dry-run.sh <name>          # preview + write sentinel" >&2
  echo "  2. bash scripts/04-validate-findings.sh <name> # gates" >&2
  echo "  3. bash scripts/05-run-batched.sh <name>       # safe, batched, resumable apply" >&2
  echo "" >&2
  echo "Override (you accept the risk): add --dry-run, narrow the target, or 'touch' the sentinel." >&2
  exit 2
}

# --- Only consider real apply commands -------------------------------------
is_apply=0
case "$CMD" in
  *"codemod jssg run"*|*"jssg run"*) is_apply=1 ;;
  *"ast-grep scan"*"--update-all"*|*"ast-grep scan"*"-U"*) is_apply=1 ;;
esac
[[ $is_apply -eq 1 ]] || allow

# Our own pipeline scripts handle gating internally — never block them.
case "$CMD" in
  *"05-run-batched.sh"*|*"03-dry-run.sh"*|*"04-validate-findings.sh"*|*"02-inner-loop.sh"*) allow ;;
esac

# A dry-run is self-evidently safe.
case "$CMD" in *"--dry-run"*) allow ;; esac

# If ANY dry-run sentinel exists under a state dir, the homework has been done — allow.
# (Per-codemod precision is enforced by 05-run-batched.sh's own require_dry_run; this hook is
# defense-in-depth, so a coarse "a dry-run happened somewhere" signal is sufficient.)
repo_root="$(git rev-parse --show-toplevel 2>/dev/null || echo .)"
state_base="$(jq -r '.state_dir // ".codemod-pipeline"' "${CLAUDE_PLUGIN_ROOT:-.}/config.json" 2>/dev/null || echo .codemod-pipeline)"
[[ -z "$state_base" || "$state_base" == "null" ]] && state_base=".codemod-pipeline"
if compgen -G "$repo_root/$state_base/*/dry-run.ok" >/dev/null 2>&1; then
  allow
fi

# Otherwise block. Inner-loop single-file trials go through 02-inner-loop.sh (allow-listed above);
# a manual single-file run should add --dry-run or use that script. We err toward blocking because
# the cost of a wrongful block is one flag, and the cost of a wrongful allow is a mass apply.
block "'jssg run' / 'ast-grep --update-all' without --dry-run and no dry-run sentinel on record"
