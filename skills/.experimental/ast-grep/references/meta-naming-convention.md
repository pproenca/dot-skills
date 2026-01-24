---
title: Follow Meta Variable Naming Conventions
impact: CRITICAL
impactDescription: prevents capture failures
tags: meta, naming, syntax, variables
---

## Follow Meta Variable Naming Conventions

Meta variables must start with `$` followed by uppercase letters, underscores, or digits. Invalid names silently fail to capture.

**Incorrect (lowercase, kebab-case, numbers first):**

```yaml
id: find-function-calls
language: javascript
rule:
  pattern: $func($args)        # lowercase fails
  # pattern: $KEBAB-CASE       # hyphens invalid
  # pattern: $123ABC           # numbers first invalid
```

**Correct (uppercase with underscores):**

```yaml
id: find-function-calls
language: javascript
rule:
  pattern: $FUNC($ARGS)
```

**Valid meta variable formats:**
- `$META` - basic uppercase
- `$META_VAR` - with underscores
- `$META_VAR1` - with trailing digits
- `$_` - single underscore wildcard
- `$_123` - underscore prefix with digits

**Invalid formats:**
- `$invalid` - lowercase letters
- `$Svalue` - mixed case
- `$123` - starts with digit
- `$KEBAB-CASE` - contains hyphen

Reference: [Pattern Syntax](https://ast-grep.github.io/guide/pattern-syntax.html)
