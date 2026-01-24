---
title: Preserve Program Semantics in Rewrites
impact: MEDIUM-HIGH
impactDescription: prevents introducing bugs during transformation
tags: rewrite, semantics, correctness, transformation
---

## Preserve Program Semantics in Rewrites

Rewrites replace matched code textually. Ensure the replacement maintains identical behavior to avoid introducing subtle bugs.

**Incorrect (changes evaluation order):**

```yaml
id: simplify-ternary
language: javascript
rule:
  pattern: $COND ? $THEN : $ELSE
fix: $COND && $THEN || $ELSE
# Bug: if $THEN is falsy, $ELSE executes even when $COND is true
```

**Correct (semantically equivalent transformation):**

```yaml
id: convert-to-if
language: javascript
rule:
  pattern: $COND ? true : false
fix: Boolean($COND)
```

**Semantic preservation checklist:**
- Does the replacement evaluate the same expressions?
- Are side effects executed in the same order?
- Are variables captured in the same scope?
- Does short-circuit evaluation change?

**Safe transformations:**

```yaml
# Safe: !! to Boolean()
pattern: '!!$EXPR'
fix: Boolean($EXPR)

# Safe: array spread for concat
pattern: $ARR.concat($ITEM)
fix: '[...$ARR, $ITEM]'

# Unsafe: may change behavior
pattern: $A || $B
fix: $A ?? $B  # Different for falsy vs nullish!
```

Reference: [Transformation](https://ast-grep.github.io/reference/yaml/transformation.html)
