---
name: ruby-refactor-best-practices
description: Ruby refactoring guidelines from community best practices. This skill should be used when refactoring, reviewing, or restructuring Ruby code to improve design, readability, and maintainability. Triggers on tasks involving code smells, method extraction, conditional simplification, coupling reduction, design patterns, or Ruby idiom adoption.
---

# Community Ruby Refactoring Best Practices

Comprehensive refactoring guide for Ruby applications, maintained by the community. Contains 45 rules across 8 categories, prioritized by impact to guide automated refactoring and code generation.

## When to Apply

Reference these guidelines when:
- Refactoring Ruby code to reduce complexity and improve design
- Extracting methods, classes, or value objects from large units
- Simplifying complex conditionals and deep nesting
- Reducing coupling between classes and modules
- Adopting idiomatic Ruby patterns and modern Ruby 3.x features

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Structure & Decomposition | CRITICAL | `struct-` |
| 2 | Conditional Simplification | CRITICAL | `cond-` |
| 3 | Coupling & Dependencies | HIGH | `couple-` |
| 4 | Ruby Idioms | HIGH | `idiom-` |
| 5 | Data & Value Objects | MEDIUM-HIGH | `data-` |
| 6 | Design Patterns | MEDIUM | `pattern-` |
| 7 | Modern Ruby 3.x | MEDIUM | `modern-` |
| 8 | Naming & Readability | LOW-MEDIUM | `name-` |

## Quick Reference

### 1. Structure & Decomposition (CRITICAL)

- [`struct-extract-method`](references/struct-extract-method.md) - Extract Long Methods into Focused Units
- [`struct-extract-class`](references/struct-extract-class.md) - Extract Class for Single Responsibility
- [`struct-parameter-object`](references/struct-parameter-object.md) - Introduce Parameter Object for Long Signatures
- [`struct-compose-method`](references/struct-compose-method.md) - Compose Methods at Single Abstraction Level
- [`struct-replace-method-with-object`](references/struct-replace-method-with-object.md) - Replace Complex Method with Method Object
- [`struct-single-responsibility`](references/struct-single-responsibility.md) - One Reason to Change per Class
- [`struct-flatten-deep-nesting`](references/struct-flatten-deep-nesting.md) - Flatten Deep Nesting with Early Extraction

### 2. Conditional Simplification (CRITICAL)

- [`cond-guard-clauses`](references/cond-guard-clauses.md) - Replace Nested Conditionals with Guard Clauses
- [`cond-decompose-conditional`](references/cond-decompose-conditional.md) - Extract Complex Booleans into Named Predicates
- [`cond-replace-with-polymorphism`](references/cond-replace-with-polymorphism.md) - Replace case/when with Polymorphism
- [`cond-null-object`](references/cond-null-object.md) - Replace nil Checks with Null Object
- [`cond-pattern-matching`](references/cond-pattern-matching.md) - Use Pattern Matching for Structural Conditions
- [`cond-consolidate-duplicates`](references/cond-consolidate-duplicates.md) - Consolidate Duplicate Conditional Fragments

### 3. Coupling & Dependencies (HIGH)

- [`couple-law-of-demeter`](references/couple-law-of-demeter.md) - Enforce Law of Demeter with Delegation
- [`couple-feature-envy`](references/couple-feature-envy.md) - Move Method to Resolve Feature Envy
- [`couple-dependency-injection`](references/couple-dependency-injection.md) - Inject Dependencies via Constructor Defaults
- [`couple-composition-over-inheritance`](references/couple-composition-over-inheritance.md) - Replace Mixin with Composed Object
- [`couple-tell-dont-ask`](references/couple-tell-dont-ask.md) - Tell Objects What to Do, Don't Query Their State
- [`couple-avoid-class-methods-domain`](references/couple-avoid-class-methods-domain.md) - Avoid Class Methods in Domain Logic

### 4. Ruby Idioms (HIGH)

- [`idiom-prefer-enumerable`](references/idiom-prefer-enumerable.md) - Use map/select/reject Over each with Accumulator
- [`idiom-keyword-arguments`](references/idiom-keyword-arguments.md) - Use Keyword Arguments for Clarity
- [`idiom-duck-typing`](references/idiom-duck-typing.md) - Use respond_to? Over is_a? for Type Checking
- [`idiom-predicate-methods`](references/idiom-predicate-methods.md) - Name Boolean Methods with ? Suffix
- [`idiom-respond-to-missing`](references/idiom-respond-to-missing.md) - Always Pair method_missing with respond_to_missing?
- [`idiom-block-yield`](references/idiom-block-yield.md) - Use yield Over block.call for Simple Blocks
- [`idiom-implicit-return`](references/idiom-implicit-return.md) - Omit Explicit return for Last Expression

### 5. Data & Value Objects (MEDIUM-HIGH)

- [`data-value-object`](references/data-value-object.md) - Replace Primitive Obsession with Value Objects
- [`data-define-immutable`](references/data-define-immutable.md) - Use Data.define for Immutable Value Objects
- [`data-encapsulate-collection`](references/data-encapsulate-collection.md) - Encapsulate Collections Behind Domain Methods
- [`data-replace-data-clump`](references/data-replace-data-clump.md) - Replace Data Clumps with Grouped Objects
- [`data-separate-query-command`](references/data-separate-query-command.md) - Separate Query Methods from Command Methods

### 6. Design Patterns (MEDIUM)

- [`pattern-strategy`](references/pattern-strategy.md) - Extract Algorithm Variations into Strategy Objects
- [`pattern-factory`](references/pattern-factory.md) - Use Factory Method to Abstract Object Creation
- [`pattern-template-method`](references/pattern-template-method.md) - Define Algorithm Skeleton with Template Method
- [`pattern-decorator`](references/pattern-decorator.md) - Wrap Objects with Decorator for Added Behavior
- [`pattern-null-object-protocol`](references/pattern-null-object-protocol.md) - Implement Null Object with Full Protocol

### 7. Modern Ruby 3.x (MEDIUM)

- [`modern-pattern-matching`](references/modern-pattern-matching.md) - Use case/in for Structural Pattern Matching
- [`modern-deconstruct-keys`](references/modern-deconstruct-keys.md) - Implement deconstruct_keys for Custom Pattern Matching
- [`modern-endless-methods`](references/modern-endless-methods.md) - Use Endless Method Definition for Simple Methods
- [`modern-hash-pattern-guard`](references/modern-hash-pattern-guard.md) - Use Pattern Matching with Guard Clauses
- [`modern-rightward-assignment`](references/modern-rightward-assignment.md) - Use Rightward Assignment for Pipeline Expressions

### 8. Naming & Readability (LOW-MEDIUM)

- [`name-intention-revealing`](references/name-intention-revealing.md) - Use Intention-Revealing Names
- [`name-consistent-vocabulary`](references/name-consistent-vocabulary.md) - Use One Word per Concept Across Codebase
- [`name-avoid-abbreviations`](references/name-avoid-abbreviations.md) - Spell Out Names Except Universal Abbreviations
- [`name-rename-to-remove-comments`](references/name-rename-to-remove-comments.md) - Rename to Eliminate Need for Comments

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
