---
name: uncle-bob-clean-code-best-practices
description: Clean Code principles from Robert C. Martin's seminal handbook. This skill should be used when writing, reviewing, or refactoring code to ensure maintainable, readable, and professional-quality implementations. Triggers on code reviews, refactoring tasks, naming discussions, function design, error handling, and test writing.
---

# Robert C. Martin (Uncle Bob) Clean Code Best Practices

Comprehensive software craftsmanship guide based on Robert C. Martin's "Clean Code: A Handbook of Agile Software Craftsmanship". Contains 45 rules across 8 categories, prioritized by impact to guide code reviews, refactoring decisions, and new development.

## When to Apply

Reference these guidelines when:
- Writing new functions, classes, or modules
- Naming variables, functions, classes, or files
- Reviewing code for maintainability issues
- Refactoring existing code to improve clarity
- Writing or improving unit tests

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Meaningful Names | CRITICAL | `name-` |
| 2 | Functions | CRITICAL | `func-` |
| 3 | Comments | HIGH | `cmt-` |
| 4 | Formatting | HIGH | `fmt-` |
| 5 | Objects and Data Structures | MEDIUM-HIGH | `obj-` |
| 6 | Error Handling | MEDIUM-HIGH | `err-` |
| 7 | Unit Tests | MEDIUM | `test-` |
| 8 | Classes and Systems | MEDIUM | `class-` |

## Quick Reference

### 1. Meaningful Names (CRITICAL)

- [`name-intention-revealing`](references/name-intention-revealing.md) - Use names that reveal intent
- [`name-avoid-disinformation`](references/name-avoid-disinformation.md) - Avoid misleading names
- [`name-meaningful-distinctions`](references/name-meaningful-distinctions.md) - Make meaningful distinctions
- [`name-pronounceable`](references/name-pronounceable.md) - Use pronounceable names
- [`name-searchable`](references/name-searchable.md) - Use searchable names
- [`name-avoid-encodings`](references/name-avoid-encodings.md) - Avoid encodings in names
- [`name-class-noun`](references/name-class-noun.md) - Use noun phrases for class names
- [`name-method-verb`](references/name-method-verb.md) - Use verb phrases for method names

### 2. Functions (CRITICAL)

- [`func-small`](references/func-small.md) - Keep functions small
- [`func-one-thing`](references/func-one-thing.md) - Functions should do one thing
- [`func-abstraction-level`](references/func-abstraction-level.md) - Maintain one level of abstraction
- [`func-minimize-arguments`](references/func-minimize-arguments.md) - Minimize function arguments
- [`func-no-side-effects`](references/func-no-side-effects.md) - Avoid side effects
- [`func-command-query-separation`](references/func-command-query-separation.md) - Separate commands from queries
- [`func-prefer-exceptions`](references/func-prefer-exceptions.md) - Prefer exceptions to error codes
- [`func-dry`](references/func-dry.md) - Do not repeat yourself

### 3. Comments (HIGH)

- [`cmt-express-in-code`](references/cmt-express-in-code.md) - Express yourself in code, not comments
- [`cmt-explain-intent`](references/cmt-explain-intent.md) - Use comments to explain intent
- [`cmt-avoid-redundant`](references/cmt-avoid-redundant.md) - Avoid redundant comments
- [`cmt-avoid-commented-out-code`](references/cmt-avoid-commented-out-code.md) - Delete commented-out code
- [`cmt-warning-consequences`](references/cmt-warning-consequences.md) - Use warning comments for consequences

### 4. Formatting (HIGH)

- [`fmt-vertical-formatting`](references/fmt-vertical-formatting.md) - Use vertical formatting for readability
- [`fmt-horizontal-alignment`](references/fmt-horizontal-alignment.md) - Avoid horizontal alignment
- [`fmt-team-rules`](references/fmt-team-rules.md) - Follow team formatting rules
- [`fmt-indentation`](references/fmt-indentation.md) - Respect indentation rules

### 5. Objects and Data Structures (MEDIUM-HIGH)

- [`obj-data-abstraction`](references/obj-data-abstraction.md) - Hide data behind abstractions
- [`obj-data-object-asymmetry`](references/obj-data-object-asymmetry.md) - Understand data/object anti-symmetry
- [`obj-law-of-demeter`](references/obj-law-of-demeter.md) - Follow the Law of Demeter
- [`obj-avoid-hybrids`](references/obj-avoid-hybrids.md) - Avoid hybrid data-object structures
- [`obj-dto`](references/obj-dto.md) - Use DTOs for data transfer

### 6. Error Handling (MEDIUM-HIGH)

- [`err-use-exceptions`](references/err-use-exceptions.md) - Use exceptions instead of return codes
- [`err-write-try-catch-first`](references/err-write-try-catch-first.md) - Write try-catch-finally first
- [`err-provide-context`](references/err-provide-context.md) - Provide context with exceptions
- [`err-define-by-caller-needs`](references/err-define-by-caller-needs.md) - Define exceptions by caller needs
- [`err-avoid-null`](references/err-avoid-null.md) - Avoid returning and passing null

### 7. Unit Tests (MEDIUM)

- [`test-first-law`](references/test-first-law.md) - Follow the three laws of TDD
- [`test-keep-clean`](references/test-keep-clean.md) - Keep tests clean
- [`test-one-assert`](references/test-one-assert.md) - One assert per test
- [`test-first-principles`](references/test-first-principles.md) - Follow FIRST principles
- [`test-build-operate-check`](references/test-build-operate-check.md) - Use Build-Operate-Check pattern

### 8. Classes and Systems (MEDIUM)

- [`class-small`](references/class-small.md) - Keep classes small
- [`class-cohesion`](references/class-cohesion.md) - Maintain class cohesion
- [`class-organize-for-change`](references/class-organize-for-change.md) - Organize classes for change
- [`class-isolate-from-change`](references/class-isolate-from-change.md) - Isolate classes from change
- [`class-separate-concerns`](references/class-separate-concerns.md) - Separate construction from use

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
