---
title: Test Skills with Edge Case Inputs
impact: MEDIUM
impactDescription: prevents failures in production scenarios
tags: test, edge-cases, validation, robustness
---

## Test Skills with Edge Case Inputs

Test skills with unusual but valid inputs: empty files, very large files, special characters, unicode, missing optional data. Edge cases expose instruction gaps that cause production failures.

**Incorrect (only happy path tested):**

```markdown
# CSV Parser - Test Results

## Tests Run
1. Standard CSV file (10 rows, 5 columns) ✓

## Deployed
```

```text
# User uploads empty CSV - skill crashes
# User uploads 100MB CSV - timeout
# User uploads CSV with emojis in headers - parsing error
# User uploads TSV file - wrong delimiter
# 4 production failures from untested cases
```

**Correct (edge cases covered):**

```markdown
# CSV Parser - Test Results

## Standard Cases
1. Standard CSV (10 rows, 5 columns) ✓
2. Large CSV (10,000 rows) ✓

## Edge Cases
3. Empty file (0 rows) ✓ - Returns "No data found"
4. Headers only (0 data rows) ✓ - Returns headers list
5. Single column ✓
6. Unicode in headers (日本語, emoji) ✓
7. Quoted fields with commas ✓
8. TSV file (tab-separated) ✗ - Added delimiter detection

## Error Cases
9. Binary file (not CSV) ✓ - Returns "Invalid format"
10. Malformed CSV (inconsistent columns) ✓ - Reports row errors

## Instructions Updated
- Added: "Detect delimiter automatically (comma, tab, semicolon)"
- Added: "Handle unicode characters in all fields"
- Added: "For empty files, report 'No data found' instead of error"
```

**Common edge cases to test:**
| Category | Edge Cases |
|----------|------------|
| Size | Empty, 1 item, very large |
| Characters | Unicode, emoji, special chars |
| Format | Missing fields, extra fields |
| Types | Null, undefined, wrong type |

Reference: [Anthropic Engineering: Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
