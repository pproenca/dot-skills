---
title: Use All for AND Logic Between Rules
impact: HIGH
impactDescription: reduces false positives by 50-90%
tags: compose, all, and-logic, composite-rules
---

## Use All for AND Logic Between Rules

The `all` composite rule requires a node to satisfy every sub-rule. Use it to combine multiple conditions that must all be true.

**Incorrect (relies on implicit YAML field merging):**

```yaml
id: find-async-arrow
language: javascript
rule:
  kind: arrow_function
  pattern: async () => $BODY  # YAML fields don't AND together
```

**Correct (explicit all for AND):**

```yaml
id: find-async-arrow
language: javascript
rule:
  all:
    - kind: arrow_function
    - has:
        pattern: async
```

**Key behaviors:**
- All sub-rules must match the same single node
- Meta variables from all sub-rules are merged into final match
- Order in `all` array can matter for relational rules

**Common AND patterns:**

```yaml
# Match console.log inside async functions
rule:
  all:
    - pattern: console.log($MSG)
    - inside:
        kind: function_declaration
        has:
          pattern: async

# Match identifier that's a function parameter
rule:
  all:
    - kind: identifier
    - inside:
        kind: formal_parameters
```

Reference: [Composite Rules](https://ast-grep.github.io/reference/rule.html#composite-rules)
