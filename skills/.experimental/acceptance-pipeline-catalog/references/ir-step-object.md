---
title: Structure Step Objects Correctly
impact: CRITICAL
impactDescription: wrong step representation breaks handler matching for all steps and parameter resolution, causing 100% failure on affected scenarios
tags: ir, json, step, keyword, text, parameters
---

## Structure Step Objects Correctly

The step object is the atomic unit of specification. It pairs a keyword with descriptive text and optionally lists the parameters (placeholders) found in that text.

### Spec Requirements

```json
{
  "keyword": "Given",
  "text": "the input is <input>",
  "parameters": ["input"]
}
```

**Required fields:**

| Field | Type | Values |
|-------|------|--------|
| `keyword` | string | One of `"Given"`, `"When"`, `"Then"`, `"And"` |
| `text` | string | The step text with placeholders preserved |

**Optional fields:**

| Field | Type | Description |
|-------|------|-------------|
| `parameters` | array of strings | Parameter names in order of appearance; omit or use `[]` when no placeholders |

### Text Is Authoritative

The `parameters` field is **derived from** `text`. Generators and runtimes should treat `text` as the authoritative source and may validate that `parameters` agrees with the placeholders found in `text`.

This means if there is a conflict between `text` and `parameters`, `text` wins. The `parameters` field exists as a convenience — it saves consumers from re-parsing angle brackets.

### Why Parameters Are Ordered and May Repeat

Parameters are recorded in the order they appear because position matters for some tooling. If a step contains `<status>` twice, the parameters array contains `["status", "status"]`. This preserves the template structure faithfully.

### Why This Matters

Step handlers match on the `text` field value. The runtime resolves `<parameter_name>` placeholders in `text` using the current example object. If `text` is wrong (truncated, missing placeholders, merged with keyword), both matching and resolution break.

### Examples

**Incorrect (parameters field disagrees with placeholders in text):**

```json
{
  "keyword": "Given",
  "text": "the input is <input> and output is <output>",
  "parameters": ["input"]
}
```

**Correct (parameters array matches all placeholders in text, in order):**

```json
{
  "keyword": "Given",
  "text": "the input is <input> and output is <output>",
  "parameters": ["input", "output"]
}
```
