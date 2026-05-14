---
title: Store Example Values as Strings
impact: CRITICAL
impactDescription: non-string values break the mutation model (8 type-inference rules) and cross-language portability
tags: ir, json, example, string-values, portability
---

## Store Example Values as Strings

An example object is a simple map from parameter names (column headers) to string values (cell contents). It represents one row of an examples table and drives one scenario execution.

### Spec Requirements

```json
{
  "input": "42",
  "command": "calculate total",
  "expected_status": "accepted"
}
```

**All values must be strings**, even when they represent:
- Numbers (`"42"`, `"3.14"`)
- Booleans (`"true"`, `"false"`)
- Lists (`"2, 5, 8"`)
- Commands (`"calculate total"`)
- Messages, enums, or any other domain type

### Why Everything Is a String

This is the most important portability decision in the IR design. Three reasons:

1. **No premature type coercion.** The parser does not know the target language's type system. A value like `"42"` might be an integer, a string ID, or a port number. That decision belongs to the step handler.

2. **Mutation model simplicity.** The mutator applies string-based rules: detect if a string looks like an integer, boolean, date, etc., then mutate accordingly. Mixed types would require type-aware mutation logic for each possible language.

3. **Cross-language portability.** JSON types (number, boolean) have different precision and semantics across languages. Strings are universally lossless.

### Why This Matters

If a parser stores `42` as a JSON number instead of `"42"`, the mutator's integer detection rule would need to handle both strings and numbers. The runtime's placeholder resolution would need type-aware substitution. The IR would no longer be a stable contract — it would vary based on what the parser guesses about types.

### Examples

**Incorrect (values stored as native JSON types instead of strings):**

```json
{
  "input": 42,
  "enabled": true,
  "expected_status": "accepted"
}
```

**Correct (all values stored as strings regardless of apparent type):**

```json
{
  "input": "42",
  "enabled": "true",
  "expected_status": "accepted"
}
```
