# TypeScript

**Version 0.1.0**  
TypeScript Advanced Patterns  
May 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Advanced TypeScript patterns for library/DSL authors and app developers building on top of the type system. Contains 40 rules across 5 categories, prioritised by impact from critical (library/DSL API design) to incremental (declaration & module system). Each rule includes detailed explanations, production-realistic incorrect vs. correct examples, when-NOT-to-apply guidance, and scope deltas relative to overlapping rules in `typescript-refactor` and `.curated/typescript`. Covers type-level programming (recursive conditionals, tail-recursion accumulator, infer-extends, key remapping, variadic tuples, type-level strings, type-level tests, HKT emulation), library/DSL patterns (fluent builders with phantom state, typed event emitters, route param extraction, schema-first inference, type-safe query builders), modern TS 5.x features at depth (Stage 3 decorators, using disposal ordering, const-T in overloads, NoInfer disambiguation, variance debugging, method-vs-property bivariance, phantom capabilities), feature implementation patterns (tagged Result, FSM transitions, schema-derived API clients, form builders, assertNever), and declaration/module system topics (module augmentation, declaration merging, ambient asset modules, library publishing via exports/typesVersions).

---

## Table of Contents

1. [Library Author / DSL Patterns](references/_sections.md#1-library-author-/-dsl-patterns) — **CRITICAL**
   - 1.1 [Build Typed Event Emitters with Mapped Event Maps](references/dsl-typed-event-emitter.md) — CRITICAL (prevents 100% of event-name typos and payload-shape drift at compile time)
   - 1.2 [Choose Overloads Over Conditional Return Types](references/dsl-overloads-vs-conditional-returns.md) — CRITICAL (produces better error messages and 2-5× faster type-checking at call sites; preserves narrowing)
   - 1.3 [Derive Static Types from Runtime Schemas](references/dsl-schema-first-inference.md) — CRITICAL (eliminates 100% of type/runtime drift between validators and TypeScript types)
   - 1.4 [Encode Query Shape in the Builder's Return Type](references/dsl-type-safe-query-builder.md) — CRITICAL (prevents 100% of column-name and result-shape mismatches at the call site)
   - 1.5 [Enforce Builder Call Order with Phantom State Types](references/dsl-fluent-builder-phantom-state.md) — CRITICAL (prevents 100% of out-of-order builder calls at compile time)
   - 1.6 [Export Only the API Surface, Not Internal Helpers](references/dsl-narrow-api-surface.md) — CRITICAL (prevents 100% of downstream coupling to internal types; enables internal refactors without major-version bumps)
   - 1.7 [Infer Route Parameters from Path Patterns](references/dsl-route-param-inference.md) — CRITICAL (prevents 100% of param-name drift between route declarations and handlers)
   - 1.8 [Type Object Path Access with Dot-Notation Inference](references/dsl-type-safe-object-paths.md) — CRITICAL (prevents 100% of broken dot-paths at compile time; enables full autocomplete on nested objects)
2. [Type-level Programming](references/_sections.md#2-type-level-programming) — **HIGH**
   - 2.1 [Build Type-Level String Algorithms with Recursive Template Literals](references/tlp-type-level-string-algorithms.md) — HIGH (enables Split/Join/Replace/CamelCase at the type level; eliminates manual string-shape declarations)
   - 2.2 [Constrain `infer` with `extends` for Validated Extraction](references/tlp-infer-extends-constraints.md) — HIGH (prevents 100% of unsafe `as` casts after type-level parsing; produces narrowed primitives instead of `string`)
   - 2.3 [Control Distribution with the `[T] extends [U]` Tuple Trick](references/tlp-distributive-conditional-control.md) — HIGH (prevents 100% of accidental union distribution in helpers; preserves whole-union semantics where needed)
   - 2.4 [Emulate Higher-Kinded Types with Interface Dictionaries](references/tlp-hkt-emulation.md) — HIGH (enables generic-over-container abstractions (Functor, Monad, Traversable) without needing native HKTs)
   - 2.5 [Match Structured Strings with `infer` in Template Literals](references/tlp-template-literal-pattern-matching.md) — HIGH (enables URL, CSS, format-string parsing at the type level; eliminates runtime regex for shape extraction)
   - 2.6 [Remap Keys with `as` Clauses in Mapped Types](references/tlp-key-remapping-as.md) — HIGH (enables rename, filter, and prefix operations in a single mapped type; replaces multi-pass type pipelines)
   - 2.7 [Test Types with `Equal`, `Expect`, and `@ts-expect-error`](references/tlp-type-level-tests.md) — HIGH (catches 100% of regressions in type-level code at CI time, not at the next call site)
   - 2.8 [Use Recursive Conditional Types for Structural Transformations](references/tlp-recursive-conditional-types.md) — HIGH (enables deep transformations (DeepReadonly, DeepPartial, NonNullableDeep) that would otherwise require code generation)
   - 2.9 [Use Tail-Recursion Accumulator Pattern to Bypass the 50-Step Limit](references/tlp-tail-recursion-accumulator.md) — HIGH (20× recursion-depth ceiling (50 to ~1000 steps); prevents "Type instantiation is excessively deep" on long tuples and strings)
   - 2.10 [Use Variadic Tuples for Position-Aware Type Algorithms](references/tlp-variadic-tuple-types.md) — HIGH (enables typing of curry, compose, concat, and reverse without combinatorial overload explosion)
3. [Modern Features at Depth](references/_sections.md#3-modern-features-at-depth) — **HIGH**
   - 3.1 [Combine `satisfies` with Branded Types for Validated Configuration](references/mod-satisfies-branded-config.md) — HIGH (catches 100% of structural drift on config objects without widening to the declared type)
   - 3.2 [Compose `using` Resources with Explicit Disposal Ordering](references/mod-using-disposal-ordering.md) — HIGH (prevents resource leaks in 100% of composed scopes; guarantees LIFO disposal even on exception paths)
   - 3.3 [Debug Variance Errors with `in` / `out` Annotations](references/mod-variance-debugging.md) — HIGH (prevents 100% of unintended variance inference; moves errors from consumer call sites to declaration sites)
   - 3.4 [Prefer Property Syntax Over Method Syntax to Avoid Bivariance Holes](references/mod-method-vs-property-bivariance.md) — HIGH (prevents 100% of unsound function-parameter assignability on interface members)
   - 3.5 [Track Capabilities at the Type Level with Phantom Brands](references/mod-phantom-capability-tracking.md) — HIGH (enables compile-time "you must do X before Y" enforcement; prevents 100% of unauthorised-use bugs at the type layer)
   - 3.6 [Use `const T` to Preserve Literals Through Overloaded APIs](references/mod-const-type-params-overloads.md) — HIGH (eliminates 100% of widening losses at overload-heavy call sites; removes the need for `as const` at every call)
   - 3.7 [Use `NoInfer<T>` to Disambiguate Overloaded Function Signatures](references/mod-noinfer-overload-disambiguation.md) — HIGH (prevents 100% of "argument leaked into inferred default" bugs in multi-parameter generics)
   - 3.8 [Use Stage 3 Decorators with Decorator Context for Metaprogramming](references/mod-stage-3-decorators.md) — HIGH (prevents 100% of legacy-decorator type holes (`any` parameters); removes dependency on `experimentalDecorators` flag)
4. [Feature Implementation Patterns](references/_sections.md#4-feature-implementation-patterns) — **MEDIUM-HIGH**
   - 4.1 [Derive Client Argument and Return Types from Endpoint Schemas](references/impl-schema-derived-api-client.md) — MEDIUM-HIGH (eliminates 100% of input/output drift between client and server; prevents serialisation mismatches)
   - 4.2 [Drive Form-Field Inference from a Single Schema Definition](references/impl-type-safe-form-builder.md) — MEDIUM-HIGH (prevents 100% of field-name drift between forms, validators, and submission payloads)
   - 4.3 [Encode FSM Transitions in Function Signatures](references/impl-finite-state-machine.md) — MEDIUM-HIGH (prevents 100% of illegal state transitions at the call site; eliminates "guard everywhere" runtime checks)
   - 4.4 [Gate Feature-Dependent Code with Phantom Capability Types](references/impl-phantom-feature-flags.md) — MEDIUM-HIGH (prevents 100% of "forgot the flag check" bugs at gated code sites; lets the type system enforce the gate)
   - 4.5 [Model Operation Outcomes as `Ok<T> | Err<E>` Tagged Unions](references/impl-tagged-result-type.md) — MEDIUM-HIGH (forces 100% of error paths to be handled at the call site; eliminates `throw`-based control flow)
   - 4.6 [Model Workflow State as a Discriminated Union of State Records](references/impl-state-discriminated-union.md) — MEDIUM-HIGH (prevents 100% of illegal-state-combination bugs (loading + error simultaneously, success + no data))
   - 4.7 [Use `assertNever` to Force Exhaustive Handling of Union Variants](references/impl-assert-never-exhaustive.md) — MEDIUM-HIGH (prevents 100% of "added variant, forgot a handler" regressions across the codebase)
   - 4.8 [Validate Environment Configuration at Boundary with Schema Inference](references/impl-env-config-loader.md) — MEDIUM-HIGH (prevents 100% of misconfigured-env runtime crashes; pushes errors to startup rather than first-request)
5. [Declaration & Module System](references/_sections.md#5-declaration-&-module-system) — **MEDIUM**
   - 5.1 [Augment Third-Party Module Types Without Patching Source](references/decl-module-augmentation.md) — MEDIUM (enables typed access to runtime-added properties without forking type definitions)
   - 5.2 [Author `.d.ts` Files for Plain JavaScript Libraries](references/decl-authoring-d-ts-for-js.md) — MEDIUM (prevents 100% of `any`-typed access to JS-only libraries; eliminates per-call-site casts)
   - 5.3 [Declare Ambient Modules for Non-TypeScript Asset Imports](references/decl-ambient-asset-modules.md) — MEDIUM (enables typed `import` of SVGs, CSS modules, images, and binary assets without per-file casts)
   - 5.4 [Merge Interface, Namespace, and Class Declarations to Extend APIs](references/decl-declaration-merging.md) — MEDIUM (enables extensible plugin systems, registry patterns, and library-style API surfaces)
   - 5.5 [Scope Global Type Augmentation to Avoid Conflicts](references/decl-global-augmentation-discipline.md) — MEDIUM (prevents global type pollution across packages in a monorepo; eliminates 100% of "two packages collide on Window.foo" bugs)
   - 5.6 [Ship Library Types with `exports` and `typesVersions` Maps](references/decl-exports-and-types-versions.md) — MEDIUM (ensures 100% of consumers across CJS/ESM/bundler/node resolve types correctly; prevents "works on my repo" reports)

---

## References

1. [https://www.typescriptlang.org/docs/handbook/2/](https://www.typescriptlang.org/docs/handbook/2/)
2. [https://www.typescriptlang.org/docs/handbook/release-notes/](https://www.typescriptlang.org/docs/handbook/release-notes/)
3. [https://www.totaltypescript.com](https://www.totaltypescript.com)
4. [https://github.com/sindresorhus/type-fest](https://github.com/sindresorhus/type-fest)
5. [https://effectivetypescript.com](https://effectivetypescript.com)
6. [https://zod.dev](https://zod.dev)
7. [https://github.com/tc39/proposal-decorators](https://github.com/tc39/proposal-decorators)
8. [https://nodejs.org/api/packages.html#exports](https://nodejs.org/api/packages.html#exports)
9. [https://arethetypeswrong.github.io/](https://arethetypeswrong.github.io/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |