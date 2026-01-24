---
title: Use Inside for Contextual Matching
impact: HIGH
impactDescription: reduces false positives by 70-95%
tags: compose, inside, relational, context
---

## Use Inside for Contextual Matching

The `inside` relational rule verifies that matched nodes appear within a specific parent structure. Use it to limit pattern matches to relevant contexts.

**Incorrect (matches everywhere):**

```yaml
id: find-this-usage
language: javascript
rule:
  pattern: this.$PROP
# Matches in classes, objects, functions - too broad
```

**Correct (scoped to class methods):**

```yaml
id: find-this-in-class
language: javascript
rule:
  all:
    - pattern: this.$PROP
    - inside:
        kind: class_declaration
```

**Controlling search depth with stopBy:**

```yaml
# Match only direct children (immediate parent)
rule:
  pattern: $EXPR
  inside:
    kind: if_statement
    stopBy: neighbor  # Only immediate parent

# Match anywhere in function (default)
rule:
  pattern: $EXPR
  inside:
    kind: function_declaration
    stopBy: end  # Search to root

# Stop at specific boundary
rule:
  pattern: await $EXPR
  inside:
    kind: function_declaration
    stopBy:
      kind: arrow_function  # Don't cross nested arrow functions
```

Reference: [Relational Rules](https://ast-grep.github.io/reference/rule.html#relational-rules)
