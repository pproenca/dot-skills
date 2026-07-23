---
title: Match type casts as as_expression, not angle brackets
tags: ts, casts, as-expression, tsx
---

## Match type casts as as_expression, not angle brackets

To find or remove type assertions in TS/React code, match the `as_expression` node: `event.target as HTMLInputElement` parses as `as_expression` under both `typescript` and `tsx`. The older angle-bracket form `<HTMLInputElement>event.target` only parses under `typescript` — the `tsx` grammar reads `<HTMLInputElement>` as the start of a JSX element — so a rule searching component files for casts will never see angle-bracket ones anyway. Standardize on matching `as_expression`.

```yaml
# Find `x as SomeType` casts (works in .ts and .tsx).
language: tsx
rule:
  pattern: $EXPR as $TYPE
  kind: as_expression
```

```yaml
# Remove an unsafe double cast `x as unknown as T`, keeping the expression.
language: tsx
rule:
  pattern: $EXPR as unknown as $TYPE
fix: $EXPR as $TYPE
```

Reference: [ast-grep pattern syntax](https://ast-grep.github.io/guide/pattern-syntax.html)
