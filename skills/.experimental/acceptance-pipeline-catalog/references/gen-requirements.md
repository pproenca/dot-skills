---
title: Follow Generator Requirements
impact: CRITICAL
impactDescription: violating any of 5 requirements produces tests that do not faithfully represent the IR, causing silent false-pass on all affected scenarios
tags: gen, requirements, determinism, ir-only
---

## Follow Generator Requirements

The generator must produce executable tests that faithfully represent the JSON IR. These five requirements ensure generated tests are correct, reproducible, and independent of the original Gherkin source.

### Spec Requirements

1. **Generated tests must embed or load the JSON IR** supplied to the generator. The tests must work from the IR, not from any other source.

2. **Generated tests must not parse the source Gherkin file.** The IR is the single source of truth for test generation. This ensures mutations applied to the IR are reflected in generated tests without re-parsing.

3. **Generated tests must run every scenario execution** represented by the IR. No scenario or example row may be silently skipped.

4. **Generated tests must fail** when the runtime reports an unsupported step, invalid example value, or failed assertion. Swallowing errors would hide pipeline problems.

5. **The generated output must be deterministic** for a fixed IR. Running the generator twice on the same IR must produce identical test files.

### Why No Gherkin Parsing

This is a key architectural constraint. The mutation workflow modifies the IR, then asks the generator to produce tests from the modified IR. If the generator went back to the Gherkin source, mutations would have no effect — the generated tests would always reflect the original feature file, not the mutated IR.

### Why Determinism

Deterministic output enables diffing generated tests across runs. When a mutation changes one example value, the diff between the original and mutated generated tests should show exactly that change. Non-deterministic generation (random variable names, timestamps in comments) would make such diffing impossible.

### Why This Matters

The generated test format is implementation-specific — the spec does not dictate whether tests are Python, Go, Java, etc. But regardless of format, these five requirements ensure the tests serve their purpose: proving the project satisfies the specification (normal run) and detecting when mutated specifications go unnoticed (mutation run).

### Examples

**Incorrect (generated test re-parses Gherkin source, ignoring IR mutations):**

```json
{
  "generated_test_loads": "features/calculator.feature",
  "uses_parser": true,
  "embeds_ir": false
}
```

**Correct (generated test embeds/loads the JSON IR directly):**

```json
{
  "generated_test_loads": "build/acceptance/calculator.json",
  "uses_parser": false,
  "embeds_ir": true
}
```
