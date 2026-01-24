---
title: Understand Multi-Match Variables Are Lazy
impact: CRITICAL
impactDescription: prevents unexpected short matches
tags: meta, multi-match, lazy, greedy
---

## Understand Multi-Match Variables Are Lazy

The `$$$` multi-match operator is lazy, not greedy. It stops at the first valid match to ensure linear-time performance.

**Incorrect (expects greedy matching):**

```yaml
id: extract-all-but-last
language: javascript
rule:
  pattern: fn($$$FIRST, $LAST)
# For fn(a, b, c): $$$FIRST = a, $LAST = b, c is unmatched!
```

**Correct (understand lazy semantics):**

```yaml
id: match-any-call
language: javascript
rule:
  pattern: fn($$$ARGS)  # Matches entire argument list
```

**Working with multi-match:**

```yaml
# Match calls with at least 2 args
id: find-two-plus-args
rule:
  pattern: fn($FIRST, $$$REST)  # $FIRST is required, $$$REST is 0+

# Match calls with at least 3 args
id: find-three-plus-args
rule:
  pattern: fn($A, $B, $$$REST)
```

**Important:** Multi-match variables cannot be used in rewrites directly because they represent multiple nodes, not a single value.

Reference: [FAQ](https://ast-grep.github.io/advanced/faq.html)
