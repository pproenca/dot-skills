---
title: Structure JSON Reports Correctly
impact: MEDIUM
impactDescription: non-standard JSON structure breaks CI parsers and dashboard integrations that consume report JSON
tags: report, json, format, machine-readable, ci
---

## JSON Report Format

When `--json` is supplied, the mutator emits a structured JSON report suitable for programmatic consumption by CI systems, dashboards, and analysis tools.

### Spec Requirements

```json
{
  "summary": {
    "Total": 2,
    "Killed": 1,
    "Survived": 1,
    "Errors": 0
  },
  "results": [
    {
      "Mutation": {
        "ID": "m1",
        "Path": "$.scenarios[0].examples[0].count",
        "Description": "$.scenarios[0].examples[0].count: 20 -> 27",
        "Original": "20",
        "Mutated": "27"
      },
      "Status": "killed",
      "Output": "<test runner output>",
      "Error": "",
      "Duration": 125000000
    }
  ]
}
```

### Structure

The JSON object has two top-level fields:

- **`summary`** — Aggregate counts for quick evaluation.
- **`results`** — Array of individual mutation results in stable order (by mutation ID).

### Why JSON Report

The text report is for humans; the JSON report is for machines. CI systems can parse the JSON to:
- Fail builds when `Survived > 0`.
- Track mutation kill rates over time.
- Generate HTML dashboards.
- Compare mutation results across branches.

### Key Casing Note

Implementations may choose idiomatic JSON key casing (e.g., `camelCase` or `snake_case` instead of `PascalCase`), but they should **document it and keep it stable**. Changing key casing between versions breaks consumers.

### Examples

**Incorrect (flat array without summary -- consumers must recompute counts):**

```json
[
  { "id": "m1", "status": "killed", "output": "..." },
  { "id": "m2", "status": "survived", "output": "..." }
]
```

**Correct (summary + results structure -- consumers get pre-computed counts and full mutation details):**

```json
{
  "summary": {
    "Total": 2,
    "Killed": 1,
    "Survived": 1,
    "Errors": 0
  },
  "results": [
    {
      "Mutation": {
        "ID": "m1",
        "Path": "$.scenarios[0].examples[0].count",
        "Description": "$.scenarios[0].examples[0].count: 20 -> 27",
        "Original": "20",
        "Mutated": "27"
      },
      "Status": "killed",
      "Output": "<test runner output>",
      "Error": "",
      "Duration": 125000000
    }
  ]
}
```

### Why This Matters

Machine-readable output enables automation. Without a JSON report, CI integration requires parsing the text report with regex — which is fragile and breaks when the text format changes. The JSON report provides a stable contract for tooling.
