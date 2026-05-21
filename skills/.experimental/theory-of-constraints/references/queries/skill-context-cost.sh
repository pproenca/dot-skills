#!/usr/bin/env bash
# skill-context-cost.sh — Find the constraint inside an Agent Skill: its context budget.
#
# Theory of Constraints applied to an Agent Skill: the scarce resource is the
# agent's context window. Content that is ALWAYS loaded (SKILL.md body + its
# frontmatter description, plus AGENTS.md if present) is paid on every trigger,
# whether or not it is used — that always-loaded budget is the usual constraint.
# On-demand references cost nothing until read (progressive disclosure), so a
# skill EXPLOITS its constraint by keeping the entry point lean and pushing
# detail into references/.
#
# This script measures lines and approximate tokens (bytes / 4) for the
# always-loaded surface vs each on-demand reference, and flags an over-budget
# entry point.
#
# Usage:
#   skill-context-cost.sh <skill-dir>
#
# Parameters:
#   <skill-dir>   Path to a skill directory containing SKILL.md (and optionally
#                 AGENTS.md and references/). Required.
#
# Example:
#   skill-context-cost.sh skills/.experimental/theory-of-constraints
#
# Expected output:
#   ALWAYS-LOADED (paid every trigger)        LINES   ~TOKENS
#   SKILL.md                                     180      1100
#   AGENTS.md                                     90       540
#   always-loaded total                          270      1640
#
#   ON-DEMAND references/ (paid only when read)  LINES   ~TOKENS
#   find-the-constraint-tree.md                  120       760
#   ...
#
#   VERDICT: <ok | constraint = context budget>
#
# A skill whose SKILL.md exceeds ~500 lines, or whose always-loaded total dwarfs
# its on-demand references, is constrained by its context budget. EXPLOIT: move
# detail into references/, leave a navigational entry point. See
# find-the-constraint-tree.md (Agent Skill branch) and dev-skill:evolve.
set -euo pipefail

DIR="${1:-}"
if [[ -z "$DIR" ]]; then
  echo "error: provide a skill directory." >&2
  echo "usage: $0 <skill-dir>" >&2
  exit 1
fi
if [[ ! -d "$DIR" ]]; then
  echo "error: '$DIR' is not a directory." >&2
  exit 1
fi
if [[ ! -f "$DIR/SKILL.md" ]]; then
  echo "error: '$DIR' has no SKILL.md — is this a skill directory?" >&2
  exit 1
fi

# Print "lines tokens" for a file (tokens approximated as bytes / 4).
_cost() {
  local f="$1"
  local lines bytes
  lines="$(grep -c '' "$f" 2>/dev/null || echo 0)"
  bytes="$(wc -c < "$f" 2>/dev/null | tr -d ' ' || echo 0)"
  echo "$lines $((bytes / 4))"
}

always_lines=0
always_tokens=0
skill_lines=0

printf '%-42s %7s %9s\n' "ALWAYS-LOADED (paid every trigger)" "LINES" "~TOKENS"
for f in "$DIR/SKILL.md" "$DIR/AGENTS.md"; do
  [[ -f "$f" ]] || continue
  read -r l t <<< "$(_cost "$f")"
  printf '%-42s %7s %9s\n' "$(basename "$f")" "$l" "$t"
  always_lines=$((always_lines + l))
  always_tokens=$((always_tokens + t))
  [[ "$(basename "$f")" == "SKILL.md" ]] && skill_lines="$l"
done
printf '%-42s %7s %9s\n' "always-loaded total" "$always_lines" "$always_tokens"
echo ""

ondemand_tokens=0
ref_count=0
if [[ -d "$DIR/references" ]]; then
  printf '%-42s %7s %9s\n' "ON-DEMAND references/ (paid when read)" "LINES" "~TOKENS"
  # Largest references first.
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    read -r l t <<< "$(_cost "$f")"
    name="${f#"$DIR"/references/}"
    printf '%-42s %7s %9s\n' "$name" "$l" "$t"
    ondemand_tokens=$((ondemand_tokens + t))
    ref_count=$((ref_count + 1))
  done <<< "$(find "$DIR/references" -type f \( -name '*.md' -o -name '*.sh' -o -name '*.py' -o -name '*.sql' \) | sort)"
  echo ""
fi

echo "always-loaded ~tokens: $always_tokens   |   on-demand ~tokens: $ondemand_tokens (across $ref_count files)"
echo ""

verdict="ok — entry point is lean; context budget is not the constraint"
if [[ "$skill_lines" -gt 500 ]]; then
  verdict="CONSTRAINT = context budget — SKILL.md is ${skill_lines} lines (>500). EXPLOIT: move detail into references/."
elif [[ "$ondemand_tokens" -gt 0 && "$always_tokens" -gt "$ondemand_tokens" ]]; then
  verdict="CONSTRAINT = context budget — always-loaded (~$always_tokens tok) exceeds on-demand (~$ondemand_tokens tok). EXPLOIT: shift detail to references/."
fi
echo "VERDICT: $verdict"
