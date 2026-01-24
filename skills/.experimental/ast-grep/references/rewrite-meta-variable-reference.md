---
title: Reference All Necessary Meta Variables in Fix
impact: MEDIUM-HIGH
impactDescription: prevents loss of captured code
tags: rewrite, meta-variables, fix, completeness
---

## Reference All Necessary Meta Variables in Fix

The `fix` template replaces matched code textually. Any captured meta variable not referenced in the fix is lost.

**Incorrect (loses the message argument):**

```yaml
id: migrate-console
language: javascript
rule:
  pattern: console.log($MSG, $$$REST)
fix: logger.info()  # $MSG and $$$REST are lost!
```

**Correct (preserves all captures):**

```yaml
id: migrate-console
language: javascript
rule:
  pattern: console.log($MSG, $$$REST)
fix: logger.info($MSG, $$$REST)
```

**Intentional omission for cleanup:**

```yaml
# Remove debug statements entirely (intentional loss)
id: remove-debug
language: javascript
rule:
  pattern: console.debug($$$ARGS)
fix: ''  # Empty fix removes the statement
```

**Checking for completeness:**

```yaml
# Before deploying, verify fix includes:
# 1. All single meta variables ($VAR)
# 2. All multi-match variables ($$$VAR) if needed
# 3. Proper syntax around insertions
rule:
  pattern: old($A, $B, $C)
fix: new($A, $B, $C)  # All three preserved
```

Reference: [Lint Rules](https://ast-grep.github.io/guide/project/lint-rule.html)
