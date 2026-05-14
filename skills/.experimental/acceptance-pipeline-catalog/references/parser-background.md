---
title: Implement Background Step Prepending
impact: CRITICAL
impactDescription: incorrect background handling duplicates or omits shared setup across all scenarios, causing 100% false-pass or false-fail rate on affected features
tags: parser, background, given, setup, gherkin
---

## Implement Background Step Prepending

Background captures shared precondition steps that apply to every scenario in the feature. The parser records background steps so the runtime can prepend them to each scenario execution. Getting this wrong means scenarios either miss shared setup or duplicate it inconsistently.

### Spec Requirements

A feature may contain one optional background:

```gherkin
Background:
  Given <step text>
  And <step text>
```

- Background steps use `Given` and `And` keywords.
- Background steps are recorded in the IR and prepended to every scenario execution by the acceptance runtime (not the parser).
- If multiple background sections are present, portable behavior is undefined. New projects should use at most one.

### Parser Responsibility

The parser stores background steps in the IR's `background` array. It does **not** prepend them to scenarios — that is the runtime's job. This separation matters because the mutator works on the IR and must not mutate background steps. If the parser had already merged backgrounds into scenarios, the mutator would need extra logic to distinguish original steps from background steps.

### Why This Matters

Background exists to eliminate duplication in feature files. When every scenario shares "Given a configured project state," writing it once in Background keeps the feature file DRY. The parser must faithfully capture this structure so the runtime can apply it uniformly.

### Examples

**Incorrect (parser merges background steps into each scenario in the IR):**

```json
{
  "name": "Calculator",
  "scenarios": [
    {
      "name": "Addition",
      "steps": [
        { "keyword": "Given", "text": "a configured project state", "parameters": [] },
        { "keyword": "When", "text": "I add 1 and 2", "parameters": [] },
        { "keyword": "Then", "text": "the result is 3", "parameters": [] }
      ],
      "examples": []
    }
  ]
}
```

**Correct (parser stores background separately; runtime prepends at execution time):**

```json
{
  "name": "Calculator",
  "background": [
    { "keyword": "Given", "text": "a configured project state", "parameters": [] }
  ],
  "scenarios": [
    {
      "name": "Addition",
      "steps": [
        { "keyword": "When", "text": "I add 1 and 2", "parameters": [] },
        { "keyword": "Then", "text": "the result is 3", "parameters": [] }
      ],
      "examples": []
    }
  ]
}
```
