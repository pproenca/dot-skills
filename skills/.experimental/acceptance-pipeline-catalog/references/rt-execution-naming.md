---
title: Apply Execution Naming Convention
impact: HIGH
impactDescription: inconsistent naming makes test output hard to correlate with scenarios, increasing debugging time per mutation failure
tags: rt, naming, execution, test-output
---

## Apply Execution Naming Convention

Each scenario execution needs a stable, human-readable name for test output, error reporting, and debugging. The naming convention must be deterministic so that test results can be correlated back to specific scenario + example combinations.

### Spec Requirements

Suggested execution naming format:

```text
<scenario name>/example_<one-based-index>
```

- For scenarios **with examples**: `My scenario/example_1`, `My scenario/example_2`, etc.
- For scenarios **without examples**: Use `example_1` or another stable name.

The index is **one-based**, matching human expectations (first example is example 1, not example 0).

### Why One-Based

While the IR uses zero-based indexing for mutation paths (`$.scenarios[0].examples[0]`), execution names use one-based indexing because they appear in test output read by humans. This follows the convention of most test frameworks that number test cases starting from 1.

### Why This Matters

When a mutation test reports "survived" for a specific mutation path, the developer needs to find the corresponding test execution in the output. Consistent naming makes this lookup straightforward. Without a naming convention, each implementation would invent its own scheme, making cross-project debugging harder.

The `/` separator creates a natural hierarchy: scenario name as the group, example index as the specific case. This aligns with test framework conventions for nested test suites.

### Examples

**Incorrect (zero-based indexing, no hierarchy separator):**

```text
Addition_example_0
Addition_example_1
```

**Correct (one-based indexing with hierarchy separator):**

```text
Addition/example_1
Addition/example_2
```
