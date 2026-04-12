#!/usr/bin/env bash
# selftest.sh - self-test for cli-review-runner.
#
# Generates a tiny mock CLI that intentionally violates specific rules,
# runs review.sh against it, and asserts that the probes detect the
# expected pass/fail pattern. Treat this as the sanity check to run
# before shipping changes to probes.sh.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REVIEW_SH="$SCRIPT_DIR/review.sh"

WORKDIR=$(mktemp -d -t cli-review-runner-selftest.XXXXXX)
trap 'rm -rf "$WORKDIR"' EXIT

MOCK_CLI="$WORKDIR/mockcli"

# ---------------------------------------------------------------------------
# Mock CLI. Designed to deliberately violate:
#   help-examples-in-help             (no Examples section in any --help)
#   err-stderr-not-stdout             (error message on stdout instead of stderr)
#   err-non-zero-exit-codes           (exits 1 for everything non-zero)
#   err-exit-fast-on-missing-required (silently accepts unknown flags on list/show)
#   output-json-flag                  (no --json flag at all)
#
# And to deliberately pass:
#   interact-no-hang-on-stdin   (returns immediately under </dev/null)
#   help-no-flag-required       (prints usage when invoked with zero args)
#   struct-standard-flag-names  (advertises --help and --version)
# ---------------------------------------------------------------------------
cat >"$MOCK_CLI" <<'MOCK_EOF'
#!/usr/bin/env bash
set -euo pipefail

# Bare usage - no Examples section, no --json, errors on stdout.
print_usage() {
  cat <<USAGE
Usage: mockcli [options] <command>

Commands:
  list    show items
  show    show detail

Options:
  --help     show this help
  --version  show version
USAGE
}

case "${1:-}" in
  "") print_usage; exit 0 ;;
  --help|-h) print_usage; exit 0 ;;
  --version) echo "mockcli 0.0.1"; exit 0 ;;
  list) echo "item1"; echo "item2"; exit 0 ;;
  show) echo "detail"; exit 0 ;;
  *)
    # Violation: error on stdout, exit 1 (not distinct from runtime failure).
    echo "error: unknown argument '$1'"
    exit 1 ;;
esac
MOCK_EOF
chmod +x "$MOCK_CLI"

# ---------------------------------------------------------------------------
# Run review.sh with NDJSON output so we can parse it deterministically.
# We also pass explicit --subcommands so the test is not dependent on
# subcommand discovery (which uses a heuristic).
# ---------------------------------------------------------------------------
FINDINGS="$WORKDIR/findings.ndjson"
set +e
"$REVIEW_SH" --target "$MOCK_CLI" --subcommands list,show --format ndjson >"$FINDINGS"
review_rc=$?
set -e

if [[ ! -s "$FINDINGS" ]]; then
  echo "FAIL: review.sh produced no findings (rc=$review_rc)" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Parse NDJSON via awk and assert expected pass/fail for specific rule IDs.
# ---------------------------------------------------------------------------
lookup_pass() {
  local rule_id=$1
  awk -v rid="$rule_id" '
    {
      # Find "rule_id":"..." and "pass":true|false on the same line.
      if (match($0, "\"rule_id\":\"" rid "\"")) {
        if (match($0, /"pass":true/))  { print "true";  exit }
        if (match($0, /"pass":false/)) { print "false"; exit }
      }
    }
  ' "$FINDINGS"
}

PASS=0
FAIL=0

expect() {
  local label=$1 rule_id=$2 expected=$3
  local actual
  actual=$(lookup_pass "$rule_id")
  if [[ -z "$actual" ]]; then
    echo "  FAIL: $label - rule '$rule_id' not found in findings" >&2
    (( FAIL++ )) || true
    return
  fi
  if [[ "$actual" == "$expected" ]]; then
    echo "  PASS: $label"
    (( PASS++ )) || true
  else
    echo "  FAIL: $label - expected pass=$expected, got pass=$actual" >&2
    (( FAIL++ )) || true
  fi
}

echo "Running cli-review-runner selftest against mockcli..."

# Rules that the mock deliberately passes.
expect "interact-no-hang-on-stdin PASS"      "interact-no-hang-on-stdin"        "true"
expect "help-no-flag-required PASS"          "help-no-flag-required"            "true"
expect "struct-standard-flag-names PASS"     "struct-standard-flag-names"       "true"

# Rules that the mock deliberately fails.
expect "help-examples-in-help FAIL"              "help-examples-in-help"              "false"
expect "err-stderr-not-stdout FAIL"              "err-stderr-not-stdout"              "false"
expect "err-non-zero-exit-codes FAIL"            "err-non-zero-exit-codes"            "false"
expect "output-json-flag FAIL"                   "output-json-flag"                   "false"
expect "err-exit-fast-on-missing-required FAIL"  "err-exit-fast-on-missing-required"  "false"

echo ""
echo "Results: $PASS passed, $FAIL failed"
if (( FAIL > 0 )); then
  echo ""
  echo "Findings file preserved at: $FINDINGS" >&2
  echo "(re-run with 'bash -x $0' for probe tracing)" >&2
  trap - EXIT  # keep workdir for inspection
  exit 1
fi
exit 0
