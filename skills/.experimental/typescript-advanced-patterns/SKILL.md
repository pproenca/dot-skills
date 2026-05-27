---
name: typescript-advanced-patterns
description: Use this skill when writing, reviewing, or designing advanced TypeScript code — type-level programming, library/DSL APIs, declaration merging, modern language features at depth (decorators, using, const T, NoInfer, variance), and feature implementation patterns built on advanced types. Trigger on tasks involving recursive conditional types, infer patterns, mapped-type key remapping, variadic tuples, fluent builders with phantom state, schema-first inference (Zod/Valibot), end-to-end-typed API clients, finite state machines, module augmentation, and library-publishing concerns. Trigger even when the user does not say "advanced" — if the work involves type-level algorithms, library-author API design, or going beyond surface-level uses of TS 5.x features, this is the skill. Assumes the reader has absorbed the `typescript-refactor` skill — this one extends those patterns at depth, never restates them.
---

# TypeScript Advanced Patterns Best Practices

Type-level programming, library-author idioms, and feature-implementation patterns that go beyond surface uses of TypeScript 5.x. Contains 40 rules across 5 categories, prioritised by impact on consumer codebases.

## When to Apply

Reference these guidelines when:

- Designing a public library or DSL surface (fluent builders, event emitters, route parsers, query builders, schema-derived clients)
- Writing type-level algorithms (recursive conditionals, accumulator pattern, key remapping, variadic tuples, type-level string/number ops, type-level tests)
- Using TS 5.x features in non-trivial ways (Stage 3 decorators, `using` composition, `const T` for overload disambiguation, `NoInfer` for anchor-vs-constrained parameters, variance annotations, the bivariance hole)
- Encoding workflow state, transitions, and capabilities at the type level so illegal states and missing checks are compile errors
- Integrating with the declaration & module system (module augmentation, declaration merging, ambient asset modules, library type publishing via `exports`/`typesVersions`)

## Boundary with neighbouring skills

| Skill | Don't reach for this skill if you need… |
|-------|-----------------------------------------|
| `typescript` (curated) | Compiler performance / tsconfig tuning |
| `typescript-refactor` | General refactoring patterns and modern-TS surface basics |
| `ts-google` | Google-style code style decisions |
| `clean-code-ts-react` | Clean-code principles (naming, function shape, abstraction) |
| `effect-ts` / `opencode-ts` | Effect library-specific patterns |

If a rule in this skill overlaps with one in `typescript-refactor` or `.curated/typescript`, the rule's **Scope delta** section names what this skill adds beyond the simpler version.

## Rule Categories by Priority

| Priority | Category | Impact | Prefix | Rules |
|----------|----------|--------|--------|-------|
| 1 | Library Author / DSL Patterns | CRITICAL | `dsl-` | 8 |
| 2 | Type-level Programming | HIGH | `tlp-` | 10 |
| 3 | Modern Features at Depth | HIGH | `mod-` | 8 |
| 4 | Feature Implementation Patterns | MEDIUM-HIGH | `impl-` | 8 |
| 5 | Declaration & Module System | MEDIUM | `decl-` | 6 |

## Quick Reference

### 1. Library Author / DSL Patterns (CRITICAL)

- [`dsl-fluent-builder-phantom-state`](references/dsl-fluent-builder-phantom-state.md) — Enforce builder call order with phantom state types
- [`dsl-typed-event-emitter`](references/dsl-typed-event-emitter.md) — Build typed event emitters with mapped event maps
- [`dsl-type-safe-object-paths`](references/dsl-type-safe-object-paths.md) — Type object path access with dot-notation inference
- [`dsl-route-param-inference`](references/dsl-route-param-inference.md) — Infer route parameters from path patterns
- [`dsl-schema-first-inference`](references/dsl-schema-first-inference.md) — Derive static types from runtime schemas
- [`dsl-type-safe-query-builder`](references/dsl-type-safe-query-builder.md) — Encode query shape in the builder's return type
- [`dsl-narrow-api-surface`](references/dsl-narrow-api-surface.md) — Export only the API surface, not internal helpers
- [`dsl-overloads-vs-conditional-returns`](references/dsl-overloads-vs-conditional-returns.md) — Choose overloads over conditional return types

### 2. Type-level Programming (HIGH)

- [`tlp-recursive-conditional-types`](references/tlp-recursive-conditional-types.md) — Use recursive conditional types for structural transformations
- [`tlp-tail-recursion-accumulator`](references/tlp-tail-recursion-accumulator.md) — Use tail-recursion accumulator pattern to bypass the 50-step limit
- [`tlp-infer-extends-constraints`](references/tlp-infer-extends-constraints.md) — Constrain `infer` with `extends` for validated extraction
- [`tlp-key-remapping-as`](references/tlp-key-remapping-as.md) — Remap keys with `as` clauses in mapped types
- [`tlp-variadic-tuple-types`](references/tlp-variadic-tuple-types.md) — Use variadic tuples for position-aware type algorithms
- [`tlp-type-level-string-algorithms`](references/tlp-type-level-string-algorithms.md) — Build type-level string algorithms with recursive template literals
- [`tlp-distributive-conditional-control`](references/tlp-distributive-conditional-control.md) — Control distribution with the `[T] extends [U]` tuple trick
- [`tlp-type-level-tests`](references/tlp-type-level-tests.md) — Test types with `Equal`, `Expect`, and `@ts-expect-error`
- [`tlp-template-literal-pattern-matching`](references/tlp-template-literal-pattern-matching.md) — Match structured strings with `infer` in template literals
- [`tlp-hkt-emulation`](references/tlp-hkt-emulation.md) — Emulate higher-kinded types with interface dictionaries

### 3. Modern Features at Depth (HIGH)

- [`mod-stage-3-decorators`](references/mod-stage-3-decorators.md) — Use Stage 3 decorators with decorator context for metaprogramming
- [`mod-using-disposal-ordering`](references/mod-using-disposal-ordering.md) — Compose `using` resources with explicit disposal ordering
- [`mod-const-type-params-overloads`](references/mod-const-type-params-overloads.md) — Use `const T` to preserve literals through overloaded APIs
- [`mod-noinfer-overload-disambiguation`](references/mod-noinfer-overload-disambiguation.md) — Use `NoInfer<T>` to disambiguate overloaded function signatures
- [`mod-variance-debugging`](references/mod-variance-debugging.md) — Debug variance errors with `in`/`out` annotations
- [`mod-method-vs-property-bivariance`](references/mod-method-vs-property-bivariance.md) — Prefer property syntax over method syntax to avoid bivariance holes
- [`mod-phantom-capability-tracking`](references/mod-phantom-capability-tracking.md) — Track capabilities at the type level with phantom brands
- [`mod-satisfies-branded-config`](references/mod-satisfies-branded-config.md) — Combine `satisfies` with branded types for validated configuration

### 4. Feature Implementation Patterns (MEDIUM-HIGH)

- [`impl-tagged-result-type`](references/impl-tagged-result-type.md) — Model operation outcomes as `Ok<T> | Err<E>` tagged unions
- [`impl-state-discriminated-union`](references/impl-state-discriminated-union.md) — Model workflow state as a discriminated union of state records
- [`impl-finite-state-machine`](references/impl-finite-state-machine.md) — Encode FSM transitions in function signatures
- [`impl-schema-derived-api-client`](references/impl-schema-derived-api-client.md) — Derive client argument and return types from endpoint schemas
- [`impl-type-safe-form-builder`](references/impl-type-safe-form-builder.md) — Drive form-field inference from a single schema definition
- [`impl-phantom-feature-flags`](references/impl-phantom-feature-flags.md) — Gate feature-dependent code with phantom capability types
- [`impl-assert-never-exhaustive`](references/impl-assert-never-exhaustive.md) — Use `assertNever` to force exhaustive handling of union variants
- [`impl-env-config-loader`](references/impl-env-config-loader.md) — Validate environment configuration at boundary with schema inference

### 5. Declaration & Module System (MEDIUM)

- [`decl-module-augmentation`](references/decl-module-augmentation.md) — Augment third-party module types without patching source
- [`decl-declaration-merging`](references/decl-declaration-merging.md) — Merge interface, namespace, and class declarations to extend APIs
- [`decl-ambient-asset-modules`](references/decl-ambient-asset-modules.md) — Declare ambient modules for non-TypeScript asset imports
- [`decl-global-augmentation-discipline`](references/decl-global-augmentation-discipline.md) — Scope global type augmentation to avoid conflicts
- [`decl-exports-and-types-versions`](references/decl-exports-and-types-versions.md) — Ship library types with `exports` and `typesVersions` maps
- [`decl-authoring-d-ts-for-js`](references/decl-authoring-d-ts-for-js.md) — Author `.d.ts` files for plain JavaScript libraries

## How to Use

Read individual reference files for detailed explanations, code examples, and "when NOT to apply" guidance:

- [Section definitions](references/_sections.md) — Category structure and impact levels
- [Rule template](assets/templates/_template.md) — Template for adding new rules

Rules cross-link via `[[other-rule-slug]]`; follow them when a related pattern is referenced.

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
