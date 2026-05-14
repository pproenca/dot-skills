---
title: Follow Agent Setup Checklist
impact: HIGH
impactDescription: skipping setup steps produces an incomplete pipeline that fails at runtime, requiring full re-diagnosis of all 15 prerequisite steps
tags: setup, checklist, installation, agent, new-project
---

## Agent Setup Checklist

When installing the acceptance pipeline in a new project, follow these 15 steps in order. Each step builds on the previous ones. Skipping steps produces an incomplete pipeline that fails when first invoked.

### Step-by-Step Installation

**Phase 1: Feature and Parser (steps 1-3)**

1. **Create the feature file.** Create `features/a-feature.feature` with at least one scenario that exercises real project behavior. Use concrete examples — abstract features produce weak tests.

2. **Implement the Gherkin parser.** Build the `gherkin-parser` command that reads the supported Gherkin subset and writes JSON IR. Follow the parser rules (command interface, supported syntax, exit codes).

3. **Implement JSON IR reader/writer.** Build the IR serialization layer used by the parser (writing) and the generator/runtime/mutator (reading). Validate against the IR schema.

**Phase 2: Runtime and Handlers (steps 4-5)**

4. **Implement the acceptance runtime.** Build the engine that expands scenarios, applies backgrounds, resolves placeholders, and dispatches steps to handlers. This is the execution core.

5. **Implement step handlers.** Write a handler for every step text in the feature file. Each handler connects the step's specification language to actual project behavior and assertions.

**Phase 3: Generator and Normal Run (steps 6-8)**

6. **Implement the acceptance generator.** Build the `acceptance-generator` command that reads JSON IR and writes executable tests for the project's test framework.

7. **Add the normal acceptance script.** Create the convenience script that chains parser, generator, and test runner. Verify it follows the four script requirements (stop on failure, create directories, propagate errors, always regenerate from IR).

8. **Run and verify.** Execute the normal acceptance script and confirm generated tests pass. This validates the entire parser-to-test-runner chain.

**Phase 4: Mutation Testing (steps 9-12)**

9. **Implement the mutator.** Build the `gherkin-mutator` command using the same parser, IR, generator, and test runner adapter. Implement value mutation rules, deep copy, stable identity, and result classification.

10. **Add the mutation script.** Create the thin wrapper script that invokes the mutator with the feature file path.

11. **Run and inspect.** Execute the mutation script and inspect survived mutations. Each survived mutation indicates a test gap — the acceptance test does not verify the specific value.

12. **Strengthen tests.** Add or improve acceptance scenarios and assertions until important mutations are killed. Not every mutation needs to be killed, but survived mutations should be conscious decisions, not oversights.

**Phase 5: Quality and Integration (steps 13-15)**

13. **Add unit tests.** Write unit tests for the parser, generator, runtime, and mutator components. These catch implementation bugs independently of acceptance tests.

14. **Add normal acceptance to CI.** Add the normal acceptance script to the project's regular verification workflow (e.g., on every push or PR). This ensures the project always satisfies its feature specifications.

15. **Add mutation to quality workflow.** Add the mutation script to an explicit quality workflow (e.g., nightly or weekly). Mutation testing may be slower than normal verification, so it does not need to run on every push.

### Why This Order

The steps follow dependency order:
- The parser must exist before the generator can read IR.
- The runtime and handlers must exist before generated tests can execute.
- The normal run must work before the mutation run can meaningfully test it.
- Unit tests and CI integration come last because they validate what is already working.

### Examples

**Incorrect (skipping phase 1 -- jumping to generator without a working parser):**

```sh
# Step 1-3: SKIPPED -- no parser, no IR

# Step 6: Try to run generator with a hand-written JSON file
acceptance-generator hand-written.json acceptance/generated/test.go
# Fails: hand-written.json doesn't match IR schema
# Developer wastes hours debugging generator when the real issue is missing parser
```

**Correct (incremental phases -- verify each phase before moving to the next):**

```sh
# Phase 1: Parser
gherkin-parser features/a-feature.feature build/acceptance/a-feature.json
# Verify: build/acceptance/a-feature.json matches IR schema

# Phase 2: Runtime + handlers (unit tested independently)

# Phase 3: Generator + normal run
acceptance-generator build/acceptance/a-feature.json \
  acceptance/generated/a-feature_test.go
go test ./acceptance/generated/...
# Verify: tests pass against base feature

# Phase 4: Mutation testing
gherkin-mutator --feature features/a-feature.feature
# Verify: report shows killed/survived/error counts
```

### Why This Matters

Installing a pipeline incrementally — testing each phase before moving to the next — catches problems early. If the parser output is wrong, the generator will fail. If the runtime does not resolve placeholders, generated tests will fail. Discovering these issues in phase order is much easier than debugging the full pipeline end-to-end.
