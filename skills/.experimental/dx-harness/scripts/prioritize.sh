#!/usr/bin/env bash
# prioritize.sh — score and rank audit findings
# Part of: dx-harness
#
# Reads dx-audit.json, computes score = (frequency × pain) / max(fix_cost,1),
# normalizes 0-100, sorts descending, writes ranked JSON to stdout.
#
# Usage:
#   bash prioritize.sh <audit-json>
#   bash prioritize.sh /tmp/audit.json > /tmp/ranked.json

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/lib/common.sh"

require_jq

[[ $# -eq 1 ]] || die "Usage: $0 <audit-json>"
[[ -f "$1" ]] || die "Audit file not found: $1  (run scripts/audit.sh first)"

jq '
  .findings as $f
  | ($f | map((.frequency_score * .pain_score) / ([.fix_cost_score,1] | max))) as $raw
  | ($raw | max // 1) as $maxRaw
  | .findings = ($f
      | to_entries
      | map(.value + {score: (($raw[.key] / $maxRaw) * 100 | round)})
      | sort_by(-.score)
    )
  | .ranked_at = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))
' "$1"
