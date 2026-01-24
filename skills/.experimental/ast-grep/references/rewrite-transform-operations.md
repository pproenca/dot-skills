---
title: Use Transform for Complex Rewrites
impact: MEDIUM-HIGH
impactDescription: enables sophisticated code transformations
tags: rewrite, transform, replace, convert
---

## Use Transform for Complex Rewrites

The `transform` section modifies captured meta variables before inserting into the fix. Use it for case conversion, substring extraction, and regex replacement.

**Incorrect (manual string manipulation not possible):**

```yaml
id: convert-case
language: javascript
rule:
  pattern: const $VAR = $VAL
fix: const $VAR_UPPER = $VAL  # Can't uppercase in fix template
```

**Correct (use transform):**

```yaml
id: convert-to-screaming-case
language: javascript
rule:
  pattern: const $VAR = $VAL
transform:
  UPPER_VAR:
    convert:
      source: $VAR
      toCase: upperCase
fix: const $UPPER_VAR = $VAL
```

**Transform operations:**

```yaml
# Replace with regex
transform:
  NEW_NAME:
    replace:
      source: $NAME
      replace: 'old'
      by: 'new'

# Extract substring
transform:
  PREFIX:
    substring:
      source: $VAR
      startChar: 0
      endChar: 3

# Case conversion
transform:
  CAMEL:
    convert:
      source: $VAR
      toCase: camelCase
      # Options: lowerCase, upperCase, capitalize,
      # camelCase, snakeCase, kebabCase, pascalCase
```

**Chaining transforms:** Create intermediate variables to chain multiple operations.

Reference: [Transformation](https://ast-grep.github.io/reference/yaml/transformation.html)
