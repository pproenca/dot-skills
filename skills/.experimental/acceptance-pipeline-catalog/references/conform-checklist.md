---
title: Validate Against Conformance Checklist
impact: HIGH
impactDescription: untested conformance items indicate gaps in the pipeline implementation, risking silent failures across all 21 verification points
tags: conform, validation, checklist, verification
---

## Conformance Checklist

A conforming implementation can be validated with these 21 cases. Each item targets a specific requirement from the spec. Use this checklist to verify that a pipeline implementation is complete and correct.

### Parser Conformance (items 1-5)

1. **Parser accepts supported syntax.** Parser accepts `Feature:`, `Background:`, `Scenario:`, `Scenario Outline:`, supported step keywords (`Given`, `When`, `Then`, `And`), parameter placeholders (`<name>`), and examples tables.

2. **Parser writes correct IR shape.** Parser output matches the JSON IR structure defined in the spec (feature object with name, scenarios array, optional background array; scenario objects with name, steps, examples; step objects with keyword, text, optional parameters).

3. **Parser rejects missing feature.** A file with no `Feature:` declaration produces exit code 1.

4. **Parser rejects orphan examples.** An `Examples:` section outside a scenario produces an error.

5. **Parser rejects cell count mismatch.** An examples data row with a different cell count than the header row produces exit code 1.

### Generator Conformance (items 6-7)

6. **Generator produces deterministic output.** Running the generator twice on the same IR produces identical output files.

7. **Generated tests execute the IR.** Generated tests run the scenarios and examples from the IR they were generated from, not from any other source.

### Runtime Conformance (items 8-11)

8. **Runtime applies backgrounds.** Background steps are prepended to every scenario execution.

9. **Runtime handles empty examples.** Scenarios without examples execute once with an empty example object.

10. **Runtime fails unsupported steps.** A step whose text matches no registered handler fails the current test.

11. **Runtime fails invalid values.** Missing or malformed example values fail the current test.

### Script Conformance (item 12)

12. **Script propagates failures.** The normal acceptance script fails if parsing, generation, or generated tests fail.

### Mutator Conformance (items 13-21)

13. **Mutator targets only example values.** Mutations are generated only for example cell values — not feature names, scenario names, step text, keywords, backgrounds, or headers.

14. **Mutator produces stable identities.** Mutation IDs (`m1`, `m2`, ...), paths (`$.scenarios[i].examples[j].key`), and descriptions are deterministic for a fixed IR.

15. **Mutator applies all value rules.** The mutator correctly applies comma-list, boolean, null-like, integer, floating-point, date/time, duration, and string-dithering mutation rules in priority order.

16. **Mutator deep-copies IR.** Each mutation is applied to a deep copy; the original IR is never modified.

17. **Mutator classifies killed correctly.** Failing generated tests result in `killed` status.

18. **Mutator classifies survived correctly.** Passing generated tests result in `survived` status.

19. **Mutator classifies errors correctly.** Parsing, generation, timeout, and infrastructure failures result in `error` status.

20. **Mutator exit code reflects results.** Exit code 1 when any mutation survived or errored; exit code 0 only when all killed.

21. **Mutator emits stable reports.** Text and JSON reports are emitted in stable order (by mutation ID) with all required fields.

### How to Use This Checklist

Work through items sequentially. Items 1-5 verify the parser foundation. Items 6-7 verify the generator. Items 8-11 verify runtime behavior. Item 12 verifies script integration. Items 13-21 verify the mutation pipeline.

Each item can be validated with a focused test: create a minimal feature file that exercises the specific behavior, run the pipeline, and verify the expected outcome.

### Examples

**Incorrect (item 5 -- parser silently accepts mismatched cell counts):**

```gherkin
Feature: Shopping Cart
  Scenario Outline: Add item
    When I add <item>
    Then cart total is <total>

    Examples:
      | item   | total |
      | apple  | 1.50  | 0.00 |
```

```sh
# Parser exits 0 despite 3 cells in data row vs 2 in header
gherkin-parser features/cart.feature build/acceptance/cart.json
echo $?  # 0 (should be 1)
```

**Correct (item 5 -- parser rejects cell count mismatch with exit code 1):**

```gherkin
Feature: Shopping Cart
  Scenario Outline: Add item
    When I add <item>
    Then cart total is <total>

    Examples:
      | item   | total |
      | apple  | 1.50  | 0.00 |
```

```sh
# Parser detects 3 cells vs 2 headers and exits with error
gherkin-parser features/cart.feature build/acceptance/cart.json
echo $?  # 1
# stderr: "line 8: expected 2 cells, got 3"
```
