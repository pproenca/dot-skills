# TypeScript 5.x + React 19 (principles are language-agnostic; examples use modern TS+React idioms)

**Version 0.1.0**  
Robert C. Martin (Uncle Bob) — adapted for TypeScript + React  
May 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Software craftsmanship guide translating Robert C. Martin's universal Clean Code principles into modern TypeScript and React. Contains 61 rules across 11 categories — names, functions/components/hooks, self-documentation via types, formatting beyond Prettier, error handling, data shape and immutability, boundaries, composition, tests, emergence, and a unique Meta category for when clean-code principles conflict (DRY vs SRP, small functions vs deep modules, type safety vs ergonomics, tests as spec vs documentation). Every rule includes incorrect and correct examples in TS 5.x + React 19 with minimal diffs, plus first-class 'When NOT to apply' sections with concrete scenarios. Sister skill to .experimental/clean-code; defers framework-specific patterns to .curated/react and TS compiler performance to .curated/typescript.

---

## Table of Contents

1. [Meaningful Names](references/_sections.md#1-meaningful-names) — **CRITICAL**
   - 1.1 [Avoid Misleading Names](references/name-avoid-disinformation.md) — CRITICAL (prevents readers from acting on false assumptions baked into a name)
   - 1.2 [Boolean Variables Use is/has/can Prefixes](references/name-boolean-predicate.md) — CRITICAL (prevents reading ambiguity at boolean call sites)
   - 1.3 [Components Are PascalCase Noun Phrases](references/name-component-pascal-case.md) — CRITICAL (enables JSX to render correctly and signals "this is a thing on the page")
   - 1.4 [Event Handlers Use onX / handleX Convention](references/name-handler-convention.md) — CRITICAL (prevents prop-handler contract drift across components)
   - 1.5 [Hooks Are useX Verb Phrases](references/name-hook-use-prefix.md) — CRITICAL (prevents hook-rule lint bypass at hook call sites)
   - 1.6 [Make Meaningful Distinctions](references/name-meaningful-distinctions.md) — CRITICAL (prevents noise-word naming collisions)
   - 1.7 [Types and Interfaces Are PascalCase](references/name-types-pascal-case.md) — CRITICAL (prevents type-vs-value confusion at every read)
   - 1.8 [Use Intention-Revealing Names](references/name-intention-revealing.md) — CRITICAL (eliminates the mental mapping a reader must do on every read)
2. [Functions, Components & Hooks](references/_sections.md#2-functions,-components-&-hooks) — **CRITICAL**
   - 2.1 [Avoid Hidden Side Effects (Especially in Render)](references/func-no-side-effects.md) — CRITICAL (preserves React's purity contract and makes function behavior predictable)
   - 2.2 [Do Not Repeat Yourself — Until the Concepts Diverge](references/func-dry.md) — CRITICAL (collapses duplicated concepts into one source of truth without coupling unrelated code)
   - 2.3 [Do One Thing](references/func-one-thing.md) — CRITICAL (prevents mixed-abstraction comprehension cost)
   - 2.4 [Extract Custom Hooks for Reusable Stateful Logic](references/func-custom-hook-extract.md) — CRITICAL (makes stateful behavior reusable without HOCs, render props, or context gymnastics)
   - 2.5 [Keep Functions, Components & Hooks Small](references/func-small.md) — CRITICAL (prevents working-memory overflow on every read)
   - 2.6 [One Level of Abstraction Per Function](references/func-abstraction-level.md) — CRITICAL (prevents the reader from context-switching between strategy and mechanics)
   - 2.7 [Prefer Object Parameters Over Long Argument Lists](references/func-minimize-arguments.md) — CRITICAL (eliminates positional-argument errors and makes refactors safe)
   - 2.8 [Separate Commands from Queries](references/func-command-query-separation.md) — CRITICAL (makes the call site read as either an action or a question, never both)
3. [Self-Documentation: Types & Comments](references/_sections.md#3-self-documentation:-types-&-comments) — **HIGH**
   - 3.1 [Avoid Redundant Comments](references/doc-avoid-redundant-comments.md) — HIGH (removes noise that decays into lies when code changes)
   - 3.2 [Delete Commented-Out Code](references/doc-delete-commented-out-code.md) — HIGH (stops dead code from accumulating as cognitive tax on every future reader)
   - 3.3 [JSDoc for Public APIs and Non-Obvious Side Effects](references/doc-jsdoc-public-api.md) — HIGH (surfaces intent and side effects at the call site where consumers actually look)
   - 3.4 [Prefer Types Over Comments](references/doc-types-over-comments.md) — HIGH (eliminates stale-doc decay by promoting invariants to compiler-checked types)
   - 3.5 [Use `satisfies` for Inferred-But-Checked Values](references/doc-satisfies-narrows-with-check.md) — HIGH (preserves literal-type precision while still verifying shape against a contract)
4. [Formatting (Beyond Prettier)](references/_sections.md#4-formatting-(beyond-prettier)) — **HIGH**
   - 4.1 [Group Imports by Source](references/fmt-imports-grouped.md) — HIGH (makes dependency provenance scannable at a glance)
   - 4.2 [Keep Related Code Close, Unrelated Code Far](references/fmt-vertical-density.md) — HIGH (reduces eye-tracking and working-memory cost when reading a function)
   - 4.3 [Order Files Top-Down Like a Newspaper](references/fmt-newspaper-order.md) — HIGH (lets readers grasp a file's purpose without scrolling to find the headline)
   - 4.4 [Team Conventions Over Personal Preference](references/fmt-team-rules-over-preference.md) — HIGH (trades local optimization for codebase-wide consistency, which is what readers actually need)
5. [Error Handling](references/_sections.md#5-error-handling) — **HIGH**
   - 5.1 [Always Narrow `unknown` in Catch Blocks](references/err-narrow-unknown.md) — HIGH (prevents secondary crashes from assuming caught values are `Error` instances)
   - 5.2 [Choose Throw vs Result Deliberately](references/err-result-vs-throw.md) — HIGH (forces callers to handle predictable failures at the type level)
   - 5.3 [Never Swallow Errors Silently](references/err-no-swallow.md) — HIGH (prevents silent bug factories at every catch site)
   - 5.4 [Pick null OR undefined Per Domain — Not Both](references/err-null-vs-undefined.md) — HIGH (removes the mental tax of remembering which absence sentinel each function uses)
   - 5.5 [Use Early Returns to Flatten Error Paths](references/err-early-return.md) — HIGH (keeps the happy path at one indent level so readers can find it)
   - 5.6 [Use Error Boundaries for Render-Time Failures](references/err-error-boundaries.md) — HIGH (contains component crashes so one bad subtree doesn't blank the whole app)
   - 5.7 [Use Suspense for Loading States, Not Boolean Flags](references/err-suspense-for-loading.md) — HIGH (declares loading once at the boundary instead of repeating conditionals in every component)
6. [Data Shape & Immutability](references/_sections.md#6-data-shape-&-immutability) — **MEDIUM-HIGH**
   - 6.1 [Beware Structural Typing Aliasing](references/data-structural-typing-pitfalls.md) — MEDIUM-HIGH (prevents semantically distinct types from being silently interchangeable)
   - 6.2 [Brand Types to Make Domain Distinctions Compile-Checked](references/data-branded-types.md) — MEDIUM-HIGH (turns argument-swap bugs into compile errors)
   - 6.3 [Mark Read-Only Data Readonly](references/data-readonly-by-default.md) — MEDIUM-HIGH (prevents silent mutation that React won't detect)
   - 6.4 [Prop Drilling Often Smells Like Demeter Violation](references/data-demeter-prop-drilling.md) — MEDIUM-HIGH (reduces structural coupling between distant components)
   - 6.5 [Separate DTOs from Domain Types](references/data-dto-vs-domain.md) — MEDIUM-HIGH (localizes API changes to a translation layer)
   - 6.6 [Use Discriminated Unions Over Boolean Flags](references/data-discriminated-unions-over-flags.md) — MEDIUM-HIGH (encodes legal states only so the compiler enforces invariants)
7. [Boundaries](references/_sections.md#7-boundaries) — **MEDIUM-HIGH**
   - 7.1 [Isolate Framework-Specific Code at the Edges](references/bound-isolate-framework.md) — MEDIUM-HIGH (keeps business logic testable and framework-agnostic)
   - 7.2 [Type Assertions Belong Only at Boundaries](references/bound-type-assertions-at-edges.md) — MEDIUM-HIGH (confines unchecked trust to one verified entry point)
   - 7.3 [Wrap Third-Party Hooks in Custom Hooks](references/bound-wrap-third-party-hooks.md) — MEDIUM-HIGH (localizes library-version churn to a single file)
   - 7.4 [Write Learning Tests for Third-Party Behavior](references/bound-learning-tests.md) — MEDIUM-HIGH (alarms on silent library behavior changes during upgrades)
8. [Composition over Inheritance](references/_sections.md#8-composition-over-inheritance) — **MEDIUM-HIGH**
   - 8.1 [Avoid Higher-Order Component Stacks](references/comp-avoid-hoc-stacks.md) — MEDIUM-HIGH (makes injected dependencies visible and typeable)
   - 8.2 [Compose with Children Over Configuration Props](references/comp-children-over-props.md) — MEDIUM-HIGH (inverts variation from props-explosion to caller composition)
   - 8.3 [Keep Components Small and Cohesive](references/comp-small-components.md) — MEDIUM-HIGH (bounds what a single component has to be understood about)
   - 8.4 [Prefer Hooks Over Render Props for Logic Reuse](references/comp-render-props-vs-hooks.md) — MEDIUM-HIGH (simplifies composition and improves type inference)
   - 8.5 [Separate Setup (Effects, Subscriptions) from Rendering](references/comp-separate-construction-from-use.md) — MEDIUM-HIGH (keeps render pure and aligns with React's contract)
   - 8.6 [Use Context for True Dependency Injection, Not Prop Avoidance](references/comp-context-only-when-needed.md) — MEDIUM-HIGH (avoids hidden coupling and re-render cascades)
9. [Tests](references/_sections.md#9-tests) — **MEDIUM**
   - 9.1 [Apply FIRST Principles to Tests](references/test-first-principles.md) — MEDIUM (Fast, isolated, deterministic tests get run; slow flaky ones get skipped)
   - 9.2 [Mock Only at True Boundaries](references/test-mock-at-boundaries.md) — MEDIUM (Real code paths get exercised; refactors stay safe)
   - 9.3 [One Concept (Not One Assert) Per Test](references/test-one-concept.md) — MEDIUM (Each test names a behavior; assertions describe it together)
   - 9.4 [Test Behavior, Not Implementation](references/test-behavior-not-implementation.md) — MEDIUM (Tests stay green through refactors, red through real regressions)
   - 9.5 [Test Code Deserves Production-Grade Care](references/test-clean-as-production.md) — MEDIUM (Readable tests make production code feel safe to change)
10. [Emergence & Simple Design](references/_sections.md#10-emergence-&-simple-design) — **MEDIUM**
   - 10.1 [Apply the Four Rules of Simple Design in Order](references/emerge-four-rules.md) — MEDIUM (Refactor toward simplicity without breaking behavior or clarity)
   - 10.2 [Avoid Premature Type Generics](references/emerge-yagni-types.md) — MEDIUM (Concrete types stay readable; generics earn their complexity)
   - 10.3 [Maximize Expressiveness — Code as Communication](references/emerge-reveal-intent.md) — MEDIUM (Names and structure communicate purpose; bytecode is a side effect)
   - 10.4 [Resist Premature Abstraction](references/emerge-premature-abstraction.md) — MEDIUM (Avoid the wrong abstraction; let patterns emerge from concrete cases)
11. [Meta: When Principles Conflict](references/_sections.md#11-meta:-when-principles-conflict) — **MEDIUM**
   - 11.1 [Bend DRY When Concepts Drift Apart](references/meta-dry-vs-srp.md) — MEDIUM (prevents wrong-abstraction lock-in across modules)
   - 11.2 [Pick Tests-as-Spec or Tests-as-Documentation Per File](references/meta-tests-as-spec-vs-doc.md) — MEDIUM (prevents audience-mixing in test files)
   - 11.3 [Small Functions Lose to Deep Modules When Indirection Exceeds Comprehension](references/meta-small-vs-deep.md) — MEDIUM (prevents shallow-module fragmentation)
   - 11.4 [Type Safety Loses to Ergonomics at Stable Boundaries](references/meta-types-vs-ergonomics.md) — MEDIUM (prevents impossible-state representations at compile time)

---

## References

1. [https://www.oreilly.com/library/view/clean-code-a/9780136083238/](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
2. [https://web.stanford.edu/~ouster/cgi-bin/aposd.php](https://web.stanford.edu/~ouster/cgi-bin/aposd.php)
3. [https://www.totaltypescript.com/](https://www.totaltypescript.com/)
4. [https://kentcdodds.com/](https://kentcdodds.com/)
5. [https://tkdodo.eu/](https://tkdodo.eu/)
6. [https://react.dev/](https://react.dev/)
7. [https://www.typescriptlang.org/docs/handbook/](https://www.typescriptlang.org/docs/handbook/)
8. [https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction](https://sandimetz.com/blog/2016/1/20/the-wrong-abstraction)
9. [https://kentbeck.github.io/TestDesiderata/](https://kentbeck.github.io/TestDesiderata/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |