#!/usr/bin/env bash
# analyze-schemas.sh — Static quality checks on MCP tool schemas
set -euo pipefail

command -v jq >/dev/null 2>&1 || {
  echo "jq not found. Install jq: https://jqlang.github.io/jq/download/"
  exit 1
}

TOOLS_FILE="${1:-}"
OUTPUT="${2:-}"

if [[ -z "$TOOLS_FILE" ]]; then
  echo "Usage: analyze-schemas.sh <tools-json> [output-file]"
  echo ""
  echo "  tools-json   Path to tools.json (output of fetch-tools.sh)"
  echo "  output-file  Write analysis to file instead of stdout"
  echo ""
  echo "Runs static quality checks against tool schemas."
  exit 1
fi

if [[ ! -f "$TOOLS_FILE" ]]; then
  echo "File not found: $TOOLS_FILE"
  exit 1
fi

# Stopwords for sibling similarity
STOPWORDS='["the","a","an","and","or","is","are","was","were","be","been","being","in","on","at","to","for","of","with","by","from","as","it","its","this","that","these","those","has","have","had","do","does","did","will","would","can","could","may","might","shall","should","not","no","but","if","then","else","when","where","which","who","what","how","all","each","every","both","few","more","most","other","some","such","than","too","very","just","also","into","over","after","before","between","under","about","up","out","off","down","only","own","same","so"]'

RESULT=$(jq --argjson stopwords "$STOPWORDS" '
# Helper: score 0-3 from value
def score_length:
  if . == null or . == "" then 0
  elif (. | length) < 20 then 1
  elif (. | length) < 50 then 2
  else 3
  end;

# Helper: check if string contains any of the patterns (case-insensitive)
def contains_any(patterns):
  . as $s | [patterns[] | select($s | ascii_downcase | test(.))] | length > 0;

# Helper: tokenize and remove stopwords
def meaningful_tokens:
  ascii_downcase | gsub("[^a-z0-9 ]"; " ") | split(" ") | map(select(length > 2)) | map(select(. as $w | $stopwords | index($w) | not));

# Tool count check
.tool_count as $count |
(if $count <= 15 then "optimal"
 elif $count <= 30 then "warning"
 else "excessive" end) as $count_grade |

# Per-tool analysis
[.tools[] | . as $tool |
  # Description checks
  ($tool.description // "") as $desc |
  ($desc | score_length) as $desc_length_score |

  # DQ-2: has action verb (does something)
  ($desc | length > 10) as $has_action |

  # DQ-3: mentions returns
  ([$desc | ascii_downcase | test("return|output|result|produce|respond|yield|give")] | .[0] // false) as $mentions_returns |

  # DQ-4: disambiguation / negation
  ([$desc | ascii_downcase | test("not |don.t|does not|instead|rather than|use .+ for|if you")] | .[0] // false) as $has_negation |

  # Description pattern score (0-3)
  ([($has_action | if . then 1 else 0 end), ($mentions_returns | if . then 1 else 0 end), ($has_negation | if . then 1 else 0 end)] | add) as $desc_pattern_score |

  # Parameter analysis
  ($tool.inputSchema.properties // {} | to_entries) as $params |
  ($params | length) as $param_count |
  (if $param_count == 0 then 3
   else
     ([$params[] | select(.value.description != null and (.value.description | length) > 0)] | length) as $described |
     (if $param_count > 0 then ($described * 100 / $param_count) else 100 end) as $pct |
     (if $pct >= 100 then 3 elif $pct >= 50 then 2 elif $pct > 0 then 1 else 0 end)
   end) as $param_desc_score |

  # Param description coverage percentage
  (if $param_count == 0 then 100
   else
     ([$params[] | select(.value.description != null and (.value.description | length) > 0)] | length) as $d |
     ($d * 100 / $param_count)
   end) as $param_desc_pct |

  # Schema specificity: params with constraints beyond base type
  (if $param_count == 0 then 3
   else
     ([$params[] | select(
       .value.enum != null or
       .value.pattern != null or
       .value.minimum != null or
       .value.maximum != null or
       .value.minLength != null or
       .value.maxLength != null or
       .value.default != null or
       .value.format != null
     )] | length) as $constrained |
     (if $param_count > 0 then ($constrained * 100 / $param_count) else 100 end) as $cpct |
     (if $cpct >= 75 then 3 elif $cpct >= 50 then 2 elif $cpct > 0 then 1 else 0 end)
   end) as $schema_spec_score |

  # Annotation coverage
  ($tool.annotations // {}) as $anns |
  ($anns | keys | length) as $ann_count |
  (if $ann_count >= 3 then 3
   elif ($anns | has("readOnlyHint") or has("destructiveHint")) then 2
   elif $ann_count >= 1 then 1
   else 0
   end) as $ann_score |

  # Overall score (average of all subscores, 0-3)
  (([$desc_length_score, $desc_pattern_score, $param_desc_score, $schema_spec_score, $ann_score] | add) / 5) as $overall |

  # Collect issues
  ([
    (if $desc_length_score < 2 then "Description too short (< 20 chars)" else empty end),
    (if $has_action | not then "Description lacks action verb" else empty end),
    (if $mentions_returns | not then "Description does not mention return value" else empty end),
    (if $has_negation | not then "Description has no disambiguation/negation" else empty end),
    (if $param_desc_score < 3 and $param_count > 0 then "Some parameters missing .describe()" else empty end),
    (if $schema_spec_score < 2 and $param_count > 0 then "Parameters lack constraints (enum, pattern, bounds)" else empty end),
    (if $ann_score == 0 then "No tool annotations set" else empty end)
  ]) as $issues |

  {
    name: $tool.name,
    description_preview: ($desc | if length > 80 then .[:80] + "..." else . end),
    scores: {
      descriptionLength: { score: $desc_length_score, chars: ($desc | length) },
      descriptionPattern: {
        score: $desc_pattern_score,
        has: ([
          (if $has_action then "action" else empty end),
          (if $mentions_returns then "returns" else empty end),
          (if $has_negation then "negation" else empty end)
        ])
      },
      paramDescribeCoverage: { score: $param_desc_score, described_pct: $param_desc_pct, param_count: $param_count },
      schemaSpecificity: { score: $schema_spec_score },
      annotationCoverage: { score: $ann_score, annotations: ($anns | keys) },
      overall: ($overall * 100 | round / 100)
    },
    issues: $issues
  }
] as $tool_results |

# Sibling similarity detection
[.tools | to_entries | . as $tools |
  $tools[] | . as $a |
  $tools[] | . as $b |
  select($a.key < $b.key) |
  ($a.value.description // "" | meaningful_tokens) as $a_tokens |
  ($b.value.description // "" | meaningful_tokens) as $b_tokens |
  ([$a_tokens[] | select(. as $t | $b_tokens | index($t) != null)]) as $shared |
  ($a_tokens | length) as $a_len |
  ($b_tokens | length) as $b_len |
  (if ($a_len + $b_len) > 0 then (($shared | length) * 2 * 100 / ($a_len + $b_len)) else 0 end) as $overlap_pct |
  select($overlap_pct > 30) |
  {
    tool1: $a.value.name,
    tool2: $b.value.name,
    shared_tokens: $shared,
    overlap_pct: ($overlap_pct | round),
    risk: (if $overlap_pct > 50 then "high" elif $overlap_pct > 30 then "medium" else "low" end)
  }
] as $sibling_pairs |

# Summary
($tool_results | map(.scores.overall) | add / length * 100 | round / 100) as $avg_score |
($tool_results | map(.issues) | add | length) as $total_issues |
([$tool_results[] | select(.issues | length > 0)] | length) as $tools_with_issues |

{
  tool_count: { count: $count, grade: $count_grade },
  tools: $tool_results,
  sibling_pairs: $sibling_pairs,
  summary: {
    avg_score: $avg_score,
    tools_with_issues: $tools_with_issues,
    total_issues: $total_issues,
    critical_issues: ([$tool_results[] | .issues[] | select(startswith("Description too short") or startswith("No tool annotations"))] | length)
  }
}
' "$TOOLS_FILE")

if [[ -n "$OUTPUT" ]]; then
  echo "$RESULT" > "$OUTPUT"
  echo "Analysis saved to $OUTPUT" >&2
else
  echo "$RESULT"
fi

# Summary to stderr
TOOL_COUNT=$(echo "$RESULT" | jq '.tool_count.count')
AVG_SCORE=$(echo "$RESULT" | jq '.summary.avg_score')
ISSUES=$(echo "$RESULT" | jq '.summary.total_issues')
SIBLINGS=$(echo "$RESULT" | jq '.sibling_pairs | length')

echo "" >&2
echo "Analyzed $TOOL_COUNT tools. Average quality score: $AVG_SCORE/3.0" >&2
echo "Issues found: $ISSUES | Sibling pairs: $SIBLINGS" >&2

if [[ "$ISSUES" -gt 0 ]]; then
  echo "" >&2
  echo "Top issues:" >&2
  echo "$RESULT" | jq -r '.tools[] | select(.issues | length > 0) | "  \(.name): \(.issues | join(", "))"' >&2
fi
