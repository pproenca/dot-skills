---
title: Expand Scenarios into Executions
impact: HIGH
impactDescription: wrong expansion produces missing or duplicate test executions, causing undetected missed scenarios with 100% false-pass rate on affected tests
tags: rt, expansion, examples, background, execution
---

## Expand Scenarios into Executions

Scenario expansion is the process of turning one scenario definition into one or more concrete executions. This is where the parameterized specification becomes concrete test runs.

### Spec Requirements

**With examples:** Create one execution per example row. Each execution uses that row's values for placeholder resolution.

**Without examples:** Create one execution with an empty example object (`{}`). The scenario still runs — it is not skipped.

**Background prepending:** Background steps are prepended to **each** execution. This means:
- If a scenario has 3 example rows and the feature has 2 background steps, each of the 3 executions gets those 2 background steps at the beginning.
- Background and scenario steps within the same execution share the same world/state object.

### Execution Structure

For a scenario with 2 background steps and 3 scenario steps with 2 example rows:

```text
Execution 1: [bg_step_1, bg_step_2, step_1, step_2, step_3] with example row 0
Execution 2: [bg_step_1, bg_step_2, step_1, step_2, step_3] with example row 1
```

### Why Empty Example Object, Not Skip

A scenario without examples is a valid specification — it describes behavior that does not vary. Skipping it would mean untested behavior. Running it once with `{}` means placeholder resolution finds nothing to resolve (no `<param>` in step text, or if present, it would fail as missing — which is correct).

### Why This Matters

The mutation model depends on correct expansion. Mutation IDs reference `$.scenarios[i].examples[j].key` — if expansion does not align with this indexing, mutation results are attributed to the wrong scenario execution.

### Examples

**Incorrect (scenario without examples is skipped entirely):**

```json
{
  "scenario": "Simple check",
  "examples": [],
  "executions_created": 0,
  "result": "skipped"
}
```

**Correct (scenario without examples runs once with empty example object):**

```json
{
  "scenario": "Simple check",
  "examples": [],
  "executions_created": 1,
  "execution_example": {},
  "result": "executed"
}
```
