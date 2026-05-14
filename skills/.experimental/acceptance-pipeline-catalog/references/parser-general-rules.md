---
title: Apply General Parsing Rules
impact: CRITICAL
impactDescription: incorrect whitespace or comment handling produces malformed IR, breaking 4 downstream consumers (generator, runtime, mutator, reporter)
tags: parser, whitespace, comments, blank-lines, ordering
---

## Apply General Parsing Rules

These rules govern how the parser handles whitespace, comments, blank lines, and ordering. They apply across all parsed elements and ensure the parser produces consistent, predictable IR regardless of how the Gherkin file is formatted.

### Spec Requirements

**Blank lines** are ignored. They exist for human readability and carry no semantic meaning.

**Comment lines** — lines whose first non-whitespace character is `#` — are ignored. Comments are not preserved in the IR.

**Leading and trailing whitespace** are ignored before parsing each line. This means indentation is cosmetic — `  Given a step` and `Given a step` parse identically.

**Free-form lines** that do not match any supported syntax are ignored. This allows brief feature descriptions after the `Feature:` line, but they are not preserved in the IR.

**Ordering is preserved.** The parser must preserve the order of:
- Background steps
- Scenarios (in declaration order)
- Steps within each scenario
- Example rows within each examples table

**Key column ordering note:** Example columns become object keys in the JSON IR. Consumers that need deterministic key traversal must sort keys explicitly, because JSON object key order is not guaranteed by all implementations.

### Why Free-Form Lines Are Ignored

Gherkin traditionally supports description blocks after `Feature:` and `Scenario:`. This spec ignores them because they serve no role in the pipeline — the IR, generator, runtime, and mutator never reference descriptions. Silently ignoring them is more practical than erroring, because it lets users write natural Gherkin without the parser rejecting documentation prose.

### Why Ordering Matters

The runtime executes steps in order. Background steps establish preconditions, Given sets up state, When triggers actions, Then asserts results. Reordering would change the test semantics. Similarly, example rows map to mutation IDs by position — reordering rows would produce different mutation IDs for the same data.

### Examples

**Incorrect (comment preserved in IR and indentation changes parse result):**

```gherkin
Feature: Calculator
  # This is a setup comment
  Scenario: Addition
    Given the input is 1
```

```json
{
  "name": "Calculator",
  "comment": "This is a setup comment",
  "scenarios": [...]
}
```

**Correct (comments ignored, indentation is cosmetic, ordering preserved):**

```json
{
  "name": "Calculator",
  "scenarios": [
    {
      "name": "Addition",
      "steps": [
        { "keyword": "Given", "text": "the input is 1", "parameters": [] }
      ],
      "examples": []
    }
  ]
}
```
