# TypeScript

**Version 0.1.0**  
Google  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive TypeScript style guide based on Google's internal standards, designed for AI agents and LLMs. Contains 45 rules across 8 categories, prioritized by impact from critical (module organization, type safety) to incremental (literals and coercion). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Module Organization](references/_sections.md#1-module-organization) — **CRITICAL**
   - 1.1 [Avoid Mutable Exports](references/module-no-mutable-exports.md) — CRITICAL (prevents hard-to-track state mutations)
   - 1.2 [Avoid TypeScript Namespaces](references/module-no-namespaces.md) — CRITICAL (prevents runtime overhead and enables tree-shaking)
   - 1.3 [Minimize Exported API Surface](references/module-export-api-surface.md) — HIGH (reduces coupling and maintenance burden)
   - 1.4 [Use ES6 Modules Exclusively](references/module-es6-modules.md) — CRITICAL (enables tree-shaking and static analysis)
   - 1.5 [Use Import Type for Type-Only Imports](references/module-import-type.md) — HIGH (reduces bundle size by eliminating runtime imports)
   - 1.6 [Use Named Exports Over Default Exports](references/module-named-exports.md) — CRITICAL (catches import typos at compile time)
   - 1.7 [Use Relative Paths for Project Imports](references/module-import-paths.md) — HIGH (improves refactoring flexibility and reduces coupling)
2. [Type Safety](references/_sections.md#2-type-safety) — **CRITICAL**
   - 2.1 [Avoid Empty Object Type](references/types-no-empty-object.md) — HIGH (prevents unexpected type widening)
   - 2.2 [Explicitly Annotate Structural Types](references/types-explicit-structural.md) — CRITICAL (catches type mismatches at declaration site)
   - 2.3 [Handle Nullable Types Correctly](references/types-nullable-patterns.md) — CRITICAL (prevents null reference errors)
   - 2.4 [Never Use the any Type](references/types-no-any.md) — CRITICAL (prevents undetected type errors throughout codebase)
   - 2.5 [Never Use Wrapper Object Types](references/types-no-wrapper-types.md) — CRITICAL (prevents type confusion and boxing overhead)
   - 2.6 [Prefer Interfaces Over Type Aliases for Objects](references/types-prefer-interfaces.md) — CRITICAL (better error messages and IDE performance)
   - 2.7 [Prefer Map and Set Over Index Signatures](references/types-prefer-map-set.md) — HIGH (O(1) operations with proper typing)
   - 2.8 [Use Consistent Array Type Syntax](references/types-array-syntax.md) — HIGH (improves readability and consistency)
3. [Class Design](references/_sections.md#3-class-design) — **HIGH**
   - 3.1 [Always Use Parentheses in Constructor Calls](references/class-constructor-parens.md) — MEDIUM (consistent syntax and prevents parsing ambiguity)
   - 3.2 [Avoid Container Classes with Only Static Members](references/class-no-static-containers.md) — HIGH (reduces unnecessary abstraction and enables tree-shaking)
   - 3.3 [Mark Properties Readonly When Never Reassigned](references/class-readonly-properties.md) — HIGH (prevents accidental mutations and enables optimizations)
   - 3.4 [Never Manipulate Prototypes Directly](references/class-no-prototype-manipulation.md) — HIGH (prevents VM deoptimization and unpredictable behavior)
   - 3.5 [Use Parameter Properties for Constructor Assignment](references/class-parameter-properties.md) — HIGH (reduces boilerplate by 50%)
   - 3.6 [Use TypeScript Private Over Private Fields](references/class-no-private-fields.md) — HIGH (consistent access control without runtime overhead)
4. [Function Patterns](references/_sections.md#4-function-patterns) — **HIGH**
   - 4.1 [Avoid Rebinding this](references/func-avoid-this-rebinding.md) — HIGH (prevents subtle bugs from this binding issues)
   - 4.2 [Prefer Function Declarations Over Expressions](references/func-declarations-over-expressions.md) — HIGH (hoisting enables cleaner code organization)
   - 4.3 [Use Concise Arrow Function Bodies Appropriately](references/func-arrow-concise-bodies.md) — MEDIUM (improves readability for simple transforms)
   - 4.4 [Use Correct Generator Function Syntax](references/func-generator-syntax.md) — MEDIUM (consistent, readable generator definitions)
   - 4.5 [Use Default Parameters Sparingly](references/func-default-parameters.md) — MEDIUM (prevents side effects in parameter defaults)
   - 4.6 [Use Rest Parameters Over arguments](references/func-rest-parameters.md) — HIGH (type-safe variadic functions)
5. [Control Flow](references/_sections.md#5-control-flow) — **MEDIUM-HIGH**
   - 5.1 [Always Include Default Case in Switch](references/control-switch-default.md) — MEDIUM (prevents silent failures on unexpected values)
   - 5.2 [Always Use Braces for Control Structures](references/control-always-use-braces.md) — MEDIUM-HIGH (prevents bugs from misleading indentation)
   - 5.3 [Always Use Triple Equals](references/control-triple-equals.md) — MEDIUM-HIGH (prevents type coercion bugs)
   - 5.4 [Avoid Assignment in Conditional Expressions](references/control-no-assignment-in-condition.md) — MEDIUM (prevents accidental assignment bugs)
   - 5.5 [Prefer for-of Over for-in for Arrays](references/control-for-of-iteration.md) — MEDIUM-HIGH (prevents prototype property enumeration bugs)
6. [Error Handling](references/_sections.md#6-error-handling) — **MEDIUM**
   - 6.1 [Always Throw Error Instances](references/error-throw-errors.md) — MEDIUM (provides stack traces for debugging)
   - 6.2 [Avoid Type and Non-Null Assertions](references/error-avoid-assertions.md) — MEDIUM (prevents hiding type errors)
   - 6.3 [Document Empty Catch Blocks](references/error-empty-catch-comments.md) — MEDIUM (explains intentional error suppression)
   - 6.4 [Type Catch Clause Variables as Unknown](references/error-catch-unknown.md) — MEDIUM (enforces safe error handling)
7. [Naming & Style](references/_sections.md#7-naming-&-style) — **MEDIUM**
   - 7.1 [Avoid Decorative Underscores](references/naming-no-decorative-underscores.md) — MEDIUM (cleaner code without misleading conventions)
   - 7.2 [No I Prefix for Interfaces](references/naming-no-interface-prefix.md) — MEDIUM (cleaner type names without Hungarian notation)
   - 7.3 [Use CONSTANT_CASE for True Constants](references/naming-constants.md) — MEDIUM (distinguishes immutable values from variables)
   - 7.4 [Use Correct Identifier Naming Styles](references/naming-identifier-styles.md) — MEDIUM (improves code readability and consistency)
   - 7.5 [Use Descriptive Names](references/naming-descriptive-names.md) — MEDIUM (improves code maintainability)
8. [Literals & Coercion](references/_sections.md#8-literals-&-coercion) — **LOW-MEDIUM**
   - 8.1 [Avoid Array Constructor](references/literal-array-constructor.md) — LOW-MEDIUM (prevents confusing Array constructor behavior)
   - 8.2 [Use Correct Number Literal Formats](references/literal-number-formats.md) — LOW-MEDIUM (consistent and readable numeric literals)
   - 8.3 [Use Explicit Type Coercion](references/literal-explicit-coercion.md) — LOW-MEDIUM (prevents unexpected coercion behavior)
   - 8.4 [Use Single Quotes for Strings](references/literal-single-quotes.md) — LOW-MEDIUM (consistent string syntax throughout codebase)

---

## References

1. [https://google.github.io/styleguide/tsguide.html](https://google.github.io/styleguide/tsguide.html)
2. [https://www.typescriptlang.org/docs/handbook/](https://www.typescriptlang.org/docs/handbook/)
3. [https://google.github.io/styleguide/jsguide.html](https://google.github.io/styleguide/jsguide.html)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |