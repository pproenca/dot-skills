---
title: Fulfill Runtime Responsibilities
impact: HIGH
impactDescription: the runtime is the execution engine for all 7 responsibilities — errors in any one produce wrong test results across all scenarios
tags: rt, execution, expansion, dispatch, reporting
---

## Fulfill Runtime Responsibilities

The acceptance runtime is the shared execution engine used by generated tests. It sits between the IR and the project step handlers, orchestrating scenario execution. Every generated test delegates to the runtime rather than implementing execution logic directly.

### Spec Requirements

The runtime must:

1. **Load or receive the JSON IR.**
2. **Expand each scenario into scenario executions.** Scenarios with examples produce one execution per row; scenarios without examples produce one execution with an empty example object.
3. **Prepend background steps** to each execution.
4. **Execute steps in order.**
5. **Resolve placeholder values** from the current example object (replacing `<parameter_name>` with the corresponding string value).
6. **Route each step to a project step handler** based on the step's `text` field.
7. **Report failures** — unsupported step, missing value, invalid conversion, or failed assertion must be reported as test failures.

### Why a Shared Runtime

Without a shared runtime, every generated test file would need to implement scenario expansion, background prepending, placeholder resolution, and handler dispatch. This duplicates logic and creates inconsistency risk. The runtime centralizes these responsibilities so the generator only needs to emit the glue that connects the test framework to the runtime.

### Why This Matters

The runtime is where the specification meets the project. If the runtime skips a background step, preconditions are missing. If it fails to resolve a placeholder, step handlers receive raw template text instead of values. If it swallows an unsupported step, the test passes when it should fail. Each of these failures is subtle and hard to diagnose without understanding the runtime's contract.

### Examples

**Incorrect (runtime swallows unsupported step instead of failing the test):**

```json
{
  "step": { "keyword": "When", "text": "I do something undefined" },
  "handler_found": false,
  "result": "skipped"
}
```

**Correct (runtime reports unsupported step as a test failure):**

```json
{
  "step": { "keyword": "When", "text": "I do something undefined" },
  "handler_found": false,
  "result": "failed",
  "error": "No handler registered for step text: 'I do something undefined'"
}
```
