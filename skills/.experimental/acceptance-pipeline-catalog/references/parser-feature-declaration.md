---
title: Require Feature Declaration
impact: CRITICAL
impactDescription: missing feature declaration makes the IR unnamed, breaking identification across 3 consumers (generator, runtime, reporter)
tags: parser, feature, declaration, gherkin
---

## Require Feature Declaration

Every feature file must declare a feature. The feature name is the only human-readable identifier that carries through the entire pipeline — from Gherkin source to JSON IR to generated tests to mutation reports. Without it, debugging becomes guesswork.

### Spec Requirements

A feature file must contain a feature declaration:

```gherkin
Feature: <feature name>
```

- The feature name is the **trimmed** text after `Feature:`.
- A **missing** feature declaration is an error (exit code 1).
- If multiple feature declarations appear, a conforming parser should treat that as invalid or use the last declaration consistently. New projects should use exactly one.

### Why This Matters

The feature name flows into the IR's top-level `name` field, which generated tests and mutation reports use for identification. A missing or empty name creates anonymous test suites that are impossible to correlate back to their source feature when multiple features exist.

Requiring exactly one declaration keeps the mapping 1:1 between feature files and IR documents, which simplifies the generator and mutator — they never need to handle multi-feature IR.

### Examples

**Incorrect (missing feature declaration produces unnamed IR):**

```gherkin
Scenario: Login succeeds
  Given a valid user
  When the user logs in
  Then access is granted
```

```json
{
  "name": "",
  "scenarios": [...]
}
```

**Correct (feature declaration provides a named, identifiable IR):**

```gherkin
Feature: User Authentication
  Scenario: Login succeeds
    Given a valid user
    When the user logs in
    Then access is granted
```

```json
{
  "name": "User Authentication",
  "scenarios": [...]
}
```
