# TypeScript

**Version 0.1.0**  
TypeScript Migration Specialist  
May 2026

> **Note:** This document guides agents and LLMs migrating JavaScript code to modern, strict TypeScript.  
> It is the compiled navigation index for the rule set. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Guide for migrating JavaScript codebases to strict, modern TypeScript without a big-bang rewrite, designed for AI agents and LLMs. Contains 42 rules across 7 categories, prioritized by impact from critical (migration setup and strictness ratcheting) to incremental (tooling and build). Each rule includes the reasoning, a production-realistic JavaScript anti-pattern, and the modern TypeScript fix, so an agent can drive an incremental, file-by-file migration that keeps the build green. Covers tsconfig and allowJs strategy, ordered strict-flag enablement, typing public surfaces, replacing any and unsafe casts, runtime boundary validation, JS-to-TS idiom conversion, and build/CI changes.

---

## Table of Contents

1. [Migration Setup & tsconfig](references/_sections.md#1-migration-setup-&-tsconfig) — **CRITICAL**
   - 1.1 [Convert Dependency Leaves Before Their Dependents](references/setup-migrate-leaves-first.md) — CRITICAL (prevents re-typing modules twice)
   - 1.2 [Enable allowJs and checkJs for Incremental Migration](references/setup-allowjs-checkjs-bridge.md) — CRITICAL (enables file-by-file migration without big-bang rewrites)
   - 1.3 [Enable isolatedModules and noEmitOnError for Safe Output](references/setup-noemitonerror-isolatedmodules.md) — MEDIUM-HIGH (prevents emitting broken JavaScript)
   - 1.4 [Prefer ts-expect-error over ts-ignore for Suppressions](references/setup-prefer-ts-expect-error.md) — HIGH (eliminates silently stale suppressions)
   - 1.5 [Set module and moduleResolution to a Modern Pair](references/setup-modern-module-resolution.md) — HIGH (prevents import resolution mismatches)
   - 1.6 [Set skipLibCheck to Silence Third-Party Type Noise](references/setup-skiplibcheck-during-migration.md) — HIGH (reduces error noise from untyped dependencies)
   - 1.7 [Type JS with JSDoc and ts-check Before Renaming](references/setup-jsdoc-before-rename.md) — HIGH (prevents type errors at rename time)
2. [Strictness Ratcheting](references/_sections.md#2-strictness-ratcheting) — **CRITICAL**
   - 2.1 [Enable exactOptionalPropertyTypes to Separate Missing from Undefined](references/strict-exact-optional-property-types.md) — MEDIUM-HIGH (prevents absent-versus-undefined confusion)
   - 2.2 [Enable noImplicitAny to Surface Every Untyped Value](references/strict-no-implicit-any.md) — CRITICAL (eliminates invisible any-debt)
   - 2.3 [Enable noUncheckedIndexedAccess for Index Safety](references/strict-no-unchecked-indexed-access.md) — HIGH (prevents undefined-index crashes)
   - 2.4 [Enable strict Flags One at a Time, Not All at Once](references/strict-enable-flags-incrementally.md) — CRITICAL (reduces error floods to fixable batches)
   - 2.5 [Prioritize strictNullChecks for the Highest Bug Yield](references/strict-prioritize-null-checks.md) — CRITICAL (prevents the most common JS runtime crash)
   - 2.6 [Type Caught Errors as unknown, Not any](references/strict-use-unknown-in-catch.md) — HIGH (prevents unsafe error property access)
3. [Typing Public Surfaces](references/_sections.md#3-typing-public-surfaces) — **HIGH**
   - 3.1 [Annotate Exported Function Signatures Explicitly](references/surface-annotate-exported-signatures.md) — HIGH (prevents silent contract drift)
   - 3.2 [Convert Loose Object Arguments to Named Interfaces](references/surface-interface-for-object-args.md) — HIGH (enables reuse and clearer error messages)
   - 3.3 [Declare Class Field Types Instead of Relying on Assignment](references/surface-type-class-fields.md) — MEDIUM-HIGH (enables strict property initialization checks)
   - 3.4 [Replace JSDoc Type Tags with Real Annotations](references/surface-replace-jsdoc-with-types.md) — MEDIUM-HIGH (eliminates type drift between JSDoc and code)
   - 3.5 [Type Callback and Higher-Order Parameters](references/surface-type-callbacks.md) — HIGH (prevents any-propagation through callbacks)
   - 3.6 [Type Default and Optional Parameters Precisely](references/surface-type-default-params.md) — HIGH (enables caller autocomplete on options)
4. [Replacing any & Unsafe Casts](references/_sections.md#4-replacing-any-&-unsafe-casts) — **HIGH**
   - 4.1 [Avoid Double Assertions That Force Unrelated Types](references/unsafe-avoid-double-assertion.md) — MEDIUM-HIGH (prevents hidden type mismatches)
   - 4.2 [Narrow Values Instead of Using the Non-Null Assertion](references/unsafe-narrow-instead-of-nonnull.md) — MEDIUM (prevents reintroduced null crashes)
   - 4.3 [Replace any with unknown at Untrusted Boundaries](references/unsafe-prefer-unknown-over-any.md) — HIGH (prevents any from spreading through the codebase)
   - 4.4 [Replace as Casts with Narrowing or Validation](references/unsafe-eliminate-as-casts.md) — HIGH (eliminates unverified type assertions)
   - 4.5 [Replace the Function Type with Specific Call Signatures](references/unsafe-replace-function-type.md) — MEDIUM (enables call-site argument checking)
   - 4.6 [Type Dynamic Property Access with Records or Index Signatures](references/unsafe-type-dynamic-property-access.md) — MEDIUM-HIGH (enables typed map-style access)
5. [Runtime Data Validation](references/_sections.md#5-runtime-data-validation) — **MEDIUM-HIGH**
   - 5.1 [Derive Static Types from Runtime Schemas](references/runtime-derive-types-from-schemas.md) — MEDIUM (maintains runtime and compile-time type sync)
   - 5.2 [Parse and Type Environment Variables Once](references/runtime-type-environment-variables.md) — MEDIUM (eliminates scattered env-var reads)
   - 5.3 [Type JSON.parse Results Through Validation](references/runtime-type-json-parse.md) — MEDIUM (prevents untyped JSON propagation)
   - 5.4 [Validate External Data at the Boundary](references/runtime-validate-external-data.md) — MEDIUM-HIGH (prevents malformed-data crashes)
   - 5.5 [Write Type Guards for Untyped Library Returns](references/runtime-type-guards-at-boundaries.md) — MEDIUM (prevents any from untyped libraries spreading)
6. [JS-to-TS Idiom Conversion](references/_sections.md#6-js-to-ts-idiom-conversion) — **MEDIUM**
   - 6.1 [Convert Frozen-Object Enums to const Objects or Unions](references/idiom-enum-to-union-or-const.md) — MEDIUM (preserves literal values for narrowing)
   - 6.2 [Convert Prototype Constructors to class Syntax](references/idiom-prototype-to-class.md) — MEDIUM (enables static analysis of object shapes)
   - 6.3 [Convert require and module.exports to ESM Syntax](references/idiom-require-to-import.md) — MEDIUM (enables typed, tree-shakeable imports)
   - 6.4 [Prefer Named Exports over Default Exports](references/idiom-default-export-to-named.md) — LOW-MEDIUM (enables reliable rename and autocomplete)
   - 6.5 [Replace Manual Existence Guards with Optional Chaining](references/idiom-optional-chaining-over-guards.md) — LOW-MEDIUM (reduces nullable-chain boilerplate)
   - 6.6 [Replace the arguments Object with Rest Parameters](references/idiom-replace-arguments-object.md) — MEDIUM (enables typed variadic arguments)
   - 6.7 [Use import type for Type-Only Imports](references/idiom-type-only-imports.md) — MEDIUM (prevents accidental runtime imports)
7. [Tooling & Build Migration](references/_sections.md#7-tooling-&-build-migration) — **LOW-MEDIUM**
   - 7.1 [Add a Type-Check Step to CI Separate from the Build](references/tooling-typecheck-in-ci.md) — LOW-MEDIUM (prevents shipping unchecked types)
   - 7.2 [Emit Declaration Files for Migrated Libraries](references/tooling-emit-declaration-files.md) — LOW-MEDIUM (preserves types for downstream consumers)
   - 7.3 [Install types Packages Before Casting Library Returns](references/tooling-install-types-packages.md) — LOW-MEDIUM (enables free library type coverage)
   - 7.4 [Provide Ambient Declarations for Untyped Dependencies](references/tooling-declare-untyped-modules.md) — LOW-MEDIUM (enables builds on untyped dependencies)
   - 7.5 [Run TypeScript Directly with tsx Instead of ts-node Flags](references/tooling-use-tsx-over-ts-node.md) — LOW-MEDIUM (eliminates fragile loader configuration)

---

## References

1. [https://www.typescriptlang.org/docs/handbook/migrating-from-javascript.html](https://www.typescriptlang.org/docs/handbook/migrating-from-javascript.html)
2. [https://www.typescriptlang.org/tsconfig/](https://www.typescriptlang.org/tsconfig/)
3. [https://github.com/microsoft/TypeScript/wiki/Performance](https://github.com/microsoft/TypeScript/wiki/Performance)
4. [https://google.github.io/styleguide/tsguide.html](https://google.github.io/styleguide/tsguide.html)
5. [https://effectivetypescript.com/](https://effectivetypescript.com/)
6. [https://www.totaltypescript.com/](https://www.totaltypescript.com/)
7. [https://zod.dev/](https://zod.dev/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |