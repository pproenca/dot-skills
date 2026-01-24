---
title: Avoid Heavy Regex in Hot Paths
impact: MEDIUM
impactDescription: 2-10× faster matching with AST patterns
tags: perf, regex, optimization, constraints
---

## Avoid Heavy Regex in Hot Paths

Regex matching is slower than AST pattern matching. Use patterns and kind filters first, then apply regex only when necessary.

**Incorrect (regex as primary filter):**

```yaml
id: find-variables
language: javascript
rule:
  kind: identifier
  regex: '.*'  # Matches all identifiers, then filters
constraints:
  # Complex regex on every identifier
```

**Correct (pattern first, regex to refine):**

```yaml
id: find-prefixed-variables
language: javascript
rule:
  pattern: $VAR
  inside:
    kind: variable_declarator
constraints:
  VAR:
    regex: ^(cache|pending|_)
```

**Regex optimization tips:**

```yaml
# Anchor patterns for faster matching
regex: ^prefix  # Faster than: .*prefix
regex: suffix$  # Faster than: suffix.*

# Use character classes efficiently
regex: ^[a-z_][a-zA-Z0-9_]*$  # Identifier pattern

# Avoid catastrophic backtracking
# Bad: (a+)+b
# Good: a+b
```

**When to use regex vs pattern:**

| Use Case | Prefer |
|----------|--------|
| Structural matching | pattern |
| Node type filtering | kind |
| Text content filtering | regex (in constraints) |
| Partial name matching | regex |

**Performance hierarchy:**
1. `kind` - fastest (direct node type check)
2. `pattern` - fast (tree comparison)
3. `regex` - slower (string matching)

Reference: [Atomic Rules](https://ast-grep.github.io/reference/rule.html#atomic-rules)
