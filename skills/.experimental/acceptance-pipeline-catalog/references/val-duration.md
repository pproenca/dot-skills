---
title: Shift Duration Values Preserving Syntax
impact: HIGH
impactDescription: dithering duration strings instead of shifting them produces unparseable values, converting 100% of duration mutations into error-state results
tags: val, value, duration, shift, syntax
---

## Shift Duration Values Preserving Syntax

Duration values represent time spans — timeouts, intervals, retention periods, etc. Mutating them tests whether the application uses the actual duration value or just checks for its presence.

### Spec Requirements

**Condition:** `trimmed` is a recognized duration value.

**Mutation:** Shift the duration by a **pseudo-random nonzero amount** while preserving valid duration syntax.

The specific duration formats recognized are implementation-defined, but common formats include:
- ISO-8601 durations (`PT1H30M`, `P2D`)
- Simple numeric durations with units (`30s`, `5m`, `2h`)

### Key Constraints

- The shift must be **nonzero** — otherwise the mutation is identical.
- The mutated value must **preserve valid duration syntax** — if the input was `PT1H30M`, the output must also be a valid ISO-8601 duration, not a malformed string.
- The shift must be **pseudo-random and deterministic**.

### Why Preserve Syntax

If the mutator changes `"PT1H30M"` to `"PT1H37M"` (shifted by 7 minutes), the handler can parse it as a valid duration. If it changed to `"PT1H3z0M"` (string dithering), the handler would fail with a parse error — which classifies as `error`, not a meaningful test quality signal.

Syntax-preserving mutation produces values that exercise the application's duration-handling logic, not its error-handling logic.

### Why Duration Is Separate From String Dither

A duration like `"30s"` looks like an ordinary string. Without this rule, it would be dithered to something like `"30t"` or `"3s"` — which is either unparseable or accidentally valid. The duration rule produces `"37s"` — a valid, different duration that tests whether the application cares about the specific value.

### Examples

**Incorrect (dithers duration string, breaking syntax):**

```json
{
  "original": "PT1H30M",
  "rule": "string-dither",
  "mutated": "PT1H3zM"
}
```

**Correct (shifts duration value, preserving valid ISO-8601 duration syntax):**

```json
{
  "original": "PT1H30M",
  "rule": "duration",
  "shift_minutes": 7,
  "mutated": "PT1H37M"
}
```

### Why This Matters

Duration values control timeouts, polling intervals, cache TTLs, and retry delays. These are often set once and never validated by tests. A survived mutation on a duration value reveals that the acceptance test does not verify the timeout or interval value — a gap that could hide misconfiguration bugs.
