---
title: Use Field to Target Specific Sub-Nodes
impact: HIGH
impactDescription: reduces false positives by 50-80% in relational rules
tags: compose, field, relational, targeting, precision
---

## Use Field to Target Specific Sub-Nodes

The `field` option in relational rules (`inside`, `has`) restricts matching to specific named children of AST nodes. Use it to distinguish between function bodies, parameters, conditions, and other structural elements.

**Incorrect (matches anywhere in function):**

```yaml
id: find-return-in-function
language: javascript
rule:
  pattern: return $VAL
  inside:
    kind: function_declaration
# Matches returns in body AND nested functions
```

**Correct (field targets specific child):**

```yaml
id: find-direct-return
language: javascript
rule:
  kind: function_declaration
  has:
    field: body  # Only check the body field
    has:
      pattern: return $VAL
```

**Common AST fields by node type:**

```yaml
# function_declaration fields
- name: identifier
- parameters: formal_parameters
- body: statement_block

# if_statement fields
- condition: parenthesized_expression
- consequence: statement_block
- alternative: else_clause

# for_statement fields
- initializer: variable_declaration
- condition: expression
- increment: update_expression
- body: statement_block

# call_expression fields
- function: identifier/member_expression
- arguments: arguments
```

**Targeting function parameters vs body:**

```yaml
# Match only in parameters (not in body)
id: find-destructured-param
language: javascript
rule:
  kind: function_declaration
  has:
    field: parameters
    has:
      kind: object_pattern

# Match only in body (not in parameters)
id: find-await-in-body
language: javascript
rule:
  kind: function_declaration
  has:
    field: body
    has:
      pattern: await $EXPR
```

**Targeting if statement parts:**

```yaml
# Match in condition only
id: find-assignment-in-condition
language: javascript
rule:
  kind: if_statement
  has:
    field: condition
    has:
      pattern: $VAR = $VAL  # Assignment, not comparison

# Match in consequence only
id: find-return-in-if-body
language: javascript
rule:
  kind: if_statement
  has:
    field: consequence
    has:
      pattern: return $VAL
```

**Combining field with stopBy:**

```yaml
# Match return directly in function body, not nested
id: find-top-level-return
language: javascript
rule:
  kind: function_declaration
  has:
    field: body
    has:
      pattern: return $VAL
      stopBy: neighbor  # Direct child of body only
```

**When to use field:**

- Distinguishing function parameters from body
- Targeting if/while conditions vs their bodies
- Matching loop initializers, conditions, or increments separately
- Any case where position within parent matters

**Tip:** Use `--debug-query=ast` to discover field names for your target language.

Reference: [Relational Rules](https://ast-grep.github.io/reference/rule.html#field)
