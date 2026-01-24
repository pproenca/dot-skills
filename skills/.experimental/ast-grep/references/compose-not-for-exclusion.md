---
title: Use Not for Exclusion Patterns
impact: HIGH
impactDescription: reduces false positives by 30-70%
tags: compose, not, exclusion, composite-rules
---

## Use Not for Exclusion Patterns

The `not` rule inverts matching logic. Use it to exclude specific patterns from broader matches.

**Incorrect (relies on post-processing to filter):**

```yaml
id: find-all-functions
language: javascript
rule:
  kind: function_declaration
# Then manually filter out async functions
```

**Correct (not excludes at match time):**

```yaml
id: find-sync-functions
language: javascript
rule:
  all:
    - kind: function_declaration
    - not:
        has:
          pattern: async
```

**Key behaviors:**
- `not` succeeds when its sub-rule fails to match
- Cannot capture meta variables (nothing matched)
- Often combined with `all` for filter patterns

**Common exclusion patterns:**

```yaml
# Match console.log but not inside catch blocks
rule:
  all:
    - pattern: console.log($MSG)
    - not:
        inside:
          kind: catch_clause

# Match await but not inside try blocks
rule:
  all:
    - pattern: await $EXPR
    - not:
        inside:
          kind: try_statement

# Match identifiers that aren't parameters
rule:
  all:
    - kind: identifier
    - not:
        inside:
          kind: formal_parameters
```

Reference: [Composite Rules](https://ast-grep.github.io/reference/rule.html#composite-rules)
