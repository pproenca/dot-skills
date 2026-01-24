---
title: Choose Kind or Pattern Based on Specificity Needs
impact: CRITICAL
impactDescription: prevents overly broad or narrow matching
tags: pattern, kind, atomic-rules, specificity
---

## Choose Kind or Pattern Based on Specificity Needs

Use `kind` for broad node-type matching and `pattern` for specific code structures. Combining them incorrectly causes unexpected results.

**Incorrect (kind + pattern together fails):**

```yaml
id: find-specific-call
language: javascript
rule:
  kind: call_expression
  pattern: console.log($MSG)  # These don't compose directly
```

**Correct (use pattern object or all):**

```yaml
id: find-specific-call
language: javascript
rule:
  all:
    - kind: call_expression
    - pattern: console.log($MSG)
```

**Alternative (pattern with kind constraint):**

```yaml
id: find-identifier-usage
language: javascript
rule:
  pattern: $VAR
constraints:
  VAR:
    kind: identifier
```

**When to use each:**
- `kind` alone: Match all nodes of a type (all function declarations)
- `pattern` alone: Match specific code structure (console.log calls)
- `all` with both: Filter pattern matches by kind
- Constraints: Filter captured meta variables by kind

Reference: [Atomic Rules](https://ast-grep.github.io/reference/rule.html#atomic-rules)
