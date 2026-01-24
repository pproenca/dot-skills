---
title: Use Has for Child Node Requirements
impact: HIGH
impactDescription: reduces false positives by 60-80%
tags: compose, has, relational, children
---

## Use Has for Child Node Requirements

The `has` relational rule confirms that a matched node contains specific descendant nodes. Use it to filter parent nodes by their content.

**Incorrect (pattern can't express child requirements):**

```yaml
id: find-function-with-await
language: javascript
rule:
  pattern: function $NAME() { $$$BODY }  # Can't require await in body
```

**Correct (has checks for descendants):**

```yaml
id: find-function-with-await
language: javascript
rule:
  all:
    - kind: function_declaration
    - has:
        pattern: await $EXPR
```

**Specifying which children via field:**

```yaml
# Only check function body, not parameters
rule:
  kind: function_declaration
  has:
    field: body
    pattern: return $VAL

# Only check condition, not consequent
rule:
  kind: if_statement
  has:
    field: condition
    pattern: $A === null
```

**Controlling search depth:**

```yaml
# Avoids matching nested returns in inner functions
rule:
  kind: block_statement
  has:
    kind: return_statement
    stopBy: neighbor

# Searches entire function body including nested callbacks
rule:
  kind: function_declaration
  has:
    pattern: console.log($MSG)
```

Reference: [Relational Rules](https://ast-grep.github.io/reference/rule.html#relational-rules)
