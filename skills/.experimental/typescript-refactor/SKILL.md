---
name: typescript-refactor
description: TypeScript refactoring and modernization guidelines from a principal specialist perspective. This skill should be used when refactoring, reviewing, or modernizing TypeScript code to ensure type safety, compiler performance, and idiomatic patterns. Triggers on tasks involving TypeScript type architecture, narrowing, generics, error handling, or migration to modern TypeScript features.
---

# TypeScript Refactor Best Practices

Comprehensive TypeScript refactoring and modernization guide designed for AI agents and LLMs. Contains 43 rules across 8 categories, prioritized by impact to guide automated refactoring, code review, and code generation.

## When to Apply

Reference these guidelines when:
- Refactoring TypeScript code for type safety and maintainability
- Designing type architectures (discriminated unions, branded types, generics)
- Narrowing types to eliminate unsafe `as` casts
- Adopting modern TypeScript 4.x-5.x features (`satisfies`, `using`, const type parameters)
- Optimizing compiler performance in large codebases
- Implementing type-safe error handling patterns
- Reviewing code for TypeScript quirks and pitfalls

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Type Architecture | CRITICAL | `arch-` |
| 2 | Type Narrowing & Guards | CRITICAL | `narrow-` |
| 3 | Modern TypeScript | HIGH | `modern-` |
| 4 | Generic Patterns | HIGH | `generic-` |
| 5 | Compiler Performance | MEDIUM-HIGH | `compile-` |
| 6 | Error Safety | MEDIUM | `error-` |
| 7 | Runtime Patterns | MEDIUM | `perf-` |
| 8 | Quirks & Pitfalls | LOW-MEDIUM | `quirk-` |

## Quick Reference

### 1. Type Architecture (CRITICAL)

- [`arch-discriminated-unions`](references/arch-discriminated-unions.md) — Use discriminated unions over string enums for exhaustive pattern matching
- [`arch-branded-types`](references/arch-branded-types.md) — Use branded types for domain identifiers to prevent value mix-ups
- [`arch-satisfies-over-annotation`](references/arch-satisfies-over-annotation.md) — Use `satisfies` for config objects to preserve literal types
- [`arch-interfaces-over-intersections`](references/arch-interfaces-over-intersections.md) — Extend interfaces instead of intersecting types for better error messages
- [`arch-const-assertion`](references/arch-const-assertion.md) — Use `as const` for immutable literal inference
- [`arch-readonly-by-default`](references/arch-readonly-by-default.md) — Default to readonly types for function parameters and return values
- [`arch-avoid-partial-abuse`](references/arch-avoid-partial-abuse.md) — Avoid `Partial<T>` abuse for builder patterns

### 2. Type Narrowing & Guards (CRITICAL)

- [`narrow-custom-type-guards`](references/narrow-custom-type-guards.md) — Write custom type guards instead of type assertions
- [`narrow-assertion-functions`](references/narrow-assertion-functions.md) — Use assertion functions for precondition checks
- [`narrow-exhaustive-switch`](references/narrow-exhaustive-switch.md) — Enforce exhaustive switch with `never`
- [`narrow-in-operator`](references/narrow-in-operator.md) — Narrow with the `in` operator for interface unions
- [`narrow-eliminate-as-casts`](references/narrow-eliminate-as-casts.md) — Eliminate `as` casts with proper narrowing chains
- [`narrow-typeof-chains`](references/narrow-typeof-chains.md) — Use `typeof` narrowing before property access

### 3. Modern TypeScript (HIGH)

- [`modern-using-keyword`](references/modern-using-keyword.md) — Use the `using` keyword for resource cleanup
- [`modern-const-type-parameters`](references/modern-const-type-parameters.md) — Use const type parameters for literal inference
- [`modern-template-literal-types`](references/modern-template-literal-types.md) — Use template literal types for string patterns
- [`modern-noinfer-utility`](references/modern-noinfer-utility.md) — Use `NoInfer` to control type parameter inference
- [`modern-accessor-keyword`](references/modern-accessor-keyword.md) — Use `accessor` for auto-generated getters and setters
- [`modern-verbatim-module-syntax`](references/modern-verbatim-module-syntax.md) — Enable `verbatimModuleSyntax` for explicit import types

### 4. Generic Patterns (HIGH)

- [`generic-infer-over-annotate`](references/generic-infer-over-annotate.md) — Let TypeScript infer instead of explicit annotation
- [`generic-constrain-dont-overconstrain`](references/generic-constrain-dont-overconstrain.md) — Constrain generics minimally
- [`generic-avoid-distributive-surprises`](references/generic-avoid-distributive-surprises.md) — Control distributive conditional types
- [`generic-mapped-type-utilities`](references/generic-mapped-type-utilities.md) — Build custom mapped types for repeated transformations
- [`generic-return-type-inference`](references/generic-return-type-inference.md) — Preserve return type inference in generic functions

### 5. Compiler Performance (MEDIUM-HIGH)

- [`compile-explicit-return-types`](references/compile-explicit-return-types.md) — Add explicit return types to exported functions
- [`compile-avoid-deep-recursion`](references/compile-avoid-deep-recursion.md) — Avoid deeply recursive type definitions
- [`compile-project-references`](references/compile-project-references.md) — Use project references for monorepo builds
- [`compile-base-types-over-unions`](references/compile-base-types-over-unions.md) — Use base types instead of large union types

### 6. Error Safety (MEDIUM)

- [`error-result-type`](references/error-result-type.md) — Use Result types instead of thrown exceptions
- [`error-exhaustive-error-handling`](references/error-exhaustive-error-handling.md) — Use exhaustive checks for typed error variants
- [`error-typed-catch`](references/error-typed-catch.md) — Type catch clause variables as `unknown`
- [`error-never-for-unreachable`](references/error-never-for-unreachable.md) — Use `never` to mark unreachable code paths
- [`error-discriminated-error-unions`](references/error-discriminated-error-unions.md) — Model domain errors as discriminated unions

### 7. Runtime Patterns (MEDIUM)

- [`perf-union-literals-over-enums`](references/perf-union-literals-over-enums.md) — Use union literals instead of enums
- [`perf-avoid-delete-operator`](references/perf-avoid-delete-operator.md) — Avoid the `delete` operator on objects
- [`perf-object-freeze-const`](references/perf-object-freeze-const.md) — Use `Object.freeze` with `as const` for true immutability
- [`perf-object-keys-narrowing`](references/perf-object-keys-narrowing.md) — Avoid `Object.keys` type widening
- [`perf-map-set-over-object`](references/perf-map-set-over-object.md) — Use `Map` and `Set` over plain objects for dynamic collections

### 8. Quirks & Pitfalls (LOW-MEDIUM)

- [`quirk-excess-property-checks`](references/quirk-excess-property-checks.md) — Understand excess property checks on object literals
- [`quirk-empty-object-type`](references/quirk-empty-object-type.md) — Avoid the `{}` type — it means non-nullish
- [`quirk-type-widening-let`](references/quirk-type-widening-let.md) — Prevent type widening with `let` declarations
- [`quirk-variance-annotations`](references/quirk-variance-annotations.md) — Use variance annotations for generic interfaces
- [`quirk-structural-typing-escapes`](references/quirk-structural-typing-escapes.md) — Guard against structural typing escape hatches

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) — Category structure and impact levels
- [Rule template](assets/templates/_template.md) — Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
