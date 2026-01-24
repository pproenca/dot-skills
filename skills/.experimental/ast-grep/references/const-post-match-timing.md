---
title: Understand Constraints Apply After Matching
impact: HIGH
impactDescription: prevents confusion about match failures
tags: const, timing, matching, execution-order
---

## Understand Constraints Apply After Matching

Constraints filter results after pattern matching completes. A pattern must first match successfully before constraints are evaluated.

**Incorrect (expects constraint to guide matching):**

```yaml
id: find-specific-call
language: javascript
rule:
  pattern: $FN()
constraints:
  FN:
    pattern: console.log  # Constraints don't make pattern more specific
```

**Correct (use specific pattern, constrain captures):**

```yaml
id: find-console-log
language: javascript
rule:
  pattern: console.log()  # Specific pattern
```

**Alternative (pattern then filter):**

```yaml
id: find-console-methods
language: javascript
rule:
  pattern: console.$METHOD($$$ARGS)
constraints:
  METHOD:
    regex: ^(log|warn|error)$  # Filter which methods
```

**Execution flow:**
1. Pattern matches against code → captures meta variables
2. Constraints evaluate against captured values
3. Match succeeds only if both pass

**When constraints are useful:**
- Pattern is necessarily generic (can't express specificity)
- Need to filter by properties pattern can't express
- Want different rules for same pattern, different constraints

Reference: [Lint Rules](https://ast-grep.github.io/guide/project/lint-rule.html)
