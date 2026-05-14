---
title: Structure Feature Objects Correctly
impact: CRITICAL
impactDescription: wrong IR shape breaks 3 consumers (generator, runtime, mutator) simultaneously
tags: ir, json, feature, schema, structure
---

## Structure Feature Objects Correctly

The feature object is the root of the JSON IR. It is the canonical data structure consumed by the generator, runtime, and mutator. Every downstream tool depends on this shape being correct and stable.

### Spec Requirements

```json
{
  "name": "Feature name",
  "background": [
    {
      "keyword": "Given",
      "text": "a configured project state",
      "parameters": []
    }
  ],
  "scenarios": [
    {
      "name": "Scenario name",
      "steps": [],
      "examples": []
    }
  ]
}
```

**Required fields:**

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | The feature name from the `Feature:` declaration |
| `scenarios` | array | Array of scenario objects |

**Optional fields:**

| Field | Type | Description |
|-------|------|-------------|
| `background` | array | Array of step objects; omit or use `[]` when absent |

### Why Background Is Optional

Not every feature has shared setup steps. Making `background` optional keeps the IR minimal for simple features while preserving the structure for features that need it. Consumers should treat a missing `background` field the same as an empty array.

### Why This Matters

The feature object is the integration contract between all pipeline components. The parser writes it. The generator reads it to produce tests. The runtime reads it to execute scenarios. The mutator reads it to create mutations. If any tool writes a different shape, the pipeline breaks silently — tests might run but test the wrong thing.

Pretty-printing the JSON IR is expected (per parser requirements) so that humans can inspect and diff the IR during development.

### Examples

**Incorrect (background stored as nested object instead of step array):**

```json
{
  "name": "Calculator",
  "background": {
    "description": "common setup",
    "steps": [
      { "keyword": "Given", "text": "a configured project state" }
    ]
  },
  "scenarios": []
}
```

**Correct (background is a flat array of step objects at the feature level):**

```json
{
  "name": "Calculator",
  "background": [
    { "keyword": "Given", "text": "a configured project state", "parameters": [] }
  ],
  "scenarios": []
}
```
