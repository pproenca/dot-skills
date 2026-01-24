---
title: Reuse Meta Variables to Enforce Equality
impact: CRITICAL
impactDescription: prevents false positives on asymmetric code
tags: meta, binding, equality, matching
---

## Reuse Meta Variables to Enforce Equality

When the same meta variable name appears multiple times in a pattern, all occurrences must match identical code. Use different names for independent captures.

**Incorrect (reuses $VAR for independent values):**

```yaml
id: find-assignment
language: javascript
rule:
  pattern: $VAR = $VAR  # Only matches self-assignment like x = x
# Won't match: x = y
```

**Correct (uses distinct names for different captures):**

```yaml
id: find-assignment
language: javascript
rule:
  pattern: $TARGET = $VALUE  # Matches any assignment
```

**Intentional reuse for equality checks:**

```yaml
id: find-self-comparison
language: javascript
rule:
  pattern: $EXPR === $EXPR
message: Comparing expression to itself is always true
# Matches: x === x, foo.bar === foo.bar
```

**Practical use cases:**
- Detect redundant comparisons: `$A == $A`
- Find self-assignment bugs: `$X = $X`
- Match symmetric operations: `$A + $A`

Reference: [Pattern Syntax](https://ast-grep.github.io/guide/pattern-syntax.html)
