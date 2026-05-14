---
title: Apply Value Mutation Rules in Priority Order
impact: HIGH
impactDescription: wrong rule priority produces incorrect mutations for ambiguous values, misclassifying ~15% of mutations on typical feature files with mixed types
tags: val, value, rules, priority, order
---

## Apply Value Mutation Rules in Priority Order

The value mutation rules form a priority chain. When a value matches multiple rules (e.g., `"true"` is both a boolean and a string), the first matching rule wins. Getting the order wrong produces different — and incorrect — mutations.

### Spec Requirements

Before selecting a rule, compute:

```text
trimmed = value with leading and trailing whitespace removed
```

Rules are applied in this priority order:

| Priority | Rule | Condition |
|----------|------|-----------|
| 1 | Comma-list | `trimmed` contains a comma |
| 2 | Boolean | Lowercase `trimmed` is `true` or `false` |
| 3 | Null-like | Lowercase `trimmed` is `null`, `nil`, or `none` |
| 4 | Integer | `trimmed` is a base-10 integer |
| 5 | Float | `trimmed` is a finite base-10 floating-point number |
| 6 | Date/time | `trimmed` is an ISO-8601 date, time, or date-time |
| 7 | Duration | `trimmed` is a recognized duration value |
| 8 | String dither | Default fallback |

### Why This Order

The order resolves ambiguity predictably:

- **Comma-list first**: `"true, false"` is a list of booleans, not a single boolean. The list rule splits it, then recursively mutates one item (which hits the boolean rule).
- **Boolean before integer**: `"true"` should toggle to `"false"`, not be dithered as a string.
- **Integer before float**: `"42"` should get an integer delta, not a float delta. This preserves the original type's precision.
- **Float before date**: A value like `"2026"` could be a year (date) or an integer. The integer rule matches first, which is correct — bare four-digit numbers are more commonly integers than dates.
- **String dither last**: Anything that does not match a more specific type gets character-level edits.

### Examples

**Incorrect (no priority order, "true, false" hits boolean rule instead of comma-list):**

```json
{
  "value": "true, false",
  "rule_applied": "boolean",
  "mutated": "false, false"
}
```

**Correct (comma-list rule matches first, splits, then recurses into boolean for selected item):**

```json
{
  "value": "true, false",
  "rule_applied": "comma-list",
  "split": ["true", "false"],
  "selected_index": 0,
  "item_rule": "boolean",
  "mutated": "false, false"
}
```

### Why Trimming

Values from examples tables may have incidental whitespace. Trimming before type detection ensures `" 42 "` is recognized as an integer, not dithered as a string with leading spaces.

### Why This Matters

The mutation model's goal is to produce **meaningful** value changes that test handlers should detect. Applying the wrong rule produces mutations that are either trivially detected (wrong type) or undetectable (structurally identical). The priority order maximizes the chance of producing a mutation that exercises the handler's value-handling logic.
