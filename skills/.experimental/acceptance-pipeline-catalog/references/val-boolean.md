---
title: Toggle Boolean Values
impact: HIGH
impactDescription: failing to toggle booleans produces parse-error mutations instead of semantic ones, yielding 0% behavioral coverage on boolean-controlled branches
tags: val, value, boolean, true, false
---

## Toggle Boolean Values

Boolean values have exactly two states. The only meaningful mutation is toggling to the opposite value. This directly tests whether the application behaves differently for true vs. false.

### Spec Requirements

**Condition:** Lowercase `trimmed` is `true` or `false`.

**Mutation:** Replace with the opposite lowercase boolean value.

```text
"true"  -> "false"
"false" -> "true"
"True"  -> "false"
"FALSE" -> "true"
```

The mutated value is always **lowercase** (`"true"` or `"false"`), regardless of the original casing.

### Why Lowercase Output

The IR stores all values as strings. Using consistent lowercase for the mutated boolean avoids case-sensitivity issues downstream. If the original was `"TRUE"` and the mutation produced `"FALSE"`, a case-insensitive handler might treat both the same way, making the mutation meaningless. Lowercase is the canonical form.

### Examples

**Incorrect (dithers "true" as a string, producing an unparseable value):**

```json
{
  "original": "true",
  "rule": "string-dither",
  "mutated": "troe"
}
```

**Correct (toggles boolean to its opposite in lowercase):**

```json
{
  "original": "True",
  "rule": "boolean",
  "mutated": "false"
}
```

### Why This Rule Exists Before Integer

Without this rule, `"true"` would fall through to string dithering, producing something like `"troe"`. That is a string mutation, not a semantic boolean mutation. A handler that parses `"troe"` would fail with a parse error, not with a behavioral difference. The boolean rule produces `"false"`, which the handler can parse — and the test should detect the behavioral change.

### Why This Matters

Boolean flags control branching in application logic. A mutation from `"true"` to `"false"` tests whether the acceptance test actually verifies the behavior associated with that flag. If the test passes with both values, it is not checking the flag's effect — a clear test gap.
