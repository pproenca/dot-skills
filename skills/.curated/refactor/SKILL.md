---
name: refactor
description: Code refactoring best practices based on Martin Fowler's catalog and Clean Code principles (formerly refactoring). This skill should be used when refactoring existing code, improving code structure, reducing complexity, eliminating code smells, or reviewing code for maintainability. Triggers on tasks involving extract method, rename, decompose conditional, reduce coupling, or improve readability.
---

# Fowler/Martin Code Refactoring Best Practices

Comprehensive code refactoring guide based on Martin Fowler's catalog and Clean Code principles, designed for AI agents and LLMs. Contains 43 rules across 8 categories, prioritized by impact to guide automated refactoring and code generation.

## When to Apply

Reference these guidelines when:
- Refactoring existing code to improve maintainability
- Decomposing long methods or large classes
- Reducing coupling between components
- Simplifying complex conditional logic
- Reviewing code for code smells and anti-patterns

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Structure & Decomposition | CRITICAL | `struct-` |
| 2 | Coupling & Dependencies | CRITICAL | `couple-` |
| 3 | Naming & Clarity | HIGH | `name-` |
| 4 | Conditional Logic | HIGH | `cond-` |
| 5 | Abstraction & Patterns | MEDIUM-HIGH | `pattern-` |
| 6 | Data Organization | MEDIUM | `data-` |
| 7 | Error Handling | MEDIUM | `error-` |
| 8 | Micro-Refactoring | LOW | `micro-` |

## Quick Reference

### 1. Structure & Decomposition (CRITICAL)

- `struct-extract-method` - Extract Method for Long Functions
- `struct-single-responsibility` - Apply Single Responsibility Principle
- `struct-extract-class` - Extract Class from Large Class
- `struct-compose-method` - Compose Method for Readable Flow
- `struct-function-length` - Keep Functions Under 20 Lines
- `struct-replace-method-with-object` - Replace Method with Method Object
- `struct-parameter-object` - Introduce Parameter Object

### 2. Coupling & Dependencies (CRITICAL)

- `couple-dependency-injection` - Use Dependency Injection
- `couple-hide-delegate` - Hide Delegate to Reduce Coupling
- `couple-remove-middle-man` - Remove Middle Man When Excessive
- `couple-feature-envy` - Fix Feature Envy by Moving Methods
- `couple-interface-segregation` - Apply Interface Segregation Principle
- `couple-preserve-whole-object` - Preserve Whole Object Instead of Fields

### 3. Naming & Clarity (HIGH)

- `name-intention-revealing` - Use Intention-Revealing Names
- `name-avoid-abbreviations` - Avoid Abbreviations and Acronyms
- `name-consistent-vocabulary` - Use Consistent Vocabulary
- `name-searchable-names` - Use Searchable Names
- `name-avoid-encodings` - Avoid Type Encodings in Names

### 4. Conditional Logic (HIGH)

- `cond-guard-clauses` - Replace Nested Conditionals with Guard Clauses
- `cond-polymorphism` - Replace Conditional with Polymorphism
- `cond-decompose` - Decompose Complex Conditionals
- `cond-consolidate` - Consolidate Duplicate Conditional Fragments
- `cond-special-case` - Introduce Special Case Object
- `cond-lookup-table` - Replace Conditional with Lookup Table

### 5. Abstraction & Patterns (MEDIUM-HIGH)

- `pattern-strategy` - Extract Strategy for Algorithm Variants
- `pattern-template-method` - Use Template Method for Shared Skeleton
- `pattern-factory` - Use Factory for Complex Object Creation
- `pattern-open-closed` - Apply Open-Closed Principle
- `pattern-composition-over-inheritance` - Prefer Composition Over Inheritance
- `pattern-extract-superclass` - Extract Superclass for Common Behavior

### 6. Data Organization (MEDIUM)

- `data-encapsulate-collection` - Encapsulate Collection
- `data-replace-primitive` - Replace Primitive with Object
- `data-encapsulate-record` - Encapsulate Record into Class
- `data-split-variable` - Split Variable with Multiple Assignments
- `data-replace-temp-with-query` - Replace Temp with Query

### 7. Error Handling (MEDIUM)

- `error-exceptions-over-codes` - Use Exceptions Instead of Error Codes
- `error-custom-exceptions` - Create Domain-Specific Exception Types
- `error-fail-fast` - Fail Fast with Preconditions
- `error-separate-concerns` - Separate Error Handling from Business Logic

### 8. Micro-Refactoring (LOW)

- `micro-remove-dead-code` - Remove Dead Code
- `micro-inline-variable` - Inline Trivial Variables
- `micro-simplify-expressions` - Simplify Boolean Expressions
- `micro-rename-for-clarity` - Rename for Clarity

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules
- Individual rules: `references/{prefix}-{slug}.md`

## Full Compiled Document

For the complete guide with all rules expanded: `AGENTS.md`
