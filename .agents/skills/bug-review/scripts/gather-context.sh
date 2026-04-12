#!/usr/bin/env bash
# gather-context.sh — Priority-based context gathering for code review
# Part of: bug-review
# Purpose: Intelligently gather surrounding code context for review passes.
#          Prioritizes callers, types, and tests of modified functions.
#
# Usage: $0 <changed-files-json> [max-files]
#   changed-files-json: JSON array of file paths or gh pr files output
#   max-files: max context files beyond changed files (default: 15)
#
# Output: JSON with {files: [{path, relevance, reason}]}
# Exit codes: 0 = success, 1 = error
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <changed-files-json> [max-files]" >&2
  echo "  changed-files-json: JSON file with array of {path} objects or string paths" >&2
  exit 1
fi

FILES_JSON="$1"
MAX_FILES="${2:-15}"
BUDGET="$MAX_FILES"

if [[ ! -f "$FILES_JSON" ]]; then
  echo "Error: File not found: $FILES_JSON" >&2
  exit 1
fi

# Extract file paths from JSON (handles both [{path:"x"}] and ["x"] formats)
CHANGED_FILES=$(jq -r '
  if type == "array" then
    .[] | if type == "object" then .path else . end
  else empty end
' "$FILES_JSON" 2>/dev/null)

if [[ -z "$CHANGED_FILES" ]]; then
  echo '{"files":[],"stats":{"changed":0,"callers":0,"types":0,"tests":0,"total":0}}'
  exit 0
fi

# Output accumulator
CONTEXT_FILES="[]"
CALLER_COUNT=0
TYPE_COUNT=0
TEST_COUNT=0

# Skip patterns
SKIP_PATTERN="node_modules/|vendor/|\.generated\.|dist/|build/|\.min\.|__pycache__"

# --- Priority 1: Extract modified function names from changed files ---
MODIFIED_FUNCTIONS=""
while IFS= read -r file; do
  [[ -f "$file" ]] || continue

  # Extract function/method names using common patterns
  # Handles: function foo, const foo =, export function foo, def foo, func foo
  FUNCS=$(grep -nE '(function\s+\w+|const\s+\w+\s*=\s*(async\s+)?\(|export\s+(async\s+)?function\s+\w+|def\s+\w+|func\s+\w+)' "$file" 2>/dev/null | \
    sed -E 's/.*function\s+(\w+).*/\1/; s/.*const\s+(\w+).*/\1/; s/.*def\s+(\w+).*/\1/; s/.*func\s+(\w+).*/\1/' | \
    sort -u || true)

  if [[ -n "$FUNCS" ]]; then
    MODIFIED_FUNCTIONS="$MODIFIED_FUNCTIONS"$'\n'"$FUNCS"
  fi
done <<< "$CHANGED_FILES"

MODIFIED_FUNCTIONS=$(echo "$MODIFIED_FUNCTIONS" | sort -u | grep -v '^$' || true)

# --- Priority 2: Find callers of modified functions (up to 5) ---
if [[ -n "$MODIFIED_FUNCTIONS" && $BUDGET -gt 0 ]]; then
  CALLER_LIMIT=$((BUDGET < 5 ? BUDGET : 5))

  while IFS= read -r func; do
    [[ $CALLER_COUNT -ge $CALLER_LIMIT ]] && break
    [[ -z "$func" ]] && continue

    # Search for callers, excluding changed files themselves and skip patterns
    CALLERS=$(grep -rlE "\b${func}\b" --include="*.ts" --include="*.js" --include="*.tsx" --include="*.jsx" --include="*.py" --include="*.go" --include="*.rs" --include="*.java" . 2>/dev/null | \
      grep -vE "$SKIP_PATTERN" | \
      while IFS= read -r caller; do
        # Exclude the changed files themselves
        IS_CHANGED=false
        while IFS= read -r cf; do
          [[ "$caller" == "./$cf" || "$caller" == "$cf" ]] && IS_CHANGED=true
        done <<< "$CHANGED_FILES"
        $IS_CHANGED || echo "$caller"
      done | head -"$CALLER_LIMIT" || true)

    while IFS= read -r caller; do
      [[ -z "$caller" ]] && continue
      [[ $CALLER_COUNT -ge $CALLER_LIMIT ]] && break

      CONTEXT_FILES=$(echo "$CONTEXT_FILES" | jq --arg path "$caller" --arg reason "Calls $func" \
        '. + [{"path": $path, "relevance": "caller", "reason": $reason}]')
      ((CALLER_COUNT++))
      ((BUDGET--))
    done <<< "$CALLERS"
  done <<< "$MODIFIED_FUNCTIONS"
fi

# --- Priority 3: Find type definitions imported by changed files (up to 3) ---
if [[ $BUDGET -gt 0 ]]; then
  TYPE_LIMIT=$((BUDGET < 3 ? BUDGET : 3))

  while IFS= read -r file; do
    [[ $TYPE_COUNT -ge $TYPE_LIMIT ]] && break
    [[ -f "$file" ]] || continue

    # Extract import paths (handles: import {X} from './path', from path import X)
    IMPORTS=$(grep -oE "(from\s+['\"]\.?\.?/[^'\"]+['\"]|import\s+['\"]\.?\.?/[^'\"]+['\"])" "$file" 2>/dev/null | \
      sed -E "s/(from|import)\s+['\"]//; s/['\"]$//" | \
      grep -vE "$SKIP_PATTERN" || true)

    while IFS= read -r imp; do
      [[ -z "$imp" ]] && continue
      [[ $TYPE_COUNT -ge $TYPE_LIMIT ]] && break

      # Resolve relative import to a file path
      DIR=$(dirname "$file")
      for ext in "" ".ts" ".tsx" ".js" ".jsx" "/index.ts" "/index.js"; do
        RESOLVED="${DIR}/${imp}${ext}"
        if [[ -f "$RESOLVED" ]]; then
          # Check if it contains type definitions
          if grep -qE "(interface\s|type\s|enum\s|class\s)" "$RESOLVED" 2>/dev/null; then
            CONTEXT_FILES=$(echo "$CONTEXT_FILES" | jq --arg path "$RESOLVED" --arg reason "Types imported by $file" \
              '. + [{"path": $path, "relevance": "type-definition", "reason": $reason}]')
            ((TYPE_COUNT++))
            ((BUDGET--))
          fi
          break
        fi
      done
    done <<< "$IMPORTS"
  done <<< "$CHANGED_FILES"
fi

# --- Priority 4: Find test files for changed modules (up to 3) ---
if [[ $BUDGET -gt 0 ]]; then
  TEST_LIMIT=$((BUDGET < 3 ? BUDGET : 3))

  while IFS= read -r file; do
    [[ $TEST_COUNT -ge $TEST_LIMIT ]] && break
    [[ -f "$file" ]] || continue

    BASENAME=$(basename "$file" | sed -E 's/\.[^.]+$//')
    DIR=$(dirname "$file")

    # Search for test files matching the changed file name
    for pattern in "${DIR}/${BASENAME}.test."* "${DIR}/${BASENAME}.spec."* "${DIR}/__tests__/${BASENAME}."* "${DIR}/${BASENAME}_test."*; do
      [[ $TEST_COUNT -ge $TEST_LIMIT ]] && break

      for testfile in $pattern; do
        [[ -f "$testfile" ]] || continue
        CONTEXT_FILES=$(echo "$CONTEXT_FILES" | jq --arg path "$testfile" --arg reason "Tests for $file" \
          '. + [{"path": $path, "relevance": "test", "reason": $reason}]')
        ((TEST_COUNT++))
        ((BUDGET--))
        break
      done
    done
  done <<< "$CHANGED_FILES"
fi

# --- Priority 5: Check for .bug-review.md ---
if [[ -f ".bug-review.md" && $BUDGET -gt 0 ]]; then
  CONTEXT_FILES=$(echo "$CONTEXT_FILES" | jq \
    '. + [{"path": ".bug-review.md", "relevance": "repo-rules", "reason": "Repository-specific review rules"}]')
  ((BUDGET--))
fi

# Deduplicate by path
CONTEXT_FILES=$(echo "$CONTEXT_FILES" | jq 'unique_by(.path)')

CHANGED_COUNT=$(echo "$CHANGED_FILES" | wc -l | tr -d ' ')
TOTAL=$(echo "$CONTEXT_FILES" | jq 'length')

# Output final JSON
jq -n \
  --argjson files "$CONTEXT_FILES" \
  --arg changed "$CHANGED_COUNT" \
  --arg callers "$CALLER_COUNT" \
  --arg types "$TYPE_COUNT" \
  --arg tests "$TEST_COUNT" \
  --argjson total "$TOTAL" \
  '{
    files: $files,
    stats: {
      changed_files: ($changed | tonumber),
      callers_found: ($callers | tonumber),
      type_defs_found: ($types | tonumber),
      test_files_found: ($tests | tonumber),
      total_context_files: $total
    }
  }'
