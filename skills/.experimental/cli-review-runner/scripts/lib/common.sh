#!/usr/bin/env bash
# common.sh - shared helpers for cli-review-runner probes.
# Sourced by review.sh and tests. Not executable on its own.

set -euo pipefail

# ---------------------------------------------------------------------------
# Exit codes - distinct codes per err-non-zero-exit-codes rule.
# review.sh and render.sh both use these.
# ---------------------------------------------------------------------------
readonly CRR_EX_OK=0
readonly CRR_EX_FINDINGS_FAILED=1     # Probes ran, but at least one rule failed.
readonly CRR_EX_USAGE=2                # POSIX/getopt convention for usage errors.
readonly CRR_EX_TARGET_MISSING=66      # sysexits.h EX_NOINPUT - target CLI not found.
readonly CRR_EX_TEMPFAIL=75            # sysexits.h EX_TEMPFAIL - probe timed out.

# ---------------------------------------------------------------------------
# Portable timeout wrapper.
# Usage: crr_with_timeout <seconds> <cmd> [args...]
# Exits with CRR_EX_TEMPFAIL (75) on timeout; forwards command exit code otherwise.
# macOS ships without GNU `timeout`, so we fall back to `gtimeout` or Perl.
# ---------------------------------------------------------------------------
crr_with_timeout() {
  local seconds=$1
  shift
  if command -v timeout >/dev/null 2>&1; then
    timeout --preserve-status "$seconds" "$@"
    local rc=$?
    # GNU timeout: 124 = killed by timeout.
    if [[ $rc -eq 124 ]]; then
      return "$CRR_EX_TEMPFAIL"
    fi
    return "$rc"
  fi
  if command -v gtimeout >/dev/null 2>&1; then
    gtimeout --preserve-status "$seconds" "$@"
    local rc=$?
    if [[ $rc -eq 124 ]]; then
      return "$CRR_EX_TEMPFAIL"
    fi
    return "$rc"
  fi
  # Perl fallback - works on every macOS without coreutils.
  perl -e 'alarm shift; exec @ARGV' "$seconds" "$@"
  local rc=$?
  # Perl alarm kill => 142 (128+SIGALRM=14). Normalize.
  if [[ $rc -eq 142 ]]; then
    return "$CRR_EX_TEMPFAIL"
  fi
  return "$rc"
}

# ---------------------------------------------------------------------------
# Verb classification. Safe verbs may be invoked with bad args; destructive
# verbs are only inspected via --help unless --include-destructive is active.
# Reads CRR_SAFE_VERBS and CRR_DESTRUCTIVE_VERBS from config (set by review.sh).
# ---------------------------------------------------------------------------
crr_is_safe_verb() {
  local verb=$1
  # Destructive list is authoritative. A verb appearing in both safe_verbs
  # and destructive_verbs is never treated as safe, even by accident.
  if crr_is_destructive_verb "$verb"; then
    return 1
  fi
  local safe
  for safe in "${CRR_SAFE_VERBS[@]:-list get show status describe help version config ls}"; do
    if [[ "$verb" == "$safe" ]]; then
      return 0
    fi
  done
  return 1
}

crr_is_destructive_verb() {
  local verb=$1
  local bad
  for bad in "${CRR_DESTRUCTIVE_VERBS[@]:-delete drop destroy remove reset purge rm del}"; do
    if [[ "$verb" == "$bad" ]]; then
      return 0
    fi
  done
  return 1
}

# ---------------------------------------------------------------------------
# JSON string escape. Used when emitting NDJSON findings from bash.
# Not a full JSON encoder - only escapes the characters that break string
# values (backslash, double quote, control chars, newlines, tabs).
# ---------------------------------------------------------------------------
crr_json_escape() {
  local s=$1
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  s=${s//$'\n'/\\n}
  s=${s//$'\r'/\\r}
  s=${s//$'\t'/\\t}
  printf '%s' "$s"
}

# ---------------------------------------------------------------------------
# Emit a single NDJSON finding line to the findings file.
# Args:
#   $1 - rule_id (e.g., help-examples-in-help)
#   $2 - pass    (true or false)
#   $3 - probe   (P1..P10)
#   $4 - impact  (CRITICAL, HIGH, MEDIUM-HIGH, MEDIUM)
#   $5 - evidence (human-readable sentence)
# Requires CRR_FINDINGS_FILE to be set.
# ---------------------------------------------------------------------------
crr_emit_finding() {
  local rule_id=$1 pass=$2 probe=$3 impact=$4 evidence=$5
  local escaped_evidence
  escaped_evidence=$(crr_json_escape "$evidence")
  printf '{"rule_id":"%s","pass":%s,"probe":"%s","impact":"%s","evidence":"%s"}\n' \
    "$rule_id" "$pass" "$probe" "$impact" "$escaped_evidence" \
    >>"$CRR_FINDINGS_FILE"
}

# ---------------------------------------------------------------------------
# Load rule catalog into associative arrays for probe lookups.
# Populates:
#   CRR_RULE_IMPACT[rule_id]    = CRITICAL | HIGH | MEDIUM-HIGH | MEDIUM
#   CRR_RULE_PROBE[rule_id]     = P1..P10 | manual
#   CRR_RULE_TESTABLE[rule_id]  = auto | partial | manual
#   CRR_RULE_TITLE[rule_id]     = human-readable title
# Comment lines (starting with #) and the header row are skipped.
# ---------------------------------------------------------------------------
declare -gA CRR_RULE_IMPACT=()
declare -gA CRR_RULE_PROBE=()
declare -gA CRR_RULE_TESTABLE=()
declare -gA CRR_RULE_TITLE=()

crr_load_catalog() {
  local catalog=$1
  if [[ ! -f "$catalog" ]]; then
    echo "Error: rule catalog not found at '$catalog'." >&2
    echo "  Expected at: references/rule-catalog.tsv" >&2
    return "$CRR_EX_TARGET_MISSING"
  fi
  local rule_id title impact probe testable
  local first=1
  while IFS=$'\t' read -r rule_id title impact probe testable; do
    [[ -z "$rule_id" || "$rule_id" =~ ^# ]] && continue
    if [[ $first -eq 1 ]]; then
      first=0
      continue  # header row
    fi
    CRR_RULE_TITLE[$rule_id]=$title
    CRR_RULE_IMPACT[$rule_id]=$impact
    CRR_RULE_PROBE[$rule_id]=$probe
    CRR_RULE_TESTABLE[$rule_id]=$testable
  done <"$catalog"
}

# ---------------------------------------------------------------------------
# Check whether we can invoke the target CLI at all. Fails fast if not found
# or not executable - per err-exit-fast-on-missing-required.
# ---------------------------------------------------------------------------
crr_validate_target() {
  local target=$1
  if [[ -z "$target" ]]; then
    echo "Error: target CLI path is required." >&2
    echo "  review --target /usr/local/bin/mycli" >&2
    return "$CRR_EX_USAGE"
  fi
  if [[ ! -e "$target" ]]; then
    echo "Error: target CLI '$target' does not exist." >&2
    echo "  Check the path with: which mycli" >&2
    return "$CRR_EX_TARGET_MISSING"
  fi
  if [[ ! -x "$target" ]]; then
    echo "Error: target CLI '$target' is not executable." >&2
    echo "  chmod +x '$target'" >&2
    return "$CRR_EX_TARGET_MISSING"
  fi
}

# ---------------------------------------------------------------------------
# Run the target CLI and capture stdout / stderr / exit code separately.
# Used by every probe. Stdout of target lands in file $1, stderr in file $2.
# Command exit code is echoed to stdout of this function.
# Usage:
#   rc=$(crr_capture "$stdout_file" "$stderr_file" "$target" arg1 arg2 ...)
# ---------------------------------------------------------------------------
crr_capture() {
  local stdout_file=$1 stderr_file=$2
  shift 2
  local rc=0
  crr_with_timeout "${CRR_TIMEOUT:-5}" "$@" \
    >"$stdout_file" 2>"$stderr_file" </dev/null || rc=$?
  printf '%s' "$rc"
}

# ---------------------------------------------------------------------------
# Discover subcommands by parsing the target's top-level --help output.
# Handles three common formats:
#   1. "Commands:" / "Available Commands:" / "Subcommands:" header, then indented list
#   2. "CORE COMMANDS" / "GITHUB ACTIONS COMMANDS" (uppercase, no colon - gh style)
#   3. "Basic Commands (Beginner):" with inline tags (kubectl style)
# If nothing is found, returns an empty list - probes degrade gracefully.
# ---------------------------------------------------------------------------
crr_discover_subcommands() {
  local target=$1
  local stdout_file stderr_file
  stdout_file=$(mktemp)
  stderr_file=$(mktemp)
  crr_capture "$stdout_file" "$stderr_file" "$target" --help >/dev/null || true
  awk '
    BEGIN { in_cmds = 0 }
    # Section header match: any line whose first non-space word contains "command"
    # (case-insensitive), optionally followed by parens and a colon. Matches
    # "Commands:", "COMMANDS", "CORE COMMANDS", "Basic Commands (Beginner):".
    tolower($0) ~ /^[[:space:]]*[a-z][a-z ]*commands?([[:space:]]*\([^)]*\))?[[:space:]]*:?[[:space:]]*$/ {
      in_cmds = 1
      next
    }
    # A line starting in column 1 (no leading space) that is not blank ends
    # the current commands block - usually the next section header.
    /^[^[:space:]]/ && in_cmds { in_cmds = 0 }
    in_cmds && /^[[:space:]]+[a-z][a-z0-9:_-]+/ {
      # Strip leading whitespace; first token is the verb.
      sub(/^[[:space:]]+/, "")
      split($0, parts, /[[:space:]]+/)
      verb = parts[1]
      # Drop trailing colon commonly used in tag-aligned help (e.g., "auth:").
      sub(/:$/, "", verb)
      if (verb ~ /^[a-z][a-z0-9:_-]*$/ && verb != "help") {
        print verb
      }
    }
  ' "$stdout_file" | sort -u
  rm -f "$stdout_file" "$stderr_file"
}
