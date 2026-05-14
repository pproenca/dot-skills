---
title: Structure Scenario Objects Correctly
impact: CRITICAL
impactDescription: wrong scenario shape breaks execution expansion and mutation targeting, corrupting all test results for affected scenarios
tags: ir, json, scenario, steps, examples
---

## Structure Scenario Objects Correctly

The scenario object represents a single specification scenario. Its shape is identical whether it came from `Scenario:` or `Scenario Outline:` in the Gherkin source. The presence or absence of examples determines execution behavior.

### Spec Requirements

```json
{
  "name": "Scenario name",
  "steps": [
    {
      "keyword": "Given",
      "text": "the input is <input>",
      "parameters": ["input"]
    }
  ],
  "examples": [
    {
      "input": "42"
    }
  ]
}
```

**Required fields:**

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | The scenario name from the declaration |
| `steps` | array | Array of step objects in execution order |
| `examples` | array | Array of example objects (string keys to string values) |

### Empty Examples Behavior

If `examples` is empty (`[]`), the runtime must execute the scenario **once** with an empty example object (`{}`). This means a scenario without examples is not skipped — it still runs, just without parameter substitution.

Scenarios with empty examples **cannot be mutated** because there are no example cell values to change.

### Why This Matters

The unified shape (no `Scenario` vs `Scenario Outline` distinction) means downstream tools have one code path. The `examples` array length tells the runtime how many executions to create and tells the mutator how many mutation candidates exist. This is simpler and more reliable than carrying a type flag through the pipeline.

### Examples

**Incorrect (scenario without examples omits the examples field entirely):**

```json
{
  "name": "Simple scenario",
  "steps": [
    { "keyword": "Given", "text": "the system is ready", "parameters": [] }
  ]
}
```

**Correct (examples field is always present, empty array when no examples):**

```json
{
  "name": "Simple scenario",
  "steps": [
    { "keyword": "Given", "text": "the system is ready", "parameters": [] }
  ],
  "examples": []
}
```
