---
title: Replace Null-Like Values with Non-Empty Strings
impact: HIGH
impactDescription: swapping between null synonyms (null/nil/none) exercises no new code path, producing 0% coverage gain on presence-vs-absence branches
tags: val, value, null, nil, none, dither
---

## Replace Null-Like Values with Non-Empty Strings

Null-like values represent absence or "no value." Mutating them to a non-empty string tests whether the application correctly distinguishes between absence and presence of a value.

### Spec Requirements

**Condition:** Lowercase `trimmed` is `null`, `nil`, or `none`.

**Mutation:** Replace with a non-empty **dithered string**.

The specific dithered value is determined by the string dithering rules, but it must be non-empty. The goal is to replace "no value" with "some value."

### Why Not Toggle Between Null-Like Values

Replacing `"null"` with `"nil"` or `"none"` would likely be treated identically by most handlers — they all represent absence. The meaningful test is whether the handler behaves differently when given an actual value vs. no value. A dithered string like `"nulk"` or `"abc"` provides that contrast.

### Why Three Variants

Different languages and conventions use different null representations:
- `null` — JSON, JavaScript, Java, C#
- `nil` — Ruby, Lua, Go, Objective-C
- `none` — Python (`None` but lowercase in string form)

Recognizing all three ensures the mutator works across the language-neutral spec's target audience.

### Examples

**Incorrect (swaps between null synonyms, exercising no new code path):**

```json
{
  "original": "null",
  "rule": "null-synonym-swap",
  "mutated": "nil"
}
```

**Correct (replaces null-like value with a non-empty dithered string):**

```json
{
  "original": "null",
  "rule": "null-like",
  "mutated": "nulk"
}
```

### Why This Matters

A common test weakness is handling the "happy path" (value present) without testing the "absent" path (null/nil/none). If an example uses `"null"` for an optional field and the acceptance test passes, the mutator tests the reverse: does the test fail when that field has a value? If it still passes, the test is not checking the null-handling logic.
