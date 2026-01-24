---
title: Ensure Fix Templates Produce Valid Syntax
impact: MEDIUM-HIGH
impactDescription: prevents generating unparseable code
tags: rewrite, syntax, fix, validation
---

## Ensure Fix Templates Produce Valid Syntax

Fix templates are inserted textually without parsing. Ensure meta variable substitutions produce syntactically valid code for all possible matches.

**Incorrect (fix may produce invalid syntax):**

```yaml
id: wrap-in-array
language: javascript
rule:
  pattern: $EXPR
fix: '[$EXPR]'
# If $EXPR is "a, b", produces "[a, b]" - different meaning!
```

**Correct (account for expression types):**

```yaml
id: wrap-single-value
language: javascript
rule:
  pattern: $EXPR
constraints:
  EXPR:
    not:
      kind: sequence_expression  # Exclude comma expressions
fix: '[$EXPR]'
```

**Syntax validation checklist:**
- Parentheses balance after substitution
- Quote escaping in string contexts
- Comma placement for multi-match variables
- Statement terminators (semicolons)

**Handling edge cases:**

```yaml
# Multi-match needs comma handling
id: spread-args
rule:
  pattern: fn($$$ARGS)
fix: newFn(...[$$$ARGS])  # Commas preserved from original

# Statement vs expression context
id: add-return
rule:
  pattern: $EXPR
  inside:
    kind: arrow_function
    field: body
fix: '{ return $EXPR; }'  # Add braces and semicolon
```

Reference: [Lint Rules](https://ast-grep.github.io/guide/project/lint-rule.html)
