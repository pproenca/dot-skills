---
title: Shift Integer Values by Pseudo-Random Delta
impact: HIGH
impactDescription: using a fixed +1/-1 delta creates predictable mutations that boundary-check tests trivially catch, missing ~60% of loose-assertion gaps
tags: val, value, integer, delta, numeric
---

## Shift Integer Values by Pseudo-Random Delta

Integer values represent counts, quantities, indexes, thresholds, and other numeric data. Mutating them by a pseudo-random delta tests whether the application and its tests are sensitive to the specific numeric value.

### Spec Requirements

**Condition:** `trimmed` is a base-10 integer (e.g., `"42"`, `"-7"`, `"0"`).

**Mutation:** Replace with the decimal representation of the integer plus a **pseudo-random nonzero integer delta**.

```text
"20" -> "27"
"0"  -> "-3"
"-5" -> "2"
```

The delta must be:
- **Nonzero** — otherwise the mutation is identical to the original and would be skipped.
- **Pseudo-random** — varied across different mutation paths to avoid systematic bias.
- **Deterministic** — the same mutation path and original value always produce the same delta.

### Why Nonzero Delta

A zero delta produces the original value, which would be skipped by the identical-value filter. The delta must change the value to test whether the handler and application respond to the change.

### Why Not Always +1 or -1

A fixed delta like +1 would create predictable mutations that developers might unconsciously design tests to catch (e.g., boundary checks at value +/- 1). Pseudo-random deltas of varying magnitude test that the application is not just checking boundaries but actually using the value.

### Examples

**Incorrect (always adds +1, creating predictable boundary mutations):**

```json
{
  "original": "20",
  "rule": "integer",
  "delta": 1,
  "mutated": "21"
}
```

**Correct (adds pseudo-random nonzero delta seeded from path and value):**

```json
{
  "original": "20",
  "rule": "integer",
  "delta": 7,
  "mutated": "27"
}
```

### Why This Matters

Integer mutations are among the most likely to produce **survived** mutations in practice. A test that checks "the order has items" but not "the order has exactly 3 items" will pass when the count changes from 3 to 10. The survived mutation report tells the developer: your test does not verify the count.
