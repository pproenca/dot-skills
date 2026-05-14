---
name: clean-code-ts-react
description: Use this skill whenever writing, reviewing, or refactoring TypeScript or React code for craftsmanship — naming, function and component shape, error handling, data modeling, tests, and abstraction. Translates Robert C. Martin's Clean Code principles into modern TS+React idioms (TS 5.x, React 19) and includes first-class "When NOT to apply" guidance plus a Meta category for when principles conflict (DRY vs SRP, small functions vs deep modules, type safety vs ergonomics). Triggers on code review, refactoring for clarity, naming discussions, function/component design, "is this clean?", "make this more readable", "is this the right abstraction?", and craftsmanship-flavored requests. Trigger even when the user doesn't explicitly say "clean code" — any request about code maintainability, readability, or principles qualifies. Does NOT cover React-specific APIs (concurrent rendering, RSC, hooks API surface) — use the `react` skill for that. Does NOT cover TS compiler performance or tsconfig — use the `typescript` skill for that. This skill is about timeless principles applied to modern TS+React, not framework-specific patterns.
---

# Robert C. Martin (Uncle Bob) TypeScript 5.x + React 19 Best Practices

Craftsmanship principles from Robert C. Martin's *Clean Code* (2008), re-expressed for modern TypeScript and React. Contains **61 rules across 11 categories**, prioritized by cognitive cost across a code change's lifetime. Examples use TS 5.x and React 19 idioms — but the rules are about timeless principles, not specific APIs.

## What Makes This Skill Different

Three things set this apart from a generic clean-code copy:

1. **Modern idioms as vehicle.** Examples use TS 5.x (`satisfies`, branded types, discriminated unions, `const` type parameters) and React 19 (function components, hooks, `use()`, Server Components where relevant). But the rule is always the principle, never the syntax.
2. **"When NOT to apply" is first-class.** Every rule has 2-3 concrete scenarios where the principle should bend — not generic disclaimers, real situations. Loop counters can be `i`. Single-use code shouldn't be DRY. Some HOCs are unavoidable.
3. **Meta category for principle conflicts.** Category 11 names the most common tensions explicitly — DRY vs Single Responsibility, small functions vs deep modules (Ousterhout), type precision vs ergonomic APIs, tests as spec vs documentation. The mark of seniority is knowing which to bend.

## When to Apply

Reference these guidelines when:
- Writing new TypeScript or React code and wanting craftsmanship feedback
- Reviewing a pull request for clarity, naming, or abstraction
- Refactoring existing code for readability or maintainability
- Designing function, hook, or component APIs
- Deciding whether to extract, abstract, or duplicate
- Resolving a tension between two clean-code rules (see Category 11)

Skip this skill and use:
- **`react`** for React 19 API patterns (concurrent rendering, Server Components, ref-as-prop, `useActionState`, `<Context>`-as-provider)
- **`typescript`** for compiler performance, tsconfig tuning, type-system perf
- **`refactor`** for mechanical refactoring workflows
- **`tdd`** for the TDD workflow itself

## Rule Categories by Priority

Order reflects **cognitive cost across a change's lifetime** (read → understand → modify → verify → ship → maintain). Earlier stages cascade — bad names taint every read.

| Priority | Category | Impact | Prefix | Rules |
|----------|----------|--------|--------|-------|
| 1 | Meaningful Names | CRITICAL | `name-` | 8 |
| 2 | Functions, Components & Hooks | CRITICAL | `func-` | 8 |
| 3 | Self-Documentation (Types & Comments) | HIGH | `doc-` | 5 |
| 4 | Formatting (Beyond Prettier) | HIGH | `fmt-` | 4 |
| 5 | Error Handling | HIGH | `err-` | 7 |
| 6 | Data Shape & Immutability | MEDIUM-HIGH | `data-` | 6 |
| 7 | Boundaries | MEDIUM-HIGH | `bound-` | 4 |
| 8 | Composition over Inheritance | MEDIUM-HIGH | `comp-` | 6 |
| 9 | Tests | MEDIUM | `test-` | 5 |
| 10 | Emergence & Simple Design | MEDIUM | `emerge-` | 4 |
| 11 | **Meta: When Principles Conflict** | MEDIUM | `meta-` | 4 |

**Total: 61 rules.**

## Quick Reference

### 1. Meaningful Names (CRITICAL)

- [`name-intention-revealing`](references/name-intention-revealing.md) — Use names that reveal intent
- [`name-avoid-disinformation`](references/name-avoid-disinformation.md) — Avoid misleading names
- [`name-meaningful-distinctions`](references/name-meaningful-distinctions.md) — Make meaningful distinctions
- [`name-component-pascal-case`](references/name-component-pascal-case.md) — Components are PascalCase noun phrases
- [`name-hook-use-prefix`](references/name-hook-use-prefix.md) — Hooks are `useX` verb phrases
- [`name-handler-convention`](references/name-handler-convention.md) — Event handlers use `onX` / `handleX`
- [`name-boolean-predicate`](references/name-boolean-predicate.md) — Boolean variables use `is`/`has`/`can`
- [`name-types-pascal-case`](references/name-types-pascal-case.md) — Types and interfaces are PascalCase

### 2. Functions, Components & Hooks (CRITICAL)

- [`func-small`](references/func-small.md) — Keep functions, components & hooks small
- [`func-one-thing`](references/func-one-thing.md) — Do one thing
- [`func-abstraction-level`](references/func-abstraction-level.md) — One level of abstraction per function
- [`func-minimize-arguments`](references/func-minimize-arguments.md) — Prefer object parameters over long lists
- [`func-no-side-effects`](references/func-no-side-effects.md) — Avoid hidden side effects (especially in render)
- [`func-command-query-separation`](references/func-command-query-separation.md) — Separate commands from queries
- [`func-dry`](references/func-dry.md) — DRY — until concepts diverge
- [`func-custom-hook-extract`](references/func-custom-hook-extract.md) — Extract custom hooks for reusable stateful logic

### 3. Self-Documentation: Types & Comments (HIGH)

- [`doc-types-over-comments`](references/doc-types-over-comments.md) — Prefer types over comments
- [`doc-satisfies-narrows-with-check`](references/doc-satisfies-narrows-with-check.md) — Use `satisfies` for inferred-but-checked values
- [`doc-jsdoc-public-api`](references/doc-jsdoc-public-api.md) — JSDoc for public APIs and non-obvious side effects
- [`doc-avoid-redundant-comments`](references/doc-avoid-redundant-comments.md) — Avoid redundant comments
- [`doc-delete-commented-out-code`](references/doc-delete-commented-out-code.md) — Delete commented-out code

### 4. Formatting Beyond Prettier (HIGH)

- [`fmt-vertical-density`](references/fmt-vertical-density.md) — Keep related code close, unrelated far
- [`fmt-newspaper-order`](references/fmt-newspaper-order.md) — Order files top-down like a newspaper
- [`fmt-team-rules-over-preference`](references/fmt-team-rules-over-preference.md) — Team conventions over personal preference
- [`fmt-imports-grouped`](references/fmt-imports-grouped.md) — Group imports by source

### 5. Error Handling (HIGH)

- [`err-early-return`](references/err-early-return.md) — Use early returns to flatten error paths
- [`err-result-vs-throw`](references/err-result-vs-throw.md) — Choose throw vs Result deliberately
- [`err-narrow-unknown`](references/err-narrow-unknown.md) — Always narrow `unknown` in catch blocks
- [`err-error-boundaries`](references/err-error-boundaries.md) — Use error boundaries for render-time failures
- [`err-suspense-for-loading`](references/err-suspense-for-loading.md) — Use Suspense for loading states
- [`err-no-swallow`](references/err-no-swallow.md) — Never swallow errors silently
- [`err-null-vs-undefined`](references/err-null-vs-undefined.md) — Pick `null` OR `undefined` per domain

### 6. Data Shape & Immutability (MEDIUM-HIGH)

- [`data-discriminated-unions-over-flags`](references/data-discriminated-unions-over-flags.md) — Discriminated unions over boolean flags
- [`data-readonly-by-default`](references/data-readonly-by-default.md) — Mark read-only data `readonly`
- [`data-branded-types`](references/data-branded-types.md) — Brand types for domain invariants
- [`data-dto-vs-domain`](references/data-dto-vs-domain.md) — Separate DTOs from domain types
- [`data-demeter-prop-drilling`](references/data-demeter-prop-drilling.md) — Prop drilling often smells like Demeter
- [`data-structural-typing-pitfalls`](references/data-structural-typing-pitfalls.md) — Beware structural typing aliasing

### 7. Boundaries (MEDIUM-HIGH)

- [`bound-wrap-third-party-hooks`](references/bound-wrap-third-party-hooks.md) — Wrap third-party hooks in custom hooks
- [`bound-learning-tests`](references/bound-learning-tests.md) — Write learning tests for third-party behavior
- [`bound-isolate-framework`](references/bound-isolate-framework.md) — Isolate framework-specific code at the edges
- [`bound-type-assertions-at-edges`](references/bound-type-assertions-at-edges.md) — Type assertions belong only at boundaries

### 8. Composition over Inheritance (MEDIUM-HIGH)

- [`comp-children-over-props`](references/comp-children-over-props.md) — Compose with `children` over configuration props
- [`comp-small-components`](references/comp-small-components.md) — Keep components small and cohesive
- [`comp-avoid-hoc-stacks`](references/comp-avoid-hoc-stacks.md) — Avoid higher-order component stacks
- [`comp-context-only-when-needed`](references/comp-context-only-when-needed.md) — Context for DI, not prop avoidance
- [`comp-render-props-vs-hooks`](references/comp-render-props-vs-hooks.md) — Prefer hooks over render props for logic reuse
- [`comp-separate-construction-from-use`](references/comp-separate-construction-from-use.md) — Separate setup from rendering

### 9. Tests (MEDIUM)

- [`test-behavior-not-implementation`](references/test-behavior-not-implementation.md) — Test behavior, not implementation
- [`test-mock-at-boundaries`](references/test-mock-at-boundaries.md) — Mock only at true boundaries
- [`test-first-principles`](references/test-first-principles.md) — Apply FIRST principles
- [`test-one-concept`](references/test-one-concept.md) — One concept (not one assert) per test
- [`test-clean-as-production`](references/test-clean-as-production.md) — Test code deserves production-grade care

### 10. Emergence & Simple Design (MEDIUM)

- [`emerge-four-rules`](references/emerge-four-rules.md) — Apply the four rules of simple design in order
- [`emerge-yagni-types`](references/emerge-yagni-types.md) — Avoid premature type generics
- [`emerge-premature-abstraction`](references/emerge-premature-abstraction.md) — Resist premature abstraction
- [`emerge-reveal-intent`](references/emerge-reveal-intent.md) — Maximize expressiveness — code as communication

### 11. Meta: When Principles Conflict (MEDIUM)

**This is the signature category** — explicit guidance on when one clean-code principle yields to another.

- [`meta-dry-vs-srp`](references/meta-dry-vs-srp.md) — Bend DRY when concepts drift apart
- [`meta-small-vs-deep`](references/meta-small-vs-deep.md) — Small functions lose to deep modules when indirection > comprehension
- [`meta-types-vs-ergonomics`](references/meta-types-vs-ergonomics.md) — Type safety loses to ergonomics at stable boundaries
- [`meta-tests-as-spec-vs-doc`](references/meta-tests-as-spec-vs-doc.md) — Pick tests-as-spec or tests-as-documentation per file

## How to Use

For an ad-hoc question ("is this naming OK?", "should I extract this?"), jump straight to the relevant rule file via the Quick Reference above.

For a code review or refactor, scan the categories in priority order — names and function shape first (highest cascade), then errors and data shape, then composition and tests. The category-major sweep is more efficient than file-major.

When two principles seem to disagree, read the corresponding Meta rule (Category 11). Pick the principle that wins, and document the call.

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for adding new rules |
| [metadata.json](metadata.json) | Version and reference information |

## Related Skills

- `.experimental/clean-code` — Original language-agnostic clean code (Java examples). This skill is the TS+React sibling.
- `.curated/react` — React 19-specific patterns (Server Components, concurrent rendering, ref-as-prop).
- `.curated/typescript` — TS compiler performance and tsconfig tuning.
- `.curated/refactor` — Mechanical refactoring workflows.
- `.curated/tdd` — The TDD workflow itself.
