---
title: Shift Float Values by Pseudo-Random Delta
impact: HIGH
impactDescription: applying integer deltas to float values loses fractional precision, producing non-representative mutations that miss ~50% of rounding and threshold bugs
tags: val, value, float, delta, decimal, numeric
---

## Shift Float Values by Pseudo-Random Delta

Floating-point values represent prices, measurements, percentages, and other precise numeric data. Mutating them tests whether the application and its tests are sensitive to the specific value, not just the presence of a number.

### Spec Requirements

**Condition:** `trimmed` is a finite base-10 floating-point number (e.g., `"3.14"`, `"-0.5"`, `"100.0"`).

**Mutation:** Replace with the decimal representation of the number plus a **pseudo-random nonzero floating-point delta**.

```text
"3.14" -> "2.89"
"0.5"  -> "1.23"
```

The delta must be:
- **Nonzero** — otherwise the mutation is identical.
- **Pseudo-random** — varied across mutation paths.
- **Deterministic** — reproducible for the same path and value.
- The result must be a **finite** number (no infinity or NaN).

### Why Separate From Integer

The integer rule (priority 4) matches first for values like `"42"`. The float rule only triggers for values with a decimal point (like `"3.14"`) or values that parse as floats but not integers. This ensures integer values get integer-appropriate deltas (whole numbers) and float values get float-appropriate deltas (potentially fractional).

### Examples

**Incorrect (applies integer delta to float, losing fractional precision):**

```json
{
  "original": "3.14",
  "rule": "integer",
  "delta": 2,
  "mutated": "5"
}
```

**Correct (applies float delta, preserving decimal representation):**

```json
{
  "original": "3.14",
  "rule": "float",
  "delta": -0.25,
  "mutated": "2.89"
}
```

### Why This Matters

Float mutations are particularly important for financial calculations, measurements, and threshold logic. A test that checks "the price is calculated" but not "the price is exactly $3.14" will pass when the price changes to $2.89. The survived mutation reveals that the test assertion is too loose.
