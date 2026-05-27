---
name: acceptance-pipeline-catalog
description: Use when implementing, reviewing, or debugging a Gherkin acceptance-test pipeline with mutation testing. Covers parser, JSON IR, generator, runtime, step handlers, test runner, mutator, value mutation rules, execution, result classification, reporting, project layout, conformance, and agent setup. Based on Uncle Bob's Acceptance Pipeline Specification. Trigger even when the user mentions Gherkin parsing, acceptance test generation, mutation testing for acceptance tests, or building a portable test pipeline.
---

# Robert C. Martin Acceptance Pipeline Best Practices

Language-neutral specification for a portable acceptance-test pipeline: Gherkin feature files to JSON IR to generated acceptance tests to mutation testing. Based on Robert C. Martin's Acceptance Pipeline Specification. Contains ~50 rules across 14 categories, prioritized by impact.

## When to Apply

Reference these rules when:
- Building a Gherkin parser that outputs JSON IR
- Implementing an acceptance test generator from JSON IR
- Writing an acceptance runtime that expands scenarios and dispatches steps
- Implementing mutation testing for acceptance test example values
- Setting up the full pipeline (parser, generator, runner, mutator) in a new project
- Debugging pipeline failures (parse errors, generation issues, mutation classification)

## Pipeline Overview

The pipeline has two modes:

**Normal acceptance run:**
```
feature file -> gherkin parser -> JSON IR -> acceptance generator -> generated tests -> test runner
```

**Mutation run:**
```
feature file -> gherkin parser -> base JSON IR -> mutator (one changed IR per mutation)
  -> generator (tests per mutation) -> test runner (evaluate each) -> mutation report
```

The normal run proves the project satisfies the feature. The mutation run probes whether tests are strong enough to fail when example data changes.

## Rule Categories by Priority

| Priority | Category | Impact | Prefix | Rules |
|----------|----------|--------|--------|-------|
| 1 | Parser | CRITICAL | `parser-` | 9 |
| 2 | JSON IR | CRITICAL | `ir-` | 4 |
| 3 | Generator | CRITICAL | `gen-` | 2 |
| 4 | Runtime | HIGH | `rt-` | 3 |
| 5 | Step Handlers | HIGH | `handler-` | 4 |
| 6 | Test Runner | HIGH | `runner-` | 2 |
| 7 | Mutator Core | HIGH | `mut-` | 4 |
| 8 | Value Mutation Rules | HIGH | `val-` | 10 |
| 9 | Result Classification | HIGH | `result-` | 2 |
| 10 | Conformance | HIGH | `conform-` | 1 |
| 11 | Agent Setup | HIGH | `setup-` | 1 |
| 12 | Mutation Execution | MEDIUM | `exec-` | 4 |
| 13 | Reports | MEDIUM | `report-` | 3 |
| 14 | Project Layout | MEDIUM | `layout-` | 3 |

## Quick Reference

### 1. Parser (CRITICAL)

- [`parser-command-interface`](references/parser-command-interface.md) - Two positional args, exit codes 0/1/2
- [`parser-feature-declaration`](references/parser-feature-declaration.md) - Feature: keyword required, trimmed name
- [`parser-background`](references/parser-background.md) - Optional Background: section with Given/And steps
- [`parser-scenarios`](references/parser-scenarios.md) - Scenario: and Scenario Outline: both supported
- [`parser-steps`](references/parser-steps.md) - Given/When/Then/And keywords, keyword stored separately
- [`parser-parameters`](references/parser-parameters.md) - Angle-bracket placeholders, not expanded by parser
- [`parser-examples-tables`](references/parser-examples-tables.md) - Pipe-delimited tables, header row first
- [`parser-general-rules`](references/parser-general-rules.md) - Blank lines, comments, whitespace, ordering
- [`parser-unsupported-syntax`](references/parser-unsupported-syntax.md) - Tags, rules, localized keywords, doc strings

### 2. JSON IR (CRITICAL)

- [`ir-feature-object`](references/ir-feature-object.md) - name, scenarios, optional background
- [`ir-scenario-object`](references/ir-scenario-object.md) - name, steps, examples arrays
- [`ir-step-object`](references/ir-step-object.md) - keyword, text, optional parameters
- [`ir-example-object`](references/ir-example-object.md) - String-keyed, string-valued maps

### 3. Generator (CRITICAL)

- [`gen-command-interface`](references/gen-command-interface.md) - Two positional args, exit codes 0/1/2
- [`gen-requirements`](references/gen-requirements.md) - Embed IR, no Gherkin parsing, deterministic output

### 4. Runtime (HIGH)

- [`rt-responsibilities`](references/rt-responsibilities.md) - Load IR, expand, dispatch, report
- [`rt-scenario-expansion`](references/rt-scenario-expansion.md) - One execution per example row, background prepended
- [`rt-execution-naming`](references/rt-execution-naming.md) - Scenario name / example index naming convention

### 5. Step Handlers (HIGH)

- [`handler-matching`](references/handler-matching.md) - Match by exact text value, not keyword
- [`handler-world-state`](references/handler-world-state.md) - Fresh world/state per scenario execution
- [`handler-value-handling`](references/handler-value-handling.md) - Fetch, parse, fail on missing/malformed
- [`handler-unsupported`](references/handler-unsupported.md) - Unsupported step text must fail the test

### 6. Test Runner (HIGH)

- [`runner-interface`](references/runner-interface.md) - Input/output contract for the test runner adapter
- [`runner-classification`](references/runner-classification.md) - Three-way: failure, success, infrastructure error

### 7. Mutator Core (HIGH)

- [`mut-command-interface`](references/mut-command-interface.md) - CLI options, exit codes 0/1/2
- [`mut-scope`](references/mut-scope.md) - Only example cell values mutated
- [`mut-identity`](references/mut-identity.md) - Stable deterministic IDs, paths, descriptions
- [`mut-deep-copy`](references/mut-deep-copy.md) - Original IR never modified in place

### 8. Value Mutation Rules (HIGH)

- [`val-rule-order`](references/val-rule-order.md) - 8 rules applied in priority order
- [`val-comma-list`](references/val-comma-list.md) - Comma-delimited list mutation
- [`val-boolean`](references/val-boolean.md) - true/false toggle
- [`val-null`](references/val-null.md) - null/nil/none to dithered string
- [`val-integer`](references/val-integer.md) - Integer plus pseudo-random delta
- [`val-float`](references/val-float.md) - Float plus pseudo-random delta
- [`val-datetime`](references/val-datetime.md) - ISO-8601 date/time shift
- [`val-duration`](references/val-duration.md) - Duration shift preserving syntax
- [`val-string-dither`](references/val-string-dither.md) - Character-level string edits
- [`val-determinism`](references/val-determinism.md) - Pseudo-random, deterministic for fixed input

### 9. Result Classification (HIGH)

- [`result-statuses`](references/result-statuses.md) - killed, survived, error
- [`result-classification-rules`](references/result-classification-rules.md) - Mapping from test outcomes to statuses

### 10. Conformance (HIGH)

- [`conform-checklist`](references/conform-checklist.md) - All 21 validation items

### 11. Agent Setup (HIGH)

- [`setup-checklist`](references/setup-checklist.md) - 15-step installation guide

### 12. Mutation Execution (MEDIUM)

- [`exec-work-directory`](references/exec-work-directory.md) - Per-mutation directory structure
- [`exec-workflow`](references/exec-workflow.md) - Write IR, generate, run, classify
- [`exec-parallelism`](references/exec-parallelism.md) - Concurrent workers, isolated directories
- [`exec-timeout`](references/exec-timeout.md) - Full-run timeout, unfinished = error

### 13. Reports (MEDIUM)

- [`report-text-format`](references/report-text-format.md) - Summary line + per-result lines
- [`report-json-format`](references/report-json-format.md) - JSON object with summary and results array
- [`report-field-requirements`](references/report-field-requirements.md) - Required fields for summary and results

### 14. Project Layout (MEDIUM)

- [`layout-required-paths`](references/layout-required-paths.md) - features/, build/, acceptance/ directories
- [`layout-commands`](references/layout-commands.md) - gherkin-parser, acceptance-generator, gherkin-mutator
- [`layout-scripts`](references/layout-scripts.md) - Normal acceptance and mutation scripts

## How to Use

Read individual reference files for detailed spec requirements and rationale:

- Start with the category relevant to the component you are building
- Each rule file is self-contained with WHY explanations, spec requirements, and examples
- For a new project setup, read [`setup-checklist`](references/setup-checklist.md) first
- For validation, use [`conform-checklist`](references/conform-checklist.md)
- Check [gotchas.md](gotchas.md) for known failure points

## Reference Files

| File | Description |
|------|-------------|
| [metadata.json](metadata.json) | Version and reference information |
| [gotchas.md](gotchas.md) | Known failure points (append-only) |
| [references/](references/) | All rule files organized by prefix |
