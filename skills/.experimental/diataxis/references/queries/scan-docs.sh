#!/usr/bin/env bash
# scan-docs.sh — Diátaxis triage scan for a documentation set.
#
# Part of: diataxis (runbook). This is a TRIAGE aid, NOT a classifier. It cannot
# decide which mode a page belongs to — that needs the compass and human/agent
# judgement (see references/compass-tree.md). What it does is cheap and deterministic:
# list every markdown file and grep for the tell-tale signals of each of the four
# modes, so that on a large corpus you know WHICH pages to run the compass on first.
# A page showing signals of two or more modes is a candidate for type-mixing.
#
# Usage:
#   bash scan-docs.sh <docs_root> [name_glob]
#
# Parameters:
#   docs_root  (required) Directory to scan recursively. e.g. "docs/" or "./website".
#   name_glob  (optional) find -name pattern for files to scan. Default: "*.md".
#
# Output (one row per file, then a summary):
#   FLAGS  LINES  FILE
#   where FLAGS is 4 chars [t h r e] — a letter is shown if that mode's signal is
#   present, a dot if absent:
#     t = tutorial signal   (we'll / let's / "you should see" / "notice that")
#     h = how-to signal     ("Step N" / "this guide shows you" / "how to " / 2+ numbered list lines)
#     r = reference signal  (markdown tables / "Parameters" / "Options" / "Default:")
#     e = explanation signal(because / "the reason" / historically / trade-off / "## Why")
#   A row with 2+ letters is marked "MIX? -> run compass". 0 letters = "no strong signal".
#
# Exit codes: 0 = scan completed (mixes may still be reported), 1 = bad usage / no dir.
# Scans LOCAL files only — for remote docs, fetch or clone them locally first.
# Notes: heuristic — expect false positives (a how-to may legitimately link a table;
# a reference's enumerated list of 2+ numbered lines may still trip the h flag).
# Treat every "MIX?" as a candidate to inspect, not a verdict.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: bash scan-docs.sh <docs_root> [name_glob]" >&2
  echo "  e.g. bash scan-docs.sh docs/ '*.md'" >&2
  exit 1
fi

ROOT="$1"
GLOB="${2:-*.md}"

if [[ ! -d "$ROOT" ]]; then
  echo "Error: '$ROOT' is not a directory. Pass the root of the docs to scan." >&2
  echo "If you don't know it, set docs_root in config.json or ask the user." >&2
  exit 1
fi

# Signal patterns (case-insensitive, extended regex).
P_TUT="(we'll|we are going to|let'?s |you should see|notice that|in this tutorial)"
P_HOW="((^|[^[:alpha:]])step [0-9]|this guide shows you|how to )"
P_STEPLIST="^[[:space:]]*[0-9]+\."   # ordered-list line; needs 2+ to count as how-to
P_REF="(^\||\| *-+ *\||\bparameters?\b|\boptions?\b|\bdefault:|\breturns?\b|\bsignature\b)"
P_EXP="(\bbecause\b|the reason|historically|trade-?off|^#+.*\bwhy\b|\bdesign decision)"

total=0; mix=0; none=0

has() { # has <pattern> <file> -> echoes 1 or 0 (never trips set -e)
  if grep -qiE "$1" "$2" 2>/dev/null; then echo 1; else echo 0; fi
}

printf '%-6s %6s  %s\n' "FLAGS" "LINES" "FILE"
printf '%-6s %6s  %s\n' "-----" "-----" "----"

# -print0 / read -d '' keeps paths with spaces intact.
while IFS= read -r -d '' f; do
  total=$((total + 1))
  lines=$(wc -l < "$f" | tr -d ' ')
  t=$(has "$P_TUT" "$f")
  if [[ "$(has "$P_HOW" "$f")" == 1 ]]; then
    h=1
  else
    # require 2+ numbered list lines so a lone "1." doesn't flag as how-to
    olc=$(grep -cE "$P_STEPLIST" "$f" 2>/dev/null || true)
    if [[ "${olc:-0}" -ge 2 ]]; then h=1; else h=0; fi
  fi
  r=$(has "$P_REF" "$f"); e=$(has "$P_EXP" "$f")
  flags=""
  [[ "$t" == 1 ]] && flags="${flags}t" || flags="${flags}."
  [[ "$h" == 1 ]] && flags="${flags}h" || flags="${flags}."
  [[ "$r" == 1 ]] && flags="${flags}r" || flags="${flags}."
  [[ "$e" == 1 ]] && flags="${flags}e" || flags="${flags}."
  count=$((t + h + r + e))
  note=""
  if [[ "$count" -ge 2 ]]; then note="  MIX? -> run compass"; mix=$((mix + 1)); fi
  if [[ "$count" -eq 0 ]]; then note="  no strong signal"; none=$((none + 1)); fi
  printf '%-6s %6s  %s%s\n' "$flags" "$lines" "$f" "$note"
done < <(find "$ROOT" -type f -name "$GLOB" -print0 | sort -z)

echo ""
echo "Scanned $total file(s): $mix candidate type-mix, $none with no strong mode signal."
echo "Next: open compass-tree.md and classify each MIX? page; split with wrong-type-tree.md."
