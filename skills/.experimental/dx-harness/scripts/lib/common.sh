#!/usr/bin/env bash
# common.sh — shared helpers for dx-harness scripts
# Source from other scripts:  source "$(dirname "$0")/lib/common.sh"

# --- Strict mode ---
set -euo pipefail

# --- Resolve plugin/skill root ---
DX_SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
DX_CONFIG_FILE="${DX_SKILL_DIR}/config.json"

# --- Plugin data dir for persistent state ---
DX_DATA_DIR="${CLAUDE_PLUGIN_DATA:-${HOME}/.local/share/dx-harness}/dx-harness"
mkdir -p "$DX_DATA_DIR"

# --- Logging ---
log()  { printf '[dx-harness] %s\n' "$*" >&2; }
warn() { printf '[dx-harness] WARN: %s\n' "$*" >&2; }
die()  { printf '[dx-harness] ERROR: %s\n' "$*" >&2; exit 1; }

# --- jq required ---
require_jq() {
  command -v jq >/dev/null 2>&1 || die "jq is required. Install: brew install jq  (macOS) | apt install jq (Debian)"
}

# --- Safely substitute ${VAR} references in a string ---
# Only an allowlist of env vars is expanded; everything else is left literal.
# Refuses to expand $(...) or `...` — those are passed through unchanged and
# will fail loudly downstream rather than execute.
# Usage: safe_expand "${TMPDIR}/foo"
safe_expand() {
  local s="$1"
  # If the value contains a command substitution, bail without expanding.
  if [[ "$s" == *'$('* || "$s" == *'`'* ]]; then
    printf '%s' "$s"
    return
  fi
  # Expand only the allowlisted variables, in order.
  local var
  for var in TMPDIR HOME CLAUDE_PLUGIN_DATA CLAUDE_PLUGIN_ROOT PWD USER; do
    local val="${!var:-}"
    # Replace both ${VAR} and $VAR forms
    s="${s//\$\{$var\}/$val}"
    s="${s//\$$var/$val}"
  done
  printf '%s' "$s"
}

# --- Read config value with a default ---
# Usage: config_get "ttfc_target_seconds" 60
config_get() {
  local key="$1" default="${2:-}"
  if [[ -f "$DX_CONFIG_FILE" ]]; then
    local val
    val=$(jq -r --arg k "$key" '.[$k] // empty' "$DX_CONFIG_FILE" 2>/dev/null || true)
    if [[ -n "$val" && "$val" != "null" ]]; then
      safe_expand "$val"
      return
    fi
  fi
  printf '%s' "$default"
}

# --- Resolve repo root (config override → $PWD → git toplevel) ---
repo_root() {
  local override
  override=$(config_get "repo_root" "")
  if [[ -n "$override" ]]; then
    printf '%s' "$override"
    return
  fi
  git -C "${PWD}" rev-parse --show-toplevel 2>/dev/null || printf '%s' "$PWD"
}

# --- Scratch directory for ephemeral output ---
# Each call yields a fresh dir under $TMPDIR.
scratch_dir() {
  local prefix="${1:-dx-harness}"
  local root
  root=$(config_get "scratch_root" "${TMPDIR:-/tmp}")
  local dir="${root%/}/${prefix}-$(date +%s)-$$"
  mkdir -p "$dir"
  printf '%s' "$dir"
}

# --- Make a git worktree at a scratch path on a detached HEAD ---
# Usage: make_worktree <path>
# Caller is responsible for cleanup with cleanup_worktree.
make_worktree() {
  local path="$1"
  local root
  root=$(repo_root)
  ( cd "$root" && git worktree add --detach "$path" >/dev/null )
  printf '%s' "$path"
}

cleanup_worktree() {
  local path="$1"
  local root
  root=$(repo_root)
  ( cd "$root" && git worktree remove --force "$path" >/dev/null 2>&1 ) || true
  rm -rf "$path" 2>/dev/null || true
}

# --- Trap helper: register a cleanup for a worktree on EXIT ---
register_worktree_cleanup() {
  local path="$1"
  trap "cleanup_worktree '$path'" EXIT INT TERM
}

# --- Time a command in milliseconds ---
# Usage: ms=$(time_ms my_command arg1 arg2)
# stdout/stderr of the inner command go to FD 3 — caller can redirect.
time_ms() {
  local start_s start_ns
  if date +%s%3N >/dev/null 2>&1; then
    start_s=$(date +%s%3N)
    "$@"
    local end_s
    end_s=$(date +%s%3N)
    printf '%s' "$((end_s - start_s))"
  else
    # macOS date has no %N; use python fallback
    start_s=$(python3 -c 'import time;print(int(time.time()*1000))')
    "$@"
    local end_s
    end_s=$(python3 -c 'import time;print(int(time.time()*1000))')
    printf '%s' "$((end_s - start_s))"
  fi
}

# --- Template rendering: substitute {{var}} placeholders ---
# Usage: render_template <template-path> <output-path> KEY1=val1 KEY2=val2 ...
render_template() {
  local tmpl="$1" out="$2"
  shift 2
  local content
  content=$(cat "$tmpl")
  while [[ $# -gt 0 ]]; do
    local pair="$1"
    local k="${pair%%=*}"
    local v="${pair#*=}"
    # Use a python helper for safe substitution (sed chokes on slashes/newlines in $v)
    content=$(KEY="$k" VAL="$v" python3 -c '
import os, sys
data = sys.stdin.read()
k = os.environ["KEY"]
v = os.environ["VAL"]
print(data.replace("{{" + k + "}}", v), end="")
' <<< "$content")
    shift
  done
  mkdir -p "$(dirname "$out")"
  printf '%s' "$content" > "$out"
}

# --- Hash the repo for attrition-log keying ---
repo_hash() {
  local root
  root=$(repo_root)
  printf '%s' "$root" | shasum -a 256 | cut -c1-12
}
