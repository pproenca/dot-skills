---
title: Use Any for OR Logic Between Rules
impact: HIGH
impactDescription: 3-10× fewer duplicate rules
tags: compose, any, or-logic, composite-rules
---

## Use Any for OR Logic Between Rules

The `any` composite rule matches if at least one sub-rule succeeds. Use it for alternative patterns that should trigger the same action.

**Incorrect (multiple separate rules for variations):**

```yaml
# Rule 1
id: find-console-log
rule:
  pattern: console.log($MSG)
---
# Rule 2
id: find-console-warn
rule:
  pattern: console.warn($MSG)
```

**Correct (single rule with any):**

```yaml
id: find-console-usage
language: javascript
rule:
  any:
    - pattern: console.log($MSG)
    - pattern: console.warn($MSG)
    - pattern: console.error($MSG)
message: Avoid console statements in production
```

**Key behaviors:**
- First matching sub-rule determines the captured variables
- Meta variables from non-matching sub-rules are not available
- Use consistent variable names across alternatives for uniform rewrites

**Common OR patterns:**

```yaml
# Match various loop types
rule:
  any:
    - kind: for_statement
    - kind: while_statement
    - kind: do_statement

# Match function declarations or expressions
rule:
  any:
    - kind: function_declaration
    - kind: function_expression
    - kind: arrow_function
```

Reference: [Composite Rules](https://ast-grep.github.io/reference/rule.html#composite-rules)
