---
title: Follow Mutation Execution Workflow
impact: MEDIUM
impactDescription: wrong execution order produces tests from stale IR, misclassifying up to 100% of mutations
tags: exec, workflow, sequence, generate, run, classify
---

## Mutation Execution Workflow

Each mutation follows a four-step workflow. The steps must execute in order because each depends on the previous step's output. Skipping or reordering steps produces incorrect results.

### Spec Requirements

For each mutation:

1. **Write the mutated IR** to `<work-dir>/<mutation-id>/feature.json`.
2. **Generate tests** by invoking the acceptance generator with the mutated IR. Place generated tests under `<work-dir>/<mutation-id>/generated/`.
3. **Run the generated tests** using the test runner adapter.
4. **Classify the result** based on the runner's output (killed, survived, or error).

### Why This Sequence

Each step feeds the next:
- Step 1 produces the IR that step 2 reads.
- Step 2 produces the tests that step 3 runs.
- Step 3 produces the outcome that step 4 classifies.

Reordering is not possible. Skipping step 2 (generating tests) and running old tests would test the base IR, not the mutation. Skipping step 3 (running tests) means no classification data.

### Error Handling

If any of steps 1-3 fails, the mutation is classified as **error** in step 4. The specific failure (IR write failure, generation failure, runner failure) should be captured in the error text for the report.

This means the classify step always executes — it either classifies based on test results or based on the infrastructure failure.

### Examples

**Incorrect (skipping generation -- reuses stale tests from a prior run):**

```sh
# Step 1: Write mutated IR
cp mutated-ir.json build/acceptance-mutation/m1/feature.json

# Step 2: SKIPPED -- reuses old generated tests

# Step 3: Run stale tests (tests reflect base IR, not the mutation)
run-tests acceptance/generated/

# Step 4: Classify -- result is wrong because tests don't reflect mutation
```

**Correct (full four-step sequence -- regenerates tests from mutated IR):**

```sh
# Step 1: Write mutated IR
cp mutated-ir.json build/acceptance-mutation/m1/feature.json

# Step 2: Generate tests from mutated IR
acceptance-generator build/acceptance-mutation/m1/feature.json \
  build/acceptance-mutation/m1/generated/a-feature_test.ext

# Step 3: Run freshly generated tests
run-tests build/acceptance-mutation/m1/generated/

# Step 4: Classify based on actual test outcome
```

### Why This Matters

The workflow is the same for every mutation. The mutator orchestrates it, the generator and runner are invoked as tools. This separation means changing the generator or runner does not require changing the mutator's orchestration logic — only the tool invocation adapters change.
