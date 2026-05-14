---
title: Include All Required Report Fields
impact: MEDIUM
impactDescription: missing required fields cause CI parsers and dashboards to crash or produce incomplete output
tags: report, fields, requirements, schema, portable
---

## Report Field Requirements

Both text and JSON reports must include specific fields. These requirements ensure that any conforming report consumer can extract the information it needs regardless of which implementation produced the report.

### Summary Fields

| Field | Type | Description |
|-------|------|-------------|
| `Total` | number | Total mutations executed (excludes filtered mutations) |
| `Killed` | number | Mutations where tests failed (detected the change) |
| `Survived` | number | Mutations where tests passed (did not detect the change) |
| `Errors` | number | Mutations where infrastructure failed |

**Invariant:** `Total = Killed + Survived + Errors`

### Result Object Fields

Each result must include:

| Field | Type | Description |
|-------|------|-------------|
| `Mutation.ID` | string | Stable identifier (e.g., `"m1"`) |
| `Mutation.Path` | string | JSON path to the mutated cell |
| `Mutation.Description` | string | Human-readable `path: original -> mutated` |
| `Mutation.Original` | string | Original cell value |
| `Mutation.Mutated` | string | Mutated cell value |
| `Status` | string | One of `"killed"`, `"survived"`, `"error"` |
| `Output` | string | Test runner output (may be empty for killed) |
| `Error` | string | Error text (empty when no error) |
| `Duration` | varies | Elapsed time (implementation-defined format) |

### Why All Fields Are Required

Optional fields in reports create compatibility problems. A CI tool that expects `Mutation.Path` but finds it missing must either crash or produce incomplete dashboards. By requiring all fields (even if some are empty strings), consumers can always destructure the result without null checks.

### Why Duration Is Implementation-Defined

Different languages represent duration differently: nanoseconds (Go), milliseconds (JS), floating-point seconds (Python). Mandating a specific format would be impractical. Implementations should document their duration format and keep it stable.

### Examples

**Incorrect (missing Mutation.Path and Duration fields -- consumer crashes on destructure):**

```json
{
  "summary": { "Total": 1, "Killed": 1, "Survived": 0, "Errors": 0 },
  "results": [
    {
      "Mutation": {
        "ID": "m1",
        "Description": "$.scenarios[0].examples[0].count: 20 -> 27",
        "Original": "20",
        "Mutated": "27"
      },
      "Status": "killed",
      "Output": "FAIL: expected 20, got 27"
    }
  ]
}
```

**Correct (all required fields present, including empty strings for unused fields):**

```json
{
  "summary": { "Total": 1, "Killed": 1, "Survived": 0, "Errors": 0 },
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
      "Output": "FAIL: expected 20, got 27",
      "Error": "",
      "Duration": 125000000
    }
  ]
}
```

### Why This Matters

The report is the pipeline's final output — everything the pipeline produces is summarized here. If the report is incomplete or inconsistent, the developer cannot make informed decisions about test quality. Complete, consistent fields ensure the report serves its purpose: telling the developer exactly which mutations survived and why.
