#!/usr/bin/env bash
# detect-fast.sh — Ripgrep-based detectors for patterns visible at the line level.
# Part of: react-hook-form-audit
# Implements: rule 5 (non-use-client), rule 11 (onChange mode), rule 14 (reValidateMode: onBlur)
# Output: JSON array of findings on stdout

set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <project-root> <files-json>" >&2
  exit 2
fi
PROJECT_ROOT="$1"
FILES_JSON="$2"

cd "$PROJECT_ROOT"

# Build a temporary "filter to candidate files" list for rg.
FILE_LIST="$(mktemp -t rhf-audit-flist.XXXXXX)"
trap 'rm -f "$FILE_LIST"' EXIT
jq -r '.[]' "$FILES_JSON" > "$FILE_LIST"

# Empty-array shortcut.
if [[ ! -s "$FILE_LIST" ]]; then
  echo "[]"
  exit 0
fi

# emit_findings runs ripgrep with JSON output and converts to our finding shape.
# Args: <rule-id> <severity> <message> <pattern>
emit_findings() {
  local rule="$1" severity="$2" message="$3" pattern="$4"
  # rg --json emits one JSON object per match line.
  # rg exits 1 when there are no matches; tolerate that with `|| true`.
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    (rg --json -nP "$pattern" "$file" 2>/dev/null || true) | \
      jq -c --arg rule "$rule" --arg severity "$severity" --arg message "$message" '
        select(.type == "match")
        | {
            rule: $rule,
            severity: $severity,
            message: $message,
            file: .data.path.text,
            line: .data.line_number,
            column: ((.data.submatches[0].start // 0) + 1),
            snippet: (.data.lines.text | rtrimstr("\n"))
          }
      '
  done < "$FILE_LIST"
}

# --- Rule 5: RHF imported in non-"use client" file (Next.js App Router) ---
# Detect any candidate file whose first 5 non-empty lines do NOT include "use client".
# This is best-effort — Pages Router files don't need "use client", so the report
# should call this out as a heuristic that matters only for App Router.
rule_use_client() {
  local file
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    # Look only at the first 10 lines for the directive.
    if ! head -n 10 "$file" 2>/dev/null | rg -q "^[[:space:]]*['\"]use client['\"]"; then
      # Emit a synthetic finding pointing at line 1.
      jq -nc --arg file "$file" --arg rule "rhf-audit-05-non-use-client" --arg severity "CRITICAL" \
        --arg message "File imports react-hook-form but is missing \"use client\" directive. RHF hooks only work in client components." \
        --arg snippet "$(head -n 1 "$file" 2>/dev/null || echo '')" \
        '{
          rule: $rule, severity: $severity, message: $message,
          file: $file, line: 1, column: 1, snippet: $snippet
        }'
    fi
  done < "$FILE_LIST"
}

{
  rule_use_client

  emit_findings \
    "rhf-audit-11-onchange-mode" \
    "MEDIUM" \
    "useForm uses mode: 'onChange' — re-validates on every keystroke. Confirm real-time feedback is genuinely needed; consider 'onSubmit' or 'onBlur' otherwise." \
    "mode:\s*['\"]onChange['\"]"

  emit_findings \
    "rhf-audit-14-revalidate-onblur" \
    "LOW" \
    "reValidateMode: 'onBlur' overrides the recommended default. Verify the form has expensive validation that justifies switching from onChange." \
    "reValidateMode:\s*['\"]onBlur['\"]"
} | jq -s .
