# Refactoring

**Version 0.1.0**  
Community  
May 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when refactoring, maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Code-review and refactoring guide focused on the judgment gaps that produce excess code volume — wrong abstraction frame, hidden semantic duplication, derived state stored as state, procedural rebuilds of declarative concepts, speculative generality, defensive checks against impossible states, and type-system underuse. Contains 40 rules across 8 categories, prioritized by cascade impact. Deliberately skips what linters and tools like knip, eslint, ruff, and tsc already catch; this is the second pass that operates on conceptual modelling rather than mechanical cleanup. Each rule includes a WHY explanation, incorrect-vs-correct code examples with minimal diffs, and clear 'when NOT to apply' guidance.

---

## Table of Contents

1. [Reinvention](references/_sections.md#1-reinvention) — **CRITICAL**
   - 1.1 [Reach for Standard Collection Operations Before Writing Loops](references/reinvent-stdlib-collection-ops.md) — CRITICAL (eliminates index variables and accumulator bugs; reduces 5-20 line loops to one expression)
   - 1.2 [Recognise When a Custom Container Is Just a Map, Set, or Queue](references/reinvent-builtin-data-structures.md) — CRITICAL (eliminates 50-200 line wrapper classes around Map, Set, or Deque)
   - 1.3 [Stop Hand-Rolling Date and Time Arithmetic](references/reinvent-date-and-time.md) — CRITICAL (prevents DST and locale bugs; reduces 20-60 lines of date math to 1-3)
   - 1.4 [Surface an Explicit State Machine Instead of Boolean Flag Juggling](references/reinvent-explicit-state-machine.md) — CRITICAL (4-8 boolean flags collapsed to a single tagged state; eliminates impossible-state bugs)
   - 1.5 [Use a Real Deep-Equality or Hash Instead of Hand-Recursing Objects](references/reinvent-deep-equality.md) — CRITICAL (30-100 lines of recursive comparison reduced to a single library call)
2. [Wrong Frame](references/_sections.md#2-wrong-frame) — **CRITICAL**
   - 2.1 [Compose Shared Fields Instead of Inheriting From a Base Class](references/frame-composition-over-inheritance-for-shared-fields.md) — CRITICAL (eliminates rigid multi-level class hierarchies in favour of intersected types)
   - 2.2 [Model the Problem as Data Before Writing Procedure](references/frame-data-over-procedure.md) — CRITICAL (reduces 50-200 lines of branches to a small table plus one interpreter)
   - 2.3 [Rename Manager/Helper/Util Classes Until the Real Verb Appears](references/frame-manager-noun-is-a-verb.md) — CRITICAL (reduces grab-bag "Manager" classes to focused functions in their real modules)
   - 2.4 [Split a God-Function Along Its Cohesive Axis, Not by Line Count](references/frame-monolith-by-cohesive-axis.md) — CRITICAL (reduces a 300-line procedure to 3-5 independently testable pieces)
   - 2.5 [Use a Function When the Class Has No Identity](references/frame-function-not-class.md) — CRITICAL (eliminates 50-100 lines of class ceremony around a stateless function)
3. [Hidden Duplication](references/_sections.md#3-hidden-duplication) — **HIGH**
   - 3.1 [Collapse Identical DTOs, DB Rows, and Domain Objects](references/dup-cross-layer-shape.md) — HIGH (eliminates a layer of pass-through mappers and the entity-x3 type explosion)
   - 3.2 [Collapse Parallel Types That Share a Shape](references/dup-parallel-types-same-shape.md) — HIGH (eliminates three near-identical types and their mappers (~100 lines))
   - 3.3 [Lift Shared Lines Out of Mirrored Branches](references/dup-mirrored-branches.md) — HIGH (reduces twin if/else bodies to one shared block plus the actual difference)
   - 3.4 [Parameterize Two Functions That Differ by a Literal](references/dup-near-twin-functions.md) — HIGH (eliminates a copy-paste twin function and the diff-rot bug class)
   - 3.5 [Replace Many Hardcoded Copies With One Table](references/dup-config-not-copies.md) — HIGH (reduces N copy-pasted definitions to 1 table; eliminates the "I forgot to update one" bug)
4. [Derived State Stored](references/_sections.md#4-derived-state-stored) — **HIGH**
   - 4.1 [Compute What You Can Compute; Store Only What You Can't](references/derive-dont-store-computed.md) — HIGH (eliminates state variables and the sync bugs they cause)
   - 4.2 [Derive Booleans From the Data, Don't Track Them Separately](references/derive-boolean-from-data.md) — HIGH (eliminates one boolean of state per "is X?" question (and its sync code))
   - 4.3 [Let the URL or Route Be the State, Not a Mirror of It](references/derive-url-as-state.md) — HIGH (eliminates URL-vs-local-state desync and the listener code that papers over it)
   - 4.4 [Pick One Source of Truth; Derive the Rest](references/derive-single-source-of-truth.md) — HIGH (prevents two-state-sync bugs and eliminates parallel updates)
   - 4.5 [Turn Cached Fields Into Getters Until Profiling Proves Otherwise](references/derive-cache-as-getter-not-field.md) — HIGH (eliminates invalidation bugs and the "stale cache" class of failures)
5. [Procedural Rebuilds](references/_sections.md#5-procedural-rebuilds) — **MEDIUM-HIGH**
   - 5.1 [Compose Pipelines When the Mutation-Builder Hides the Intent](references/proc-mutation-builder-over-pipeline.md) — MEDIUM-HIGH (reduces 10-20 line accumulator-builder blocks to a 3-5 line composed pipeline)
   - 5.2 [Parallelise Independent Awaits](references/proc-sequential-awaits-could-be-parallel.md) — MEDIUM-HIGH (faster wall-clock time by N for N independent I/O calls; eliminates accidental serial chains)
   - 5.3 [Replace an if/elif Chain That Returns Different Constants With a Lookup](references/proc-if-chain-as-lookup.md) — MEDIUM-HIGH (reduces an N-branch if/elif to a single Map or object lookup)
   - 5.4 [Use a Recognised Tree/Object Walk Instead of Hand-Coded Recursion](references/proc-manual-recursion-of-walk.md) — MEDIUM-HIGH (eliminates hand-rolled recursive descent with its accumulator and base-case bugs)
   - 5.5 [Use the Declarative Form When the Framework Provides One](references/proc-build-vs-declarative-template.md) — MEDIUM-HIGH (eliminates imperative DOM/string builders in favour of the framework's template form)
6. [Speculative Generality](references/_sections.md#6-speculative-generality) — **MEDIUM**
   - 6.1 [Avoid Defining an Interface for a Single Implementation](references/spec-interface-of-one.md) — MEDIUM (eliminates one-implementer interfaces and the indirection layer they impose)
   - 6.2 [Avoid Options Bags Where Every Caller Passes the Same Values](references/spec-options-bag-of-one.md) — MEDIUM (eliminates options-object plumbing for parameters that have one value)
   - 6.3 [Delete Extension Points That Have No Second User](references/spec-no-extension-point-without-extender.md) — MEDIUM (eliminates hook/plugin/registry machinery that no one extends)
   - 6.4 [Drop the Generic Parameter When Only One Concrete Type Uses It](references/spec-generic-over-one-type.md) — MEDIUM (eliminates one-type generic indirection; reduces 5-10 lines of type plumbing)
   - 6.5 [Split a Function That a Boolean Flag Has Made Into Two](references/spec-flag-driven-paths.md) — MEDIUM (eliminates flag-driven branching that hides two distinct functions inside one)
7. [Defensive Excess](references/_sections.md#7-defensive-excess) — **MEDIUM**
   - 7.1 [Fix the Type That Makes the Null Checks Necessary](references/defense-null-pollution-from-bad-modelling.md) — MEDIUM (eliminates cascading null checks by modelling the actual cases)
   - 7.2 [Let Exceptions Propagate; Don't Catch What You Can't Handle](references/defense-let-it-throw.md) — MEDIUM (eliminates pass-through try/catch blocks that obscure failures)
   - 7.3 [Stop Guarding Against States the Type or Flow Already Rules Out](references/defense-guard-against-impossible.md) — MEDIUM (eliminates defensive checks for states the type system guarantees impossible)
   - 7.4 [Validate Once at the Boundary, Trust Inside](references/defense-validate-once-at-boundary.md) — MEDIUM (eliminates re-validation at every internal call; reduces N defensive checks to 1)
8. [Type System Underuse](references/_sections.md#8-type-system-underuse) — **LOW-MEDIUM**
   - 8.1 [Avoid Reaching for any/as to Silence a Type Error](references/types-no-any-to-silence.md) — LOW-MEDIUM (prevents silent type-error suppression; eliminates 5-10 lines of compensating runtime code)
   - 8.2 [Brand a Validated Value So You Don't Validate It Twice](references/types-branding-over-runtime-checks.md) — LOW-MEDIUM (eliminates re-validation of values that have already been checked)
   - 8.3 [Mark Data Readonly Until Mutation Is Actually Needed](references/types-readonly-and-immutable-by-default.md) — LOW-MEDIUM (eliminates defensive copies and prevents accidental mutation bugs)
   - 8.4 [Narrow string Down to a Literal Union When the Set Is Closed](references/types-literal-union-over-string.md) — LOW-MEDIUM (eliminates runtime string-comparison guards; enables compiler-checked exhaustiveness)
   - 8.5 [Use a Discriminated Union Instead of Optional Fields and Runtime Tags](references/types-discriminated-union-over-flags.md) — LOW-MEDIUM (eliminates manual tag checks; reduces 5-10 lines of guards to a switch)
   - 8.6 [Use Exhaustiveness Checks Instead of a Catch-All default](references/types-exhaustive-switch-not-default.md) — LOW-MEDIUM (prevents silent fall-through; eliminates the "I added a case and forgot to handle it" bug class)

---

## References

1. [https://web.stanford.edu/~ouster/cgi-bin/aposd.php](https://web.stanford.edu/~ouster/cgi-bin/aposd.php)
2. [https://tidyfirst.substack.com/](https://tidyfirst.substack.com/)
3. [https://refactoring.com/](https://refactoring.com/)
4. [https://blog.janestreet.com/effective-ml-revisited/](https://blog.janestreet.com/effective-ml-revisited/)
5. [https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/)
6. [https://martinfowler.com/bliki/Yagni.html](https://martinfowler.com/bliki/Yagni.html)
7. [https://verraes.net/2019/12/speculative-generality/](https://verraes.net/2019/12/speculative-generality/)
8. [https://react.dev/learn/you-might-not-need-an-effect](https://react.dev/learn/you-might-not-need-an-effect)
9. [https://www.typescriptlang.org/docs/handbook/2/narrowing.html](https://www.typescriptlang.org/docs/handbook/2/narrowing.html)
10. [https://pragprog.com/titles/swdddf/domain-modeling-made-functional/](https://pragprog.com/titles/swdddf/domain-modeling-made-functional/)
11. [https://effectivetypescript.com/](https://effectivetypescript.com/)
12. [https://en.wikipedia.org/wiki/Composition_over_inheritance](https://en.wikipedia.org/wiki/Composition_over_inheritance)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |