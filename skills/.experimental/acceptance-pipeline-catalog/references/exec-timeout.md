---
title: Enforce Full-Run Timeout
impact: MEDIUM
impactDescription: missing timeout allows runaway mutations to block the pipeline indefinitely, losing all partial results when CI kills the build
tags: exec, timeout, cancellation, error
---

## Timeout Handling

The timeout applies to the entire mutation run, not to individual mutations. When time expires, unfinished mutations are reported as errors rather than silently dropped.

### Spec Requirements

- The `--timeout` flag sets a timeout for the **full mutation run**.
- Duration syntax is implementation-defined but should support seconds.
- When the timeout expires, **unfinished mutations** should be reported as `error` with useful timeout text.

### Why Full-Run Timeout

A per-mutation timeout would require knowing how long each mutation should take — which varies by project, test suite size, and system load. A full-run timeout is simpler: the developer says "I have 5 minutes for mutation testing" and the mutator does as many mutations as it can in that time.

### Why Error, Not Skip

Unfinished mutations are classified as `error` (not silently omitted) because:
1. The report's `total` count must be accurate — omitting mutations would undercount.
2. The exit code must be 1 (not 0) when errors exist — an incomplete run should not be reported as "all killed."
3. The developer needs to know which mutations were not evaluated so they can increase the timeout or reduce the mutation set.

### Example Report Entry

```text
error    $.scenarios[2].examples[0].value: hello -> hallo
  error: mutation timed out after 300s
```

### Examples

**Incorrect (no timeout -- pipeline hangs on a stuck mutation):**

```sh
# No --timeout flag; mutation m3 hangs forever
gherkin-mutator --feature features/a-feature.feature --workers 2
# CI kills the entire job after 30 minutes -- all results lost
```

**Correct (full-run timeout -- unfinished mutations reported as errors):**

```sh
gherkin-mutator --feature features/a-feature.feature --workers 2 --timeout 300s
# After 300s, unfinished mutations are classified as error:
#   error    $.scenarios[2].examples[0].value: hello -> hallo
#     error: mutation timed out after 300s
# Completed mutations retain their real killed/survived status
```

### Why This Matters

Without a timeout, a single slow test or a hanging process blocks the entire mutation pipeline. In CI, this means the build hangs until the CI system's own timeout kills it — losing all partial results. With a proper timeout, partial results are preserved and reported, and the developer gets actionable information about which mutations need investigation.
