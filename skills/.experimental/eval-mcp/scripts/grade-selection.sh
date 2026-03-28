#!/usr/bin/env bash
# grade-selection.sh — Compare actual vs expected tool selections, build confusion matrix
set -euo pipefail

command -v jq >/dev/null 2>&1 || {
  echo "jq not found. Install jq: https://jqlang.github.io/jq/download/"
  exit 1
}

RESULTS_DIR="${1:-}"
EVALS_FILE="${2:-}"
OUTPUT="${3:-}"

if [[ -z "$RESULTS_DIR" ]] || [[ -z "$EVALS_FILE" ]]; then
  echo "Usage: grade-selection.sh <results-dir> <evals-json> [output-file]"
  echo ""
  echo "  results-dir  Directory containing intent-N/result.json files"
  echo "  evals-json   Path to evals.json with expected tool selections"
  echo "  output-file  Write grading JSON to file instead of stdout"
  echo ""
  echo "Compares actual tool selections against expected, builds confusion matrix."
  exit 1
fi

if [[ ! -d "$RESULTS_DIR" ]]; then
  echo "Results directory not found: $RESULTS_DIR"
  exit 1
fi

if [[ ! -f "$EVALS_FILE" ]]; then
  echo "Evals file not found: $EVALS_FILE"
  exit 1
fi

CORRECT=0
WRONG_TOOL=0
FALSE_ACCEPT=0
FALSE_REJECT=0
TOTAL=0
GRADES="[]"
CONFUSION="{}"

# Iterate over each intent in evals.json
INTENT_COUNT=$(jq '.intents | length' "$EVALS_FILE")

for ((i = 0; i < INTENT_COUNT; i++)); do
  INTENT_ID=$(jq -r ".intents[$i].id" "$EVALS_FILE")
  EXPECTED=$(jq -r ".intents[$i].expected_tool" "$EVALS_FILE")
  INTENT_TEXT=$(jq -r ".intents[$i].intent" "$EVALS_FILE")
  INTENT_TYPE=$(jq -r ".intents[$i].type" "$EVALS_FILE")

  RESULT_FILE="$RESULTS_DIR/intent-${INTENT_ID}/result.json"

  if [[ ! -f "$RESULT_FILE" ]]; then
    echo "Warning: Missing result for intent $INTENT_ID, skipping" >&2
    continue
  fi

  ACTUAL=$(jq -r '.selected_tool // "null"' "$RESULT_FILE")
  [[ "$ACTUAL" == "null" ]] && ACTUAL="none"
  [[ "$EXPECTED" == "null" ]] && EXPECTED="none"

  TOTAL=$((TOTAL + 1))

  # Classify the result
  if [[ "$ACTUAL" == "$EXPECTED" ]]; then
    VERDICT="correct"
    PASS=true
    CORRECT=$((CORRECT + 1))
  elif [[ "$EXPECTED" == "none" ]] && [[ "$ACTUAL" != "none" ]]; then
    VERDICT="false_accept"
    PASS=false
    FALSE_ACCEPT=$((FALSE_ACCEPT + 1))
  elif [[ "$EXPECTED" != "none" ]] && [[ "$ACTUAL" == "none" ]]; then
    VERDICT="false_reject"
    PASS=false
    FALSE_REJECT=$((FALSE_REJECT + 1))
  else
    VERDICT="wrong_tool"
    PASS=false
    WRONG_TOOL=$((WRONG_TOOL + 1))
  fi

  # Add to grades array
  GRADE=$(jq -n \
    --argjson id "$INTENT_ID" \
    --arg intent "$INTENT_TEXT" \
    --arg expected "$EXPECTED" \
    --arg actual "$ACTUAL" \
    --arg verdict "$VERDICT" \
    --argjson pass "$PASS" \
    --arg type "$INTENT_TYPE" \
    '{intent_id: $id, intent: $intent, expected: $expected, actual: $actual, verdict: $verdict, pass: $pass, type: $type}')
  GRADES=$(echo "$GRADES" | jq --argjson g "$GRADE" '. + [$g]')

  # Update confusion matrix
  CONFUSION=$(echo "$CONFUSION" | jq \
    --arg exp "$EXPECTED" \
    --arg act "$ACTUAL" \
    '.[$exp] = ((.[$exp] // {}) | .[$act] = ((.[$act] // 0) + 1))')
done

# Compute per-tool precision and recall
TOOL_NAMES=$(jq -r '.intents[].expected_tool // "none"' "$EVALS_FILE" | sort -u)
PER_TOOL="{}"

for TOOL in $TOOL_NAMES; do
  [[ "$TOOL" == "null" ]] && TOOL="none"

  # Recall: correct for this tool / times this tool was expected
  EXPECTED_COUNT=$(echo "$GRADES" | jq --arg t "$TOOL" '[.[] | select(.expected == $t)] | length')
  CORRECT_FOR_TOOL=$(echo "$GRADES" | jq --arg t "$TOOL" '[.[] | select(.expected == $t and .pass == true)] | length')

  # Precision: correct for this tool / times this tool was selected
  SELECTED_COUNT=$(echo "$GRADES" | jq --arg t "$TOOL" '[.[] | select(.actual == $t)] | length')
  CORRECT_SELECTED=$(echo "$GRADES" | jq --arg t "$TOOL" '[.[] | select(.actual == $t and .expected == $t)] | length')

  if [[ "$EXPECTED_COUNT" -gt 0 ]]; then
    RECALL=$(echo "scale=3; $CORRECT_FOR_TOOL / $EXPECTED_COUNT" | bc)
  else
    RECALL="1.000"
  fi

  if [[ "$SELECTED_COUNT" -gt 0 ]]; then
    PRECISION=$(echo "scale=3; $CORRECT_SELECTED / $SELECTED_COUNT" | bc)
  else
    PRECISION="1.000"
  fi

  PER_TOOL=$(echo "$PER_TOOL" | jq \
    --arg tool "$TOOL" \
    --argjson prec "$PRECISION" \
    --argjson rec "$RECALL" \
    --argjson exp "$EXPECTED_COUNT" \
    --argjson sel "$SELECTED_COUNT" \
    '.[$tool] = {precision: $prec, recall: $rec, expected_count: $exp, selected_count: $sel}')
done

# Find worst confusions (wrong_tool pairs sorted by count)
WORST=$(echo "$GRADES" | jq '[.[] | select(.verdict == "wrong_tool")] | group_by([.expected, .actual]) | map({expected: .[0].expected, actual: .[0].actual, count: length}) | sort_by(-.count)')

# Compute accuracy
if [[ "$TOTAL" -gt 0 ]]; then
  ACCURACY=$(echo "scale=3; $CORRECT / $TOTAL" | bc)
else
  ACCURACY="0.000"
fi

# Build final output
RESULT=$(jq -n \
  --argjson accuracy "$ACCURACY" \
  --argjson total "$TOTAL" \
  --argjson correct "$CORRECT" \
  --argjson wrong_tool "$WRONG_TOOL" \
  --argjson false_accept "$FALSE_ACCEPT" \
  --argjson false_reject "$FALSE_REJECT" \
  --argjson grades "$GRADES" \
  --argjson confusion "$CONFUSION" \
  --argjson per_tool "$PER_TOOL" \
  --argjson worst "$WORST" \
  '{
    accuracy: $accuracy,
    total: $total,
    correct: $correct,
    wrong_tool: $wrong_tool,
    false_accept: $false_accept,
    false_reject: $false_reject,
    per_tool: $per_tool,
    confusion_matrix: $confusion,
    worst_confusions: $worst,
    grades: $grades
  }')

if [[ -n "$OUTPUT" ]]; then
  echo "$RESULT" > "$OUTPUT"
  echo "Grading saved to $OUTPUT" >&2
else
  echo "$RESULT"
fi

# Summary to stderr
echo "" >&2
echo "Selection accuracy: ${ACCURACY} ($CORRECT/$TOTAL correct)" >&2
echo "  Wrong tool: $WRONG_TOOL | False accept: $FALSE_ACCEPT | False reject: $FALSE_REJECT" >&2

if [[ $(echo "$WORST" | jq 'length') -gt 0 ]]; then
  echo "" >&2
  echo "Worst confusions:" >&2
  echo "$WORST" | jq -r '.[:3][] | "  \(.expected) → \(.actual) (\(.count)x)"' >&2
fi

[[ "$CORRECT" -eq "$TOTAL" ]] && exit 0 || exit 1
