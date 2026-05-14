---
title: Dither Unrecognized Strings with Small Edits
impact: HIGH
impactDescription: large random replacements are trivially caught by any handler, missing ~80% of loose-match gaps that small character edits expose
tags: val, value, string, dither, edit, fallback
---

## Dither Unrecognized Strings with Small Edits

String dithering is the default fallback mutation rule. When a value does not match any specific type (boolean, integer, float, date, duration), the mutator applies a small character-level edit. This catches all the domain-specific values that the portable mutator cannot understand semantically.

### Spec Requirements

**Condition:** The value does not match any higher-priority rule (rules 1-7).

**Mutation:** Produce a different string by applying one small edit:
- Inserting a character
- Deleting a character
- Replacing a character
- Swapping adjacent characters
- Changing character case

**Empty strings** are dithered by inserting a character (since deletion, replacement, and swapping are impossible on an empty string).

### Examples

```text
"accepted"            -> "accfpted"        (character replacement)
"message with spaces" -> "message with spcaes"  (character swap)
""                    -> "a"               (insertion into empty)
```

### Why Small Edits

Large changes (replacing the whole string, random generation) would produce values so different that almost any handler would catch them. Small edits test whether the handler verifies the **exact** value. A handler that checks `status == "accepted"` catches `"accfpted"`. A handler that only checks `status.length > 0` does not.

### Why Not Semantic Mutations

The portable mutator intentionally does **not** define command, enum, or domain-specific swaps (e.g., replacing `"accepted"` with `"rejected"`). Such mutations require domain knowledge that varies by project. Project-specific semantic mutations belong in a project adapter or mutator extension, not in the portable core.

### Examples

**Incorrect (replaces entire string, trivially caught by any handler):**

```json
{
  "original": "accepted",
  "rule": "string-replace",
  "mutated": "xK9!qZ2m"
}
```

**Correct (applies one small character edit, testing exact-value verification):**

```json
{
  "original": "accepted",
  "rule": "string-dither",
  "edit": "replace char at index 3",
  "mutated": "accfpted"
}
```

### Why This Matters

Many example values are domain-specific strings: status codes, command names, error messages, user roles. These cannot be understood by a generic mutator, but character-level edits still test whether the handler verifies the exact value. A survived string-dither mutation means the test does not check the specific string — it either ignores it or uses a loose match.
