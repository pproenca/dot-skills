---
title: Implement Runner Adapter Interface
impact: HIGH
impactDescription: incomplete runner output prevents accurate mutation classification, misclassifying up to 100% of error-state mutations as killed or survived
tags: runner, interface, input, output, adapter
---

## Implement Runner Adapter Interface

The test runner adapter wraps the project's test execution mechanism. It provides a uniform interface that the mutator uses to evaluate each mutation. Without this abstraction, the mutator would need project-specific test invocation logic.

### Spec Requirements

**Inputs:**

| Field | Type | Description |
|-------|------|-------------|
| Generated test path | string | Path to generated test file or directory |
| Timeout/cancellation | signal | Mechanism to abort long-running tests |

**Outputs:**

| Field | Type | Description |
|-------|------|-------------|
| `passed?` | boolean | Whether all generated tests passed |
| `output` | string | Combined stdout/stderr or equivalent diagnostic text |
| `error text` | string | Infrastructure error, command failure text, or empty string |
| `duration` | elapsed time | How long the test run took |

### Why These Four Outputs

- **passed?** — The binary signal the mutator needs for killed/survived classification.
- **output** — Diagnostic text shown in the mutation report for survived and error cases, helping developers understand why a mutation was not caught.
- **error text** — Distinguishes infrastructure failures (could not start tests) from test failures (tests ran and failed). This drives the three-way classification.
- **duration** — Enables timeout enforcement and performance reporting.

### Examples

**Incorrect (returns only pass/fail, losing diagnostic and error context):**

```json
{
  "passed": false
}
```

**Correct (returns all four required output fields):**

```json
{
  "passed": false,
  "output": "FAIL: expected 200 but got 404 at step 'the API responds with <status>'",
  "error": "",
  "duration": "1.23s"
}
```

### Why This Matters

The runner adapter is the only component that touches the project's actual test framework. Encapsulating this behind a clean interface means the mutator, normal acceptance script, and any future tooling all share the same test invocation mechanism. Changing test frameworks (e.g., switching from pytest to unittest) only requires updating the adapter.
