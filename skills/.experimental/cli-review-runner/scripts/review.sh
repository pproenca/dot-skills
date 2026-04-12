#!/usr/bin/env bash
# review.sh - main entry point for cli-review-runner.
#
# Audits a target CLI against the cli-for-agents rules by running a suite
# of black-box probes and emitting a structured report.
#
# Dog-fooded: this script itself obeys the rules it checks for.

set -euo pipefail

# ---------------------------------------------------------------------------
# Locate our own directory so we can source lib/ and find the rule catalog
# regardless of where the user invokes us from.
# ---------------------------------------------------------------------------
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SKILL_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
RULE_CATALOG_DEFAULT="$SKILL_ROOT/references/rule-catalog.tsv"
RENDER_SH="$SCRIPT_DIR/render.sh"

# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"
# shellcheck source=lib/probes.sh
source "$SCRIPT_DIR/lib/probes.sh"

readonly CRR_VERSION="0.1.0"

usage() {
  cat <<EOF
Usage: review.sh --target <cli> [options]

Audit a command-line tool against the cli-for-agents design rules.
Runs 10 black-box probes covering ~25 of the 45 rules, then renders a
report to stdout. All probes are read-only by default.

Required:
  --target, -t <cli>     Path or PATH-resolvable name of the CLI to audit
                         (e.g., /usr/local/bin/mycli, gh, kubectl)

Options:
  --subcommands <list>   Comma-separated subcommands to probe (default: auto-discover)
  --timeout <seconds>    Per-probe timeout (default: 5)
  --format <kind>        text (default) | json | ndjson
  --json                 Alias for --format json
  --ndjson               Alias for --format ndjson
  --include-destructive  Also probe destructive verbs (delete/drop/...) with bogus args.
                         Default is to only inspect their --help output.
  --config <file>        Config file to load (default: ../config.json)
  --rule-catalog <file>  Rule catalog to load (default: ../references/rule-catalog.tsv)
  --no-color             Disable ANSI color (also honors NO_COLOR env var)
  --dry-run              Show which probes would run, but do not invoke the target
  --help, -h             Show this help and exit 0
  --version              Print version and exit 0

Exit codes:
   0  all findings passed
   1  at least one finding failed - the target CLI has issues to fix
   2  usage error (bad flag, missing --target)
  66  target CLI was not found or not executable
  75  a probe timed out; partial findings may still have been rendered

Examples:
  review.sh --target /usr/local/bin/mycli
  review.sh --target gh --subcommands pr,issue,repo --format json
  review.sh --target ./bin/acme --include-destructive --format ndjson
  review.sh --target kubectl --timeout 10 --no-color

See also:
  render.sh       re-format an existing findings file
  selftest.sh     run review.sh against a mock CLI to sanity-check probes
EOF
}

# ---------------------------------------------------------------------------
# Flag parsing.
# ---------------------------------------------------------------------------
TARGET=""
SUBCOMMANDS_ARG=""
FORMAT="text"
INCLUDE_DESTRUCTIVE=0
DRY_RUN=0
USE_COLOR=""
CRR_TIMEOUT=5
CONFIG_FILE="$SKILL_ROOT/config.json"
RULE_CATALOG="$RULE_CATALOG_DEFAULT"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h) usage; exit "$CRR_EX_OK" ;;
    --version) echo "review.sh $CRR_VERSION"; exit "$CRR_EX_OK" ;;
    --target|-t)
      if [[ $# -lt 2 ]]; then
        echo "Error: --target requires a CLI path or name." >&2
        echo "  review.sh --target /usr/local/bin/mycli" >&2
        exit "$CRR_EX_USAGE"
      fi
      TARGET=$2; shift 2 ;;
    --subcommands)
      SUBCOMMANDS_ARG=$2; shift 2 ;;
    --timeout)
      if [[ $# -lt 2 ]] || ! [[ $2 =~ ^[0-9]+$ ]]; then
        echo "Error: --timeout requires a positive integer (seconds)." >&2
        echo "  review.sh --target mycli --timeout 10" >&2
        exit "$CRR_EX_USAGE"
      fi
      CRR_TIMEOUT=$2; shift 2 ;;
    --format)
      FORMAT=$2; shift 2 ;;
    --json) FORMAT="json"; shift ;;
    --ndjson) FORMAT="ndjson"; shift ;;
    --include-destructive)
      INCLUDE_DESTRUCTIVE=1
      export CLI_REVIEW_INCLUDE_DESTRUCTIVE=1
      shift ;;
    --config) CONFIG_FILE=$2; shift 2 ;;
    --rule-catalog) RULE_CATALOG=$2; shift 2 ;;
    --no-color) USE_COLOR="--no-color"; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    *)
      echo "Error: unknown flag '$1'." >&2
      echo "  review.sh --help" >&2
      exit "$CRR_EX_USAGE" ;;
  esac
done

export CRR_TIMEOUT

if [[ -z "$TARGET" ]]; then
  echo "Error: --target is required." >&2
  echo "  review.sh --target /usr/local/bin/mycli" >&2
  echo "  review.sh --target gh --format json" >&2
  exit "$CRR_EX_USAGE"
fi

case "$FORMAT" in
  text|json|ndjson) ;;
  *)
    echo "Error: unknown --format '$FORMAT'. Valid values: text, json, ndjson." >&2
    exit "$CRR_EX_USAGE" ;;
esac

# ---------------------------------------------------------------------------
# Resolve target to an absolute path if it is on PATH.
# ---------------------------------------------------------------------------
if [[ ! -e "$TARGET" ]]; then
  resolved=$(command -v "$TARGET" 2>/dev/null || true)
  if [[ -n "$resolved" ]]; then
    TARGET=$resolved
  fi
fi

crr_validate_target "$TARGET" || exit $?

# ---------------------------------------------------------------------------
# Load config.json (optional) for verb lists. Falls back to defaults when
# missing - no jq dependency, plain bash arrays.
# ---------------------------------------------------------------------------
CRR_SAFE_VERBS=(list get show status describe help version config ls inspect)
CRR_DESTRUCTIVE_VERBS=(delete drop destroy remove reset purge rm del)

if [[ -f "$CONFIG_FILE" ]]; then
  # Minimal parse: look for "safe_verbs":[...] and "destructive_verbs":[...].
  safe_line=$(grep -oE '"safe_verbs":[[:space:]]*\[[^]]*\]' "$CONFIG_FILE" || true)
  if [[ -n "$safe_line" ]]; then
    stripped=${safe_line#*\[}
    stripped=${stripped%\]*}
    stripped=${stripped//\"/}
    stripped=${stripped//,/ }
    # shellcheck disable=SC2206  # intentional word split
    CRR_SAFE_VERBS=($stripped)
  fi
  bad_line=$(grep -oE '"destructive_verbs":[[:space:]]*\[[^]]*\]' "$CONFIG_FILE" || true)
  if [[ -n "$bad_line" ]]; then
    stripped=${bad_line#*\[}
    stripped=${stripped%\]*}
    stripped=${stripped//\"/}
    stripped=${stripped//,/ }
    # shellcheck disable=SC2206
    CRR_DESTRUCTIVE_VERBS=($stripped)
  fi
  timeout_line=$(grep -oE '"timeout_seconds":[[:space:]]*[0-9]+' "$CONFIG_FILE" || true)
  if [[ -n "$timeout_line" ]]; then
    CRR_TIMEOUT=${timeout_line##*:}
    CRR_TIMEOUT=${CRR_TIMEOUT// /}
    export CRR_TIMEOUT
  elif grep -qE '"timeout_seconds":' "$CONFIG_FILE"; then
    echo "Warning: 'timeout_seconds' in $CONFIG_FILE is not a positive integer - using default ${CRR_TIMEOUT}s." >&2
  fi
fi

# Warn if any verb appears in both lists - the destructive list wins,
# but this is almost always a misconfiguration worth surfacing.
for safe in "${CRR_SAFE_VERBS[@]}"; do
  for bad in "${CRR_DESTRUCTIVE_VERBS[@]}"; do
    if [[ "$safe" == "$bad" ]]; then
      echo "Warning: verb '$safe' is in both safe_verbs and destructive_verbs in $CONFIG_FILE; treating as destructive." >&2
    fi
  done
done

export CRR_SAFE_VERBS CRR_DESTRUCTIVE_VERBS

# ---------------------------------------------------------------------------
# Load rule catalog.
# ---------------------------------------------------------------------------
crr_load_catalog "$RULE_CATALOG" || exit $?

# ---------------------------------------------------------------------------
# Discover subcommands (or use the user-supplied list).
# ---------------------------------------------------------------------------
SUBCOMMANDS=()
if [[ -n "$SUBCOMMANDS_ARG" ]]; then
  IFS=',' read -r -a SUBCOMMANDS <<<"$SUBCOMMANDS_ARG"
else
  while IFS= read -r discovered; do
    [[ -n "$discovered" ]] && SUBCOMMANDS+=("$discovered")
  done < <(crr_discover_subcommands "$TARGET")
fi

# ---------------------------------------------------------------------------
# Dry-run mode: list the probes that would run, then exit 0.
# ---------------------------------------------------------------------------
if (( DRY_RUN == 1 )); then
  echo "review.sh dry-run"
  echo "  target:               $TARGET"
  echo "  timeout:              ${CRR_TIMEOUT}s"
  echo "  format:               $FORMAT"
  echo "  include-destructive:  $INCLUDE_DESTRUCTIVE"
  echo "  subcommands:          ${SUBCOMMANDS[*]:-<none discovered>}"
  echo "  probes that would run:"
  echo "    P1  non-interactive operation"
  echo "    P2  layered help"
  echo "    P3  help examples / flag summary / next steps"
  echo "    P4  actionable errors"
  echo "    P5  stderr channeling"
  echo "    P6  exit codes"
  echo "    P7  stdin / positional composition"
  echo "    P8  structured output (--json, NO_COLOR)"
  if (( INCLUDE_DESTRUCTIVE == 1 )); then
    echo "    P9  destructive safety (full, --include-destructive active)"
  else
    echo "    P9  destructive safety (help-only inspection)"
  fi
  echo "    P10 command structure"
  echo "  rule catalog:         $RULE_CATALOG"
  exit "$CRR_EX_OK"
fi

# ---------------------------------------------------------------------------
# Set up findings file and guarantee cleanup on any exit path.
# ---------------------------------------------------------------------------
CRR_FINDINGS_FILE=$(mktemp -t cli-review-runner.XXXXXX.ndjson)
export CRR_FINDINGS_FILE
trap 'rm -f "$CRR_FINDINGS_FILE"' EXIT

# ---------------------------------------------------------------------------
# Run probes in order.
# Each probe handles its own errors and never aborts the pipeline.
# ---------------------------------------------------------------------------
run_probe() {
  local name=$1
  shift
  if ! "$@"; then
    echo "Warning: $name encountered an internal error - see findings for partial results." >&2
  fi
}

run_probe "P1" probe_p1_noninteractive "$TARGET" "${SUBCOMMANDS[@]:-}"
run_probe "P2" probe_p2_help_layered   "$TARGET" "${SUBCOMMANDS[@]:-}"
run_probe "P3" probe_p3_help_examples  "$TARGET" "${SUBCOMMANDS[@]:-}"
run_probe "P4" probe_p4_errors         "$TARGET" "${SUBCOMMANDS[@]:-}"
run_probe "P5" probe_p5_stderr         "$TARGET"
run_probe "P6" probe_p6_exit_codes     "$TARGET"
run_probe "P7" probe_p7_stdin          "$TARGET" "${SUBCOMMANDS[@]:-}"
run_probe "P8" probe_p8_output         "$TARGET" "${SUBCOMMANDS[@]:-}"
run_probe "P9" probe_p9_destructive    "$TARGET" "${SUBCOMMANDS[@]:-}"
run_probe "P10" probe_p10_structure    "$TARGET" "${SUBCOMMANDS[@]:-}"

# ---------------------------------------------------------------------------
# Render.
# render.sh owns its own exit code, which we forward so the shell sees 1
# when any finding failed.
# ---------------------------------------------------------------------------
render_args=(--input "$CRR_FINDINGS_FILE" --format "$FORMAT" --target "${TARGET##*/}" --rule-catalog "$RULE_CATALOG")
if [[ -n "$USE_COLOR" ]]; then
  render_args+=("$USE_COLOR")
fi

"$RENDER_SH" "${render_args[@]}"
