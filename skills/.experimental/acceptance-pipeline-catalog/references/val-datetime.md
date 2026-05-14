---
title: Shift Date/Time Values by Precision-Appropriate Amount
impact: HIGH
impactDescription: dithering date strings instead of shifting them produces unparseable values, converting 100% of temporal mutations into error-state results
tags: val, value, datetime, date, time, iso-8601, shift
---

## Shift Date/Time Values by Precision-Appropriate Amount

Date and time values control scheduling, expiry, ordering, and time-dependent logic. Mutating them tests whether the application actually uses the temporal value or just passes it through unchecked.

### Spec Requirements

**Condition:** `trimmed` is an ISO-8601 date, time, or date-time value.

**Mutation:** Shift the value by a **pseudo-random nonzero amount** appropriate to the represented precision.

```text
"2026-05-13"          -> "2026-05-15"     (date shifted by days)
"14:30:00"            -> "14:33:00"       (time shifted by minutes)
"2026-05-13T14:30:00" -> "2026-05-15T14:30:00"  (date-time shifted)
```

The shift must be:
- **Nonzero** — otherwise the mutation is identical.
- **Appropriate to precision** — a date value shifts by days, a time value shifts by the smallest represented unit, a date-time can shift by either.
- **Pseudo-random and deterministic** — reproducible for the same path and value.

### Recognized Formats

At minimum, the mutator should recognize:
- Dates: `YYYY-MM-DD`
- Times: `HH:MM:SS`, `HH:MM`
- Date-times: `YYYY-MM-DDTHH:MM:SS`, with optional timezone offsets

### Why Precision-Appropriate Shifts

Shifting a date by milliseconds would produce a value that looks identical when rendered as a date. Shifting a time by days makes no sense. The shift must match the precision of the original value to produce a meaningfully different but structurally valid temporal value.

### Examples

**Incorrect (dithers date string character-by-character, producing unparseable output):**

```json
{
  "original": "2026-05-13",
  "rule": "string-dither",
  "mutated": "2026-05-1e"
}
```

**Correct (shifts date by precision-appropriate amount, preserving ISO-8601 format):**

```json
{
  "original": "2026-05-13",
  "rule": "datetime",
  "shift_days": 2,
  "mutated": "2026-05-15"
}
```

### Why This Matters

Time-dependent logic is notoriously undertested. A test that checks "the event is scheduled" but not "the event is scheduled for May 13" will pass when the date shifts to May 15. The survived mutation reveals that the test does not verify the actual date — a common source of production bugs when dates are miscalculated.
