---
title: Isolate World State per Execution
impact: HIGH
impactDescription: shared state across executions causes test interference, producing order-dependent failures in ~40% of multi-row scenario tables
tags: handler, world, state, isolation, fresh
---

## Isolate World State per Execution

Each scenario execution gets a fresh world/state object. This isolation is fundamental to test reliability — without it, state from one execution leaks into another, causing order-dependent test results.

### Spec Requirements

1. A scenario execution must get a **fresh** world/state object.
2. Background and scenario steps within the **same execution** share the same world/state object.

This means:
- Background steps set up shared state that scenario steps can read and modify.
- Each example row's execution starts with a clean slate.
- No state carries between different scenario executions.

### Example

For a scenario with 2 example rows:

```text
Execution 1 (row 0): fresh world -> background steps modify world -> scenario steps modify world
Execution 2 (row 1): fresh world -> background steps modify world -> scenario steps modify world
```

Execution 2 does not see any changes made by Execution 1.

### Examples

**Incorrect (shared world object leaks state between executions):**

```python
world = {}  # single instance reused

def run_execution(scenario, example_row):
    # world carries state from prior execution
    run_background(world, scenario.background)
    run_steps(world, scenario.steps, example_row)
```

**Correct (fresh world object per execution prevents interference):**

```python
def run_execution(scenario, example_row):
    world = {}  # fresh per execution
    run_background(world, scenario.background)
    run_steps(world, scenario.steps, example_row)
```

### Why This Matters

Test isolation is a first principle of reliable testing. If Execution 1 adds an item to a list in the world object and Execution 2 reads that list, the test results depend on execution order. This creates flaky tests that pass when run in one order and fail in another — the hardest kind of bug to diagnose.

The fresh-per-execution guarantee means tests are inherently parallelizable (though the spec does not require parallel scenario execution).
