---
title: Preserve Parameter Placeholders
impact: CRITICAL
impactDescription: wrong parameter extraction breaks placeholder resolution at runtime, causing 100% failure rate on parameterized scenarios
tags: parser, parameters, placeholders, angle-brackets
---

## Preserve Parameter Placeholders

Parameters are placeholders inside step text that get resolved at runtime using example values. The parser extracts parameter names but does **not** expand them — expansion happens in the runtime. This separation is essential for the mutator, which needs to see the template form of steps.

### Spec Requirements

Parameters appear as angle-bracket placeholders inside step text:

```text
<parameter_name>
```

Parameter names must match this pattern:

```text
[A-Za-z0-9_]+
```

Parsing rules:

- The parser records parameter names in the **order they appear** in each step's text.
- **Repeated** parameter names are preserved as repeated entries in the parameters array.
- Parameters are **not expanded** by the parser. They remain as `<parameter_name>` in the step text.
- Resolution happens in the acceptance runtime using the current example object.

### Example

Given this step:

```gherkin
Then the <status> response contains <status> code
```

The parser produces:

```json
{
  "keyword": "Then",
  "text": "the <status> response contains <status> code",
  "parameters": ["status", "status"]
}
```

### Why the Parser Does Not Expand

If the parser expanded parameters, the IR would contain fully resolved step text — one copy per example row. This would lose the template structure that the mutator needs. The mutator changes example **values**, not step text. It needs to see `<parameter_name>` in the template to know which values are substitutable.

The runtime resolves placeholders at execution time, keeping the IR compact and the mutation model clean.

### Examples

**Incorrect (parser expands placeholders, losing the template structure):**

```json
{
  "keyword": "Then",
  "text": "the accepted response contains accepted code",
  "parameters": []
}
```

**Correct (parser preserves angle-bracket placeholders for runtime resolution):**

```json
{
  "keyword": "Then",
  "text": "the <status> response contains <status> code",
  "parameters": ["status", "status"]
}
```
