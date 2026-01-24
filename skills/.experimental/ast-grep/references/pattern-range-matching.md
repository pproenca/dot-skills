---
title: Use Range for Character Position Matching
impact: LOW-MEDIUM
impactDescription: enables location-based code targeting
tags: pattern, range, position, coordinates, atomic
---

## Use Range for Character Position Matching

The `range` atomic rule matches nodes by their character position in the source file. Use it for precise location-based targeting when other methods are insufficient.

**Incorrect (trying to match by line number with pattern):**

```yaml
id: find-at-line
language: javascript
rule:
  pattern: $EXPR  # No way to filter by location
```

**Correct (range targets by position):**

```yaml
id: find-in-range
language: javascript
rule:
  kind: expression_statement
  range:
    start:
      line: 10
      column: 0
    end:
      line: 20
      column: 0
```

**Range specification:**

```yaml
# Match node starting at specific position
range:
  start:
    line: 5      # 0-based line number
    column: 4    # 0-based column number

# Match node within range
range:
  start:
    line: 10
    column: 0
  end:
    line: 50
    column: 0
```

**Practical use cases:**

```yaml
# Match code in specific function (by known position)
id: audit-function
rule:
  kind: function_declaration
  range:
    start:
      line: 100
    end:
      line: 150

# Match imports at top of file
id: find-early-imports
rule:
  kind: import_statement
  range:
    end:
      line: 20  # First 20 lines
```

**When NOT to use range:**

- For structural matching (use `pattern` or `kind` instead)
- For context-based matching (use `inside` instead)
- When code positions may change (range is brittle)

**When to use range:**

- Auditing specific code regions
- Generating reports with location context
- Combining with other rules for precise targeting

**Note:** Line and column numbers are 0-based. Range matching is fragile to code changes - prefer structural patterns when possible.

Reference: [Atomic Rules](https://ast-grep.github.io/reference/rule.html#range)
