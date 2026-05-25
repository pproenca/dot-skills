# TypeScript 6.0 / TSX (React 19)

**Version 1.2.0**  
TypeScript Principal Specialist  
May 2026

---

## Abstract

Comprehensive TypeScript and TSX refactoring and modernization guide designed for AI agents and LLMs. Contains 47 rules across 9 categories, prioritized by impact from critical (type architecture, narrowing) to incremental (quirks and pitfalls). Each rule includes a detailed explanation, a production-realistic example, and an authoritative reference. Current to TypeScript 6.0 and React 19: covers modern TypeScript features (satisfies, using, const type parameters, inferred type predicates, isolatedDeclarations, erasable syntax, with import attributes), React/TSX component and hook typing (ref-as-prop, ComponentProps, discriminated props, synthetic events), compiler performance, and type-safe error handling.

---

## Table of Contents

1. [Type Architecture](references/_sections.md#1-type-architecture) — **CRITICAL**
   - 1.1 [Avoid Partial Type Abuse for Builder Patterns](references/arch-avoid-partial-abuse.md) — HIGH (prevents accessing properties that were never set)
   - 1.2 [Default to Readonly Types](references/arch-readonly-by-default.md) — HIGH (prevents accidental mutation, catches side-effect bugs at compile time)
   - 1.3 [Extend Interfaces Instead of Intersecting Types](references/arch-interfaces-over-intersections.md) — CRITICAL (2-3× faster type-checking, detects property conflicts)
   - 1.4 [Use as const for Immutable Literal Inference](references/arch-const-assertion.md) — HIGH (prevents type widening, enables literal-based narrowing)
   - 1.5 [Use Branded Types for Domain Identifiers](references/arch-branded-types.md) — CRITICAL (prevents cross-domain ID mix-ups at compile time)
   - 1.6 [Use Discriminated Unions Over String Enums](references/arch-discriminated-unions.md) — CRITICAL (eliminates entire classes of invalid state bugs)
   - 1.7 [Use satisfies for Config Objects Instead of Type Annotations](references/arch-satisfies-over-annotation.md) — CRITICAL (preserves literal types while validating structure)
2. [Type Narrowing & Guards](references/_sections.md#2-type-narrowing-&-guards) — **CRITICAL**
   - 2.1 [Eliminate as Casts with Proper Narrowing Chains](references/narrow-eliminate-as-casts.md) — HIGH (removes 80-90% of type assertions through control flow)
   - 2.2 [Enforce Exhaustive Switch with never](references/narrow-exhaustive-switch.md) — CRITICAL (prevents silent fallthrough when union members expand)
   - 2.3 [Narrow with the in Operator for Interface Unions](references/narrow-in-operator.md) — HIGH (eliminates as casts with 1-line property checks)
   - 2.4 [Use Assertion Functions for Precondition Checks](references/narrow-assertion-functions.md) — CRITICAL (narrows types while validating invariants in a single call)
   - 2.5 [Write Custom Type Guards Instead of Type Assertions](references/narrow-custom-type-guards.md) — CRITICAL (eliminates unsafe as casts with runtime-verified narrowing)
3. [Modern TypeScript](references/_sections.md#3-modern-typescript) — **HIGH**
   - 3.1 [Enable verbatimModuleSyntax for Explicit Import Types](references/modern-verbatim-module-syntax.md) — MEDIUM (prevents runtime import of type-only modules)
   - 3.2 [Prefer Erasable Syntax Over Enums and Namespaces](references/modern-erasable-syntax.md) — HIGH (keeps code runnable under Node.js type-stripping)
   - 3.3 [Use Const Type Parameters for Literal Inference](references/modern-const-type-parameters.md) — HIGH (eliminates as const at call sites)
   - 3.4 [Use NoInfer to Control Type Parameter Inference](references/modern-noinfer-utility.md) — MEDIUM-HIGH (prevents incorrect inference from secondary parameters)
   - 3.5 [Use Template Literal Types for String Patterns](references/modern-template-literal-types.md) — MEDIUM-HIGH (eliminates invalid string formats at compile time)
   - 3.6 [Use the using Keyword for Resource Cleanup](references/modern-using-keyword.md) — HIGH (prevents resource leaks by guaranteeing cleanup)
   - 3.7 [Use with Import Attributes Instead of assert](references/modern-import-attributes.md) — MEDIUM (replaces the assert syntax deprecated for removal in TS 7.0)
4. [React & TSX](references/_sections.md#4-react-&-tsx) — **HIGH**
   - 4.1 [Extend Native Element Props Instead of Redeclaring Them](references/tsx-extend-native-props.md) — HIGH (inherits every DOM attribute and prevents prop drift)
   - 4.2 [Model Mutually-Exclusive Props as Discriminated Unions](references/tsx-discriminated-props.md) — HIGH (makes impossible prop combinations a compile error)
   - 4.3 [Pass ref as a Prop Instead of forwardRef](references/tsx-ref-as-prop.md) — HIGH (removes forwardRef boilerplate; ref becomes a normal prop)
   - 4.4 [Type Event Handlers with React Synthetic Event Types](references/tsx-event-handler-types.md) — MEDIUM-HIGH (types event.target/currentTarget and replaces any)
   - 4.5 [Type Props Directly Instead of React.FC](references/tsx-avoid-react-fc.md) — HIGH (makes children opt-in and enables generic components)
   - 4.6 [Type useState and useRef for Nullable and Mutable State](references/tsx-hook-typing.md) — MEDIUM (prevents null-unsafe state assignments and ref access)
5. [Generic Patterns](references/_sections.md#5-generic-patterns) — **HIGH**
   - 5.1 [Build Custom Mapped Types for Repeated Transformations](references/generic-mapped-type-utilities.md) — MEDIUM (eliminates manual type duplication across related interfaces)
   - 5.2 [Constrain Generics Minimally](references/generic-constrain-dont-overconstrain.md) — HIGH (enables wider reuse without sacrificing type safety)
   - 5.3 [Control Distributive Conditional Types](references/generic-avoid-distributive-surprises.md) — MEDIUM-HIGH (prevents unexpected union expansion in type transformations)
   - 5.4 [Preserve Return Type Inference in Generic Functions](references/generic-return-type-inference.md) — MEDIUM (enables precise downstream typing without manual annotation)
6. [Compiler Performance](references/_sections.md#6-compiler-performance) — **MEDIUM-HIGH**
   - 6.1 [Add Explicit Return Types to Exported Functions](references/compile-explicit-return-types.md) — MEDIUM-HIGH (measurably faster incremental builds in large codebases)
   - 6.2 [Avoid Deeply Recursive Type Definitions](references/compile-avoid-deep-recursion.md) — MEDIUM-HIGH (prevents exponential type-checking time and IDE freezes)
   - 6.3 [Enable isolatedDeclarations for Parallel Declaration Emit](references/compile-isolated-declarations.md) — MEDIUM-HIGH (enables per-file .d.ts emit without whole-program checking)
   - 6.4 [Use Base Types Instead of Large Union Types](references/compile-base-types-over-unions.md) — MEDIUM (avoids O(n²) comparison overhead for large unions)
   - 6.5 [Use Project References for Monorepo Builds](references/compile-project-references.md) — MEDIUM (3-10× faster incremental builds in large codebases)
7. [Error Safety](references/_sections.md#7-error-safety) — **MEDIUM**
   - 7.1 [Model Domain Errors as Discriminated Unions](references/error-discriminated-error-unions.md) — MEDIUM (enables precise error handling with full type safety)
   - 7.2 [Type Catch Clause Variables as unknown](references/error-typed-catch.md) — MEDIUM (prevents unsafe property access on caught errors)
   - 7.3 [Use Exhaustive Checks for Typed Error Variants](references/error-exhaustive-error-handling.md) — MEDIUM (prevents silent fallthrough when error variants expand)
   - 7.4 [Use Result Types Instead of Thrown Exceptions](references/error-result-type.md) — MEDIUM (eliminates unhandled exception paths across call sites)
8. [Runtime Patterns](references/_sections.md#8-runtime-patterns) — **MEDIUM**
   - 8.1 [Avoid Object.keys Type Widening](references/perf-object-keys-narrowing.md) — MEDIUM (prevents string[] return type from losing key precision)
   - 8.2 [Avoid the delete Operator on Objects](references/perf-avoid-delete-operator.md) — MEDIUM (prevents V8 deoptimization from hidden class transitions)
   - 8.3 [Use Map and Set Over Plain Objects for Dynamic Collections](references/perf-map-set-over-object.md) — MEDIUM (O(1) operations with better memory and iteration performance)
   - 8.4 [Use Object.freeze with as const for True Immutability](references/perf-object-freeze-const.md) — MEDIUM (prevents both compile-time and runtime mutation)
   - 8.5 [Use Union Literals Instead of Enums](references/perf-union-literals-over-enums.md) — MEDIUM (removes non-erasable runtime emit; enables type-stripping)
9. [Quirks & Pitfalls](references/_sections.md#9-quirks-&-pitfalls) — **LOW-MEDIUM**
   - 9.1 [Avoid the {} Type — It Means Non-Nullish](references/quirk-empty-object-type.md) — LOW-MEDIUM (prevents accepting any non-null value when you mean "empty object")
   - 9.2 [Guard Against Structural Typing Escape Hatches](references/quirk-structural-typing-escapes.md) — LOW-MEDIUM (prevents extra properties from leaking through assignments)
   - 9.3 [Understand Excess Property Checks on Object Literals](references/quirk-excess-property-checks.md) — LOW-MEDIUM (prevents silent extra-property bugs in direct assignments)
   - 9.4 [Use Variance Annotations to Document Generic Intent](references/quirk-variance-annotations.md) — LOW-MEDIUM (documents and enforces intended variance on type parameters)

---

## References

1. [https://www.typescriptlang.org/docs/handbook/](https://www.typescriptlang.org/docs/handbook/)
2. [https://www.typescriptlang.org/docs/handbook/release-notes/typescript-6-0.html](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-6-0.html)
3. [https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-5.html](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-5.html)
4. [https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-8.html](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-8.html)
5. [https://github.com/microsoft/TypeScript/wiki/Performance](https://github.com/microsoft/TypeScript/wiki/Performance)
6. [https://react.dev/learn/typescript](https://react.dev/learn/typescript)
7. [https://react.dev/blog/2024/12/05/react-19](https://react.dev/blog/2024/12/05/react-19)
8. [https://react-typescript-cheatsheet.netlify.app/](https://react-typescript-cheatsheet.netlify.app/)
9. [https://www.totaltypescript.com](https://www.totaltypescript.com)
10. [https://effectivetypescript.com](https://effectivetypescript.com)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |