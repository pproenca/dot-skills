---
title: Apply Comma-List Mutation First
impact: HIGH
impactDescription: treats compound values as atomic, missing N sub-value mutations per comma-list and reducing mutation coverage by ~30% on typical feature files
tags: val, value, comma-list, split, recursive
---

## Apply Comma-List Mutation First

When a value contains a comma, the mutator treats it as a comma-delimited list and mutates a single item within it. This is the highest-priority value mutation rule because lists contain structured data that should be tested at the item level.

### Spec Requirements

**Condition:** `trimmed` value contains a comma.

**Mutation process:**
1. Split the value on commas.
2. Trim each item.
3. Select one item pseudo-randomly (deterministically based on mutation path and original value).
4. Mutate the selected item **recursively** using the same value mutation rules.
5. Rejoin the list with `", "` (comma-space separator).

### Example

```text
Original: "2, 5, 8"
Split:    ["2", "5", "8"]
Select:   item at index 1 ("5")
Mutate:   "5" -> integer rule -> "11"
Result:   "2, 11, 8"
```

### Why Recursive Mutation

The selected item goes through the full rule chain. This means:
- An item `"true"` in a list gets boolean mutation (toggled to `"false"`).
- An item `"42"` gets integer mutation (shifted by delta).
- An item `"hello"` gets string dithering.

This produces type-appropriate mutations for each list element rather than crude string edits on the whole list.

### Why Mutate Only One Item

Changing one item at a time follows the same principle as one-mutation-per-cell: isolation. If two items changed simultaneously, a test failure could not pinpoint which change was detected. Single-item mutation makes the mutation report actionable.

### Examples

**Incorrect (dithers the entire list as one string, losing sub-value semantics):**

```json
{
  "original": "admin, editor, viewer",
  "rule": "string-dither",
  "mutated": "admjn, editor, viewer"
}
```

**Correct (splits on comma, selects one item, mutates it recursively):**

```json
{
  "original": "admin, editor, viewer",
  "rule": "comma-list",
  "split": ["admin", "editor", "viewer"],
  "selected_index": 1,
  "item_rule": "string-dither",
  "mutated": "admin, editzr, viewer"
}
```

### Why This Matters

Many acceptance test examples use comma-separated lists for multi-value inputs (e.g., `"admin, editor, viewer"` for roles). Testing whether the application correctly processes each individual value requires mutating items within the list, not just dithering the entire string.
