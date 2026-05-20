#!/usr/bin/env bash
# common.sh — shared helpers for the codemod-react-pipeline scripts.
# Part of: codemod-react-pipeline
#
# Source this from every step script:
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   source "$SCRIPT_DIR/lib/common.sh"
#
# Conventions used across the pipeline:
#   - The TARGET repo is the current working directory ($PWD), not the skill dir.
#   - Per-codemod state lives under <state_dir>/<codemod-name>/ in the target repo.
#   - Exit codes: 0 = success, 1 = error, 2 = skipped / already done / precondition unmet.

set -euo pipefail

# --- Locations -------------------------------------------------------------

# Directory of the script that sourced us (scripts/), and the skill root.
PIPELINE_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PIPELINE_SKILL_DIR="$(cd "$PIPELINE_SCRIPT_DIR/.." && pwd)"
PIPELINE_CONFIG_FILE="${CODEMOD_PIPELINE_CONFIG:-$PIPELINE_SKILL_DIR/config.json}"
PIPELINE_TEMPLATES_DIR="$PIPELINE_SKILL_DIR/assets/templates"

# --- Logging ---------------------------------------------------------------

_pp_is_tty() { [[ -t 2 ]]; }
if _pp_is_tty; then
  _C_RESET=$'\033[0m'; _C_DIM=$'\033[2m'; _C_RED=$'\033[31m'
  _C_YEL=$'\033[33m'; _C_GRN=$'\033[32m'; _C_BLU=$'\033[34m'
else
  _C_RESET=""; _C_DIM=""; _C_RED=""; _C_YEL=""; _C_GRN=""; _C_BLU=""
fi

log_step() { echo "${_C_BLU}==>${_C_RESET} $*" >&2; }
log_info() { echo "${_C_DIM}    $*${_C_RESET}" >&2; }
log_ok()   { echo "${_C_GRN}  ✓ ${_C_RESET}$*" >&2; }
log_warn() { echo "${_C_YEL}  ! ${_C_RESET}$*" >&2; }

# die <message...> — print an actionable error and exit 1.
die() { echo "${_C_RED}Error:${_C_RESET} $*" >&2; exit 1; }

# skip <message...> — print a reason and exit 2 (precondition not met / nothing to do).
skip() { echo "${_C_YEL}Skip:${_C_RESET} $*" >&2; exit 2; }

# --- Dependency checks -----------------------------------------------------

# need_cmd <command> [install-hint] — fail with a hint if a tool is missing.
need_cmd() {
  local cmd="$1" hint="${2:-}"
  command -v "$cmd" >/dev/null 2>&1 && return 0
  if [[ -n "$hint" ]]; then
    die "'$cmd' is required but not found. $hint"
  fi
  die "'$cmd' is required but not found in PATH."
}

# codemod_cli — echo how to invoke the codemod CLI (global binary or npx fallback).
codemod_cli() {
  if command -v codemod >/dev/null 2>&1; then
    echo "codemod"
  else
    echo "npx --yes codemod"
  fi
}

# --- Config access ---------------------------------------------------------

# config_get <jq-path> [default] — read a scalar from config.json.
config_get() {
  local path="$1" default="${2:-}"
  [[ -f "$PIPELINE_CONFIG_FILE" ]] || { echo "$default"; return 0; }
  local val
  val="$(jq -r "${path} // empty" "$PIPELINE_CONFIG_FILE" 2>/dev/null || true)"
  if [[ -z "$val" || "$val" == "null" ]]; then echo "$default"; else echo "$val"; fi
}

# config_get_array <jq-path> — print array elements, one per line.
config_get_array() {
  local path="$1"
  [[ -f "$PIPELINE_CONFIG_FILE" ]] || return 0
  jq -r "${path}[]? // empty" "$PIPELINE_CONFIG_FILE" 2>/dev/null || true
}

# gate_enabled <name> — true if config.gates.<name> is not explicitly false.
gate_enabled() {
  local name="$1" v
  v="$(config_get ".gates.${name}" "true")"
  [[ "$v" != "false" ]]
}

# --- Target repo / git -----------------------------------------------------

# target_root — absolute path to the git repo we are transforming.
target_root() {
  git rev-parse --show-toplevel 2>/dev/null \
    || die "Not inside a git repository. Run the pipeline from the codebase you want to transform."
}

# require_clean_git — refuse to proceed with uncommitted changes (so rollback is trivial).
require_clean_git() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
    || die "Not inside a git repository. The pipeline needs git for safe rollback."
  if [[ -n "$(git status --porcelain)" ]]; then
    die "Working tree is dirty. Commit or stash first so each batch is reversible:
    git stash               # park your changes, or
    git add -A && git commit -m 'wip'"
  fi
}

# --- State ------------------------------------------------------------------

# state_dir_for <codemod-name> — ensure and echo the per-codemod state directory.
state_dir_for() {
  local name="$1"
  [[ -n "$name" ]] || die "state_dir_for: codemod name is required."
  local base; base="$(config_get '.state_dir' '.codemod-pipeline')"
  local dir="$(target_root)/$base/$name"
  mkdir -p "$dir"
  echo "$dir"
}

# dry_run_sentinel <codemod-name> — path to the file proving a dry-run happened.
dry_run_sentinel() { echo "$(state_dir_for "$1")/dry-run.ok"; }

# require_dry_run <codemod-name> — block mass apply unless 03-dry-run.sh has run.
require_dry_run() {
  local name="$1" sentinel; sentinel="$(dry_run_sentinel "$name")"
  [[ -f "$sentinel" ]] || die "No dry-run on record for '$name'.
    Run:  bash $PIPELINE_SCRIPT_DIR/03-dry-run.sh $name
    then: bash $PIPELINE_SCRIPT_DIR/04-validate-findings.sh $name
    before applying changes at scale."
}

# --- Codemod project layout -------------------------------------------------

# codemod_proj_dir <codemod-name> — where a scaffolded codemod lives in the target repo.
codemod_proj_dir() { echo "$(target_root)/codemods/$1"; }

# transform_file <codemod-name> — path to the JSSG transform (created by 01-scaffold.sh).
transform_file() {
  local d; d="$(codemod_proj_dir "$1")"
  if [[ -f "$d/transform.ts" ]]; then echo "$d/transform.ts"
  elif [[ -f "$d/rule.yml" ]]; then echo "$d/rule.yml"
  else echo "$d/transform.ts"; fi
}

# require_codemod <codemod-name> — fail if the codemod has not been scaffolded.
require_codemod() {
  local name="$1" d; d="$(codemod_proj_dir "$name")"
  [[ -d "$d" ]] || die "Codemod '$name' not found at $d.
    Scaffold it first:  bash $PIPELINE_SCRIPT_DIR/01-scaffold.sh $name"
}

# --- Affected files ---------------------------------------------------------

# affected_files — list of currently-modified tracked files (post-run), one per line.
affected_files() {
  git -C "$(target_root)" diff --name-only --diff-filter=ACMR
}

# codemod_apply <name> <path...> — apply the scaffolded codemod (transform.ts or rule.yml)
# to the given paths IN PLACE (no dry-run). Returns the CLI's exit status.
codemod_apply() {
  local name="$1"; shift
  local proj language cm
  proj="$(codemod_proj_dir "$name")"
  language="$(config_get '.language' 'tsx')"
  cm="$(codemod_cli)"
  local -a threads=()
  local mt; mt="$(config_get '.max_threads' '0')"
  [[ "$mt" =~ ^[0-9]+$ && "$mt" -gt 0 ]] && threads=(--max-threads "$mt")
  if [[ -f "$proj/transform.ts" ]]; then
    # shellcheck disable=SC2086
    $cm jssg run "$proj/transform.ts" "$@" --language "$language" "${threads[@]}"
  elif [[ -f "$proj/rule.yml" ]]; then
    command -v ast-grep >/dev/null 2>&1 || die "ast-grep not installed (needed to apply rule.yml). Install it or convert to a JSSG transform."
    ast-grep scan --rule "$proj/rule.yml" --update-all "$@"
  else
    die "No transform.ts or rule.yml for '$name'."
  fi
}

# _pathspecs — print config.src_globs as git :(glob) pathspecs, one per line.
# :(glob) magic makes ** match across directories; * stops at /. Braces are NOT supported,
# so config.src_globs must list one glob per extension.
_pathspecs() {
  local g
  while IFS= read -r g; do
    [[ -n "$g" ]] && printf ':(glob)%s\n' "$g"
  done < <(config_get_array '.src_globs')
}

# list_candidates — tracked files matching config.src_globs, one per line (NUL-safe internally).
list_candidates() {
  local root; root="$(target_root)"
  local -a specs=(); local s
  while IFS= read -r s; do specs+=("$s"); done < <(_pathspecs)
  [[ ${#specs[@]} -gt 0 ]] || specs=(':(glob)src/**/*.ts' ':(glob)src/**/*.tsx' ':(glob)src/**/*.js' ':(glob)src/**/*.jsx')
  git -C "$root" ls-files -- "${specs[@]}" 2>/dev/null
}

# count_candidates — number of files matching config.src_globs (the blast-radius ceiling).
count_candidates() { list_candidates | wc -l | tr -d ' '; }
