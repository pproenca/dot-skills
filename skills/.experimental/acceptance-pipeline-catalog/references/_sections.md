# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

---

## 1. Parser (parser)

**Impact:** CRITICAL
**Description:** The Gherkin parser converts feature files into JSON IR. Parser errors propagate to every downstream component, making correct parsing the foundation of the entire pipeline.

## 2. JSON IR (ir)

**Impact:** CRITICAL
**Description:** The JSON Intermediate Representation is the canonical interchange format consumed by generator, runtime, and mutator. Schema errors break all consumers simultaneously.

## 3. Generator (gen)

**Impact:** CRITICAL
**Description:** The acceptance generator converts JSON IR into executable tests. Generator correctness determines whether tests actually exercise the specified behavior.

## 4. Runtime (rt)

**Impact:** HIGH
**Description:** The acceptance runtime expands scenarios, applies backgrounds, resolves placeholders, and dispatches steps to handlers. Runtime errors cause silent test gaps.

## 5. Step Handlers (handler)

**Impact:** HIGH
**Description:** Step handlers bind Gherkin step text to project behavior and assertions. Handler contract violations produce false passes or misleading failures.

## 6. Test Runner (runner)

**Impact:** HIGH
**Description:** The test runner adapter executes generated tests and classifies outcomes. Misclassification (confusing infrastructure errors with test failures) corrupts mutation results.

## 7. Mutator Core (mut)

**Impact:** HIGH
**Description:** The mutator creates deterministic example-value mutations to probe acceptance test strength. Scope and identity errors make mutation results unreproducible or misleading.

## 8. Value Mutation Rules (val)

**Impact:** HIGH
**Description:** Eight type-inference rules applied in priority order determine how example values are mutated. Rule ordering and determinism are essential for reproducible mutation runs.

## 9. Result Classification (result)

**Impact:** HIGH
**Description:** Result classification maps test outcomes to killed/survived/error statuses. Misclassification directly corrupts the mutation score and misleads developers about test quality.

## 10. Conformance (conform)

**Impact:** HIGH
**Description:** Twenty-one testable conformance items validate a complete pipeline implementation. Missing conformance coverage allows non-portable implementations.

## 11. Agent Setup (setup)

**Impact:** HIGH
**Description:** The fifteen-step installation checklist guides agents through setting up the pipeline in a new project. Order matters — later steps depend on earlier ones.

## 12. Mutation Execution (exec)

**Impact:** MEDIUM
**Description:** Mutation execution manages work directories, parallelism, and timeouts for running mutated tests. Isolation failures between workers corrupt results.

## 13. Reports (report)

**Impact:** MEDIUM
**Description:** Text and JSON reports communicate mutation results to developers and CI systems. Format errors break downstream tooling and make results unactionable.

## 14. Project Layout (layout)

**Impact:** MEDIUM
**Description:** Required paths and convenience scripts establish the project structure. Layout errors cause pipeline commands to fail on missing directories or mismatched paths.
