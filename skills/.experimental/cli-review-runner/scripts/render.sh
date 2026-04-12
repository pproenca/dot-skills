#!/usr/bin/env bash
# render.sh - format cli-review-runner findings as text / JSON / NDJSON.
#
# Reads NDJSON findings (one per line) from --input <file> or stdin.
# Writes the formatted report to stdout. Errors go to stderr.
#
# This script eats its own dog food: it obeys the same cli-for-agents
# rules that cli-review-runner checks for in target CLIs.

set -euo pipefail

usage() {
  cat <<EOF
Usage: render.sh [--input <file>] [--format text|json|ndjson]
                 [--target <name>] [--rule-catalog <file>]
                 [--help]

Format cli-review-runner findings for human or machine consumption.

Options:
  --input, -i <file>        Read NDJSON findings from <file> (default: stdin, '-')
  --format, -f <kind>       text (default) | json | ndjson
  --target <name>           Target CLI name to include in the report header
  --rule-catalog <file>     Path to rule-catalog.tsv (for manual-only rule list)
  --no-color                Disable ANSI color (also set by NO_COLOR env var)
  --help, -h                Show this help and exit 0
  --version                 Print version and exit 0

Exit codes:
   0  all findings passed
   1  at least one finding failed (the normal case when a CLI has issues)
   2  usage error (bad flag, missing input)
  75  transient read failure (input file unreadable)

Examples:
  cat findings.ndjson | render.sh --format text
  render.sh --input findings.ndjson --format json --target mycli
  review.sh --target /usr/local/bin/mycli --ndjson | render.sh --format text

See also:
  review.sh   run the probes and produce findings
EOF
}

# ---------------------------------------------------------------------------
# Exit codes (mirror common.sh). We don't source common.sh here because
# render.sh is meant to work standalone for pipeline composition.
# ---------------------------------------------------------------------------
readonly EX_OK=0
readonly EX_FINDINGS_FAILED=1
readonly EX_USAGE=2
readonly EX_TEMPFAIL=75
readonly CRR_VERSION="0.1.0"

# ---------------------------------------------------------------------------
# Flag parsing.
# ---------------------------------------------------------------------------
INPUT="-"
FORMAT="text"
TARGET=""
RULE_CATALOG=""
USE_COLOR=1

if [[ -n "${NO_COLOR:-}" ]] || [[ ! -t 1 ]]; then
  USE_COLOR=0
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h) usage; exit "$EX_OK" ;;
    --version) echo "render.sh $CRR_VERSION"; exit "$EX_OK" ;;
    --input|-i)
      if [[ $# -lt 2 ]]; then
        echo "Error: --input requires a file path or '-' for stdin." >&2
        echo "  render.sh --input findings.ndjson" >&2
        exit "$EX_USAGE"
      fi
      INPUT=$2; shift 2 ;;
    --format|-f)
      if [[ $# -lt 2 ]]; then
        echo "Error: --format requires a value (text, json, ndjson)." >&2
        echo "  render.sh --format text" >&2
        exit "$EX_USAGE"
      fi
      FORMAT=$2; shift 2 ;;
    --target)
      TARGET=$2; shift 2 ;;
    --rule-catalog)
      RULE_CATALOG=$2; shift 2 ;;
    --no-color)
      USE_COLOR=0; shift ;;
    *)
      echo "Error: unknown flag '$1'." >&2
      echo "  render.sh --help" >&2
      exit "$EX_USAGE" ;;
  esac
done

case "$FORMAT" in
  text|json|ndjson) ;;
  *)
    echo "Error: unknown --format '$FORMAT'. Valid values: text, json, ndjson." >&2
    echo "  render.sh --format text" >&2
    exit "$EX_USAGE" ;;
esac

# ---------------------------------------------------------------------------
# Load findings from input.
# ---------------------------------------------------------------------------
FINDINGS_TMP=$(mktemp)
trap 'rm -f "$FINDINGS_TMP"' EXIT

if [[ "$INPUT" == "-" ]]; then
  cat >"$FINDINGS_TMP"
elif [[ ! -r "$INPUT" ]]; then
  echo "Error: cannot read input file '$INPUT'." >&2
  echo "  chmod +r '$INPUT'" >&2
  exit "$EX_TEMPFAIL"
else
  cat "$INPUT" >"$FINDINGS_TMP"
fi

# ---------------------------------------------------------------------------
# Parse NDJSON into aligned columns via awk. Keeps bash out of JSON parsing
# while still running on systems without jq.
# ---------------------------------------------------------------------------
extract_field() {
  local key=$1 line=$2
  # Minimal JSON string/bool extractor. Not a full parser - probes.sh only
  # emits flat objects with string or boolean values.
  local value
  value=$(printf '%s' "$line" | awk -v k="$key" '
    {
      # Find "key":"value" (string) or "key":bool (boolean)
      pattern_s = "\"" k "\":\""
      pattern_b = "\"" k "\":"
      idx = index($0, pattern_s)
      if (idx > 0) {
        rest = substr($0, idx + length(pattern_s))
        # Walk until unescaped "
        out = ""
        escaped = 0
        for (i = 1; i <= length(rest); i++) {
          c = substr(rest, i, 1)
          if (escaped) { out = out c; escaped = 0; continue }
          if (c == "\\") { out = out c; escaped = 1; continue }
          if (c == "\"") break
          out = out c
        }
        print out
        exit 0
      }
      idx = index($0, pattern_b)
      if (idx > 0) {
        rest = substr($0, idx + length(pattern_b))
        # Strip leading space, then capture until , or }
        sub(/^[[:space:]]+/, "", rest)
        split(rest, parts, /[,}]/)
        print parts[1]
      }
    }
  ')
  printf '%s' "$value"
}

# Unescape JSON string escapes back to plain text for display.
unescape_json() {
  local s=$1
  s=${s//\\n/$'\n'}
  s=${s//\\r/$'\r'}
  s=${s//\\t/$'\t'}
  s=${s//\\\"/\"}
  s=${s//\\\\/\\}
  printf '%s' "$s"
}

impact_rank() {
  case "$1" in
    CRITICAL) echo 0 ;;
    HIGH) echo 1 ;;
    MEDIUM-HIGH) echo 2 ;;
    MEDIUM) echo 3 ;;
    *) echo 9 ;;
  esac
}

# ---------------------------------------------------------------------------
# Emit the chosen format.
# ---------------------------------------------------------------------------
total=0
passed=0
failed=0
declare -a lines=()

while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  lines+=("$line")
  (( total+=1 ))
  pass=$(extract_field "pass" "$line")
  if [[ "$pass" == "true" ]]; then
    (( passed+=1 ))
  else
    (( failed+=1 ))
  fi
done <"$FINDINGS_TMP"

color_red=""; color_green=""; color_dim=""; color_reset=""
if (( USE_COLOR == 1 )); then
  color_red=$'\033[31m'
  color_green=$'\033[32m'
  color_dim=$'\033[2m'
  color_reset=$'\033[0m'
fi

case "$FORMAT" in
  ndjson)
    for line in "${lines[@]}"; do
      printf '%s\n' "$line"
    done
    ;;
  json)
    printf '{"target":"%s","summary":{"total":%d,"passed":%d,"failed":%d},"findings":[' \
      "${TARGET:-unknown}" "$total" "$passed" "$failed"
    sep=""
    for line in "${lines[@]}"; do
      printf '%s%s' "$sep" "$line"
      sep=","
    done
    printf ']}\n'
    ;;
  text)
    # Header
    if [[ -n "$TARGET" ]]; then
      printf 'CLI Review: %s\n' "$TARGET"
    else
      printf 'CLI Review\n'
    fi
    printf 'Findings: %d total (%s%d passed%s, %s%d failed%s)\n\n' \
      "$total" "$color_green" "$passed" "$color_reset" \
      "$color_red" "$failed" "$color_reset"

    # Group by impact (CRITICAL -> HIGH -> MEDIUM-HIGH -> MEDIUM).
    for target_impact in CRITICAL HIGH MEDIUM-HIGH MEDIUM; do
      local_count=0
      for line in "${lines[@]}"; do
        impact=$(extract_field "impact" "$line")
        [[ "$impact" != "$target_impact" ]] && continue
        if [[ $local_count -eq 0 ]]; then
          printf '%s\n' "$target_impact"
          local_count=1
        fi
        rule=$(extract_field "rule_id" "$line")
        pass=$(extract_field "pass" "$line")
        probe=$(extract_field "probe" "$line")
        evidence=$(extract_field "evidence" "$line")
        evidence=$(unescape_json "$evidence")
        if [[ "$pass" == "true" ]]; then
          tag="${color_green}PASS${color_reset}"
        else
          tag="${color_red}FAIL${color_reset}"
        fi
        printf '  %s  %-38s %s[%s]%s %s\n' \
          "$tag" "$rule" "$color_dim" "$probe" "$color_reset" "$evidence"
      done
      if [[ $local_count -gt 0 ]]; then
        printf '\n'
      fi
    done

    # Manual-only rules section (not probed, listed from catalog).
    if [[ -n "$RULE_CATALOG" ]] && [[ -f "$RULE_CATALOG" ]]; then
      declare -A probed_rules=()
      for line in "${lines[@]}"; do
        rule=$(extract_field "rule_id" "$line")
        probed_rules[$rule]=1
      done
      manual_rules=()
      while IFS=$'\t' read -r rid title impact probe testable; do
        [[ -z "$rid" || "$rid" =~ ^# || "$rid" == "rule_id" ]] && continue
        if [[ "$testable" == "manual" ]] && [[ -z "${probed_rules[$rid]:-}" ]]; then
          manual_rules+=("$rid")
        fi
      done <"$RULE_CATALOG"
      if (( ${#manual_rules[@]} > 0 )); then
        printf 'Manual review required (not black-box testable):\n'
        for rid in "${manual_rules[@]}"; do
          printf '  %s-%s %s\n' "$color_dim" "$color_reset" "$rid"
        done
        printf '\n'
      fi
    fi

    printf 'Summary: %d passed, %d failed, %d total\n' "$passed" "$failed" "$total"
    ;;
esac

if (( failed > 0 )); then
  exit "$EX_FINDINGS_FAILED"
fi
exit "$EX_OK"
