---
title: Separate Step Keywords from Text
impact: CRITICAL
impactDescription: incorrect step parsing breaks handler matching for all 4 keyword types (Given/When/Then/And) and scenario execution
tags: parser, steps, given, when, then, and, keywords
---

## Separate Step Keywords from Text

Steps are the atomic instructions within scenarios. Each step pairs a keyword with descriptive text. The parser must store these separately because handlers match on text (not keyword), while the keyword carries semantic meaning for human readers and potential tooling.

### Spec Requirements

Supported step keywords:

```text
Given
When
Then
And
```

A step line must be one of:

```gherkin
Given <step text>
When <step text>
Then <step text>
And <step text>
```

Parsing rules:

- The **keyword** is stored separately from the **step text**.
- The **step text** is the trimmed text after the keyword.
- A step outside a background or scenario is an **error** (exit code 1).

### Why Keyword and Text Are Separate

Handlers match by exact `text` value, not by keyword. This means `Given the system is ready` and `And the system is ready` route to the same handler. If keyword and text were merged, handler authors would need to register multiple patterns for the same step.

Storing the keyword separately also preserves the Gherkin author's intent (Given = precondition, When = action, Then = assertion, And = continuation) without burdening the matching logic.

### Error on Orphan Steps

A step that appears outside any Background or Scenario context is structurally invalid — it has no scenario to belong to and no execution context. The parser must reject this rather than silently dropping it, because a dropped step likely means the feature file has a formatting error the author needs to fix.

### Examples

**Incorrect (keyword merged with text, preventing handler matching):**

```json
{
  "keyword": "Given",
  "text": "Given the system is ready"
}
```

**Correct (keyword stored separately, text is keyword-free for handler matching):**

```json
{
  "keyword": "Given",
  "text": "the system is ready"
}
```
