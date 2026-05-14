---
title: Support Both Scenario Forms
impact: CRITICAL
impactDescription: failing to support both Scenario and Scenario Outline breaks 2 common Gherkin patterns, forcing downstream tools to branch on scenario type
tags: parser, scenario, scenario-outline, gherkin
---

## Support Both Scenario Forms

Scenarios are the core units of specification. The parser must handle both `Scenario:` and `Scenario Outline:` because real-world feature files use both forms. Treating them differently in the IR would force downstream tools to branch on scenario type.

### Spec Requirements

The parser accepts both keywords:

```gherkin
Scenario: <scenario name>
  Given <step text>
  When <step text>
  Then <step text>

Scenario Outline: <scenario name>
  Given <step text containing <parameter_name>>

  Examples:
    | parameter_name |
    | value          |
```

Both forms produce the **same JSON IR shape**. The IR does not distinguish between `Scenario:` and `Scenario Outline:` — the difference is whether the scenario has examples.

### Key Behaviors

- A scenario **with examples** can be mutated (mutations target example cell values).
- A scenario **without examples** is valid, executes once with an empty example object, and cannot be mutated.
- The scenario name is the trimmed text after the keyword.

### Why This Matters

Unifying both forms into one IR shape is a deliberate design choice. It means the generator, runtime, and mutator each have exactly one code path for scenarios. The `Scenario:` vs `Scenario Outline:` distinction is syntactic sugar in the Gherkin source — what matters downstream is whether `examples` is populated.

### Examples

**Incorrect (IR distinguishes Scenario from Scenario Outline with a type field):**

```json
{
  "name": "Addition",
  "type": "scenario_outline",
  "steps": [
    { "keyword": "Given", "text": "the input is <input>", "parameters": ["input"] }
  ],
  "examples": [{ "input": "42" }]
}
```

**Correct (unified IR shape for both forms; presence of examples determines behavior):**

```json
{
  "name": "Addition",
  "steps": [
    { "keyword": "Given", "text": "the input is <input>", "parameters": ["input"] }
  ],
  "examples": [{ "input": "42" }]
}
```
