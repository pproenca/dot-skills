---
name: same-results-less-code
description: Use this skill whenever reviewing, refactoring, or simplifying code with the goal of producing the same behaviour in fewer, clearer lines — covers the judgment gaps that linters cannot catch (reinvention, wrong frame, hidden duplication, derived state, procedural rebuilds, speculative generality, defensive excess, type-system underuse). Trigger even when the user doesn't explicitly ask for "simplification" but is reviewing code, refactoring, or asking "is there a shorter way to write this?" — this skill complements knip/eslint/ruff/tsc by focusing on the conceptual modelling layer those tools cannot see.
---

# Community Refactoring Best Practices: Same Results, Less Code

Code-review and refactoring guide focused on the parts of code volume that come from **judgment and modelling gaps** — wrong abstraction choices, hidden semantic duplication, defensive habits, premature generality. This skill deliberately skips what linters and tools like `knip`, `eslint`, `ruff`, `tsc --noUnusedLocals`, or formatters already catch. It is the second pass: after the mechanical cleanup, what remains?

## Core Principles

1. **Preserve behaviour.** Every transformation must produce identical observable behaviour — same outputs, same errors, same side effects, same API surface.
2. **Earlier mistakes cascade.** A wrong frame multiplies into wrong shapes, which multiply into duplicate logic. Optimise from the top of the lifecycle.
3. **Explain why, not just what.** Each rule explains the cost of the anti-pattern so judgment can transfer to novel cases.
4. **Quantify where possible.** Prefer "eliminates N lines / prevents X bug class" over "cleaner."
5. **Don't over-refactor.** Rule of three: extract abstractions when duplication has actually appeared three times, not in anticipation.

## When to Apply

Use this skill when:

- Reviewing a PR for "could this be simpler?" (the question linters can't answer)
- Refactoring code that has grown in volume without growing in capability
- Auditing a module that "feels heavy" — many flags, many layers, many checks
- Onboarding to an unfamiliar codebase and trying to spot the parts that are accidental volume vs essential complexity
- Designing a new module and wanting to avoid the common over-abstraction traps
- Working alongside knip / eslint / ruff and wanting the layer of judgment those tools can't supply

**Don't use this skill for:**

- Mechanical cleanup that a linter or formatter already does (unused imports, dead exports, style) — use `knip`, `eslint`, `ruff`, or `prettier`/`black` instead.
- Algorithmic complexity / performance tuning — use [`complexity-optimizer`](../complexity-optimizer/) for that.
- General cleanup of recently modified code regardless of mental-model gaps — use [`code-simplifier`](../code-simplifier/).

## Rule Categories by Priority

| # | Category | Prefix | Impact | Rules | Gist |
|---|----------|--------|--------|-------|------|
| 1 | Reinvention | `reinvent-` | CRITICAL | 5 | You wrote what the platform/stdlib already provides |
| 2 | Wrong Frame | `frame-` | CRITICAL | 5 | Wrong abstraction shape — class where a function fits, manager nouns, OO over data |
| 3 | Hidden Duplication | `dup-` | HIGH | 5 | Semantic copies hiding behind syntactic differences |
| 4 | Derived State Stored | `derive-` | HIGH | 5 | Storing what should be computed |
| 5 | Procedural Rebuilds | `proc-` | MEDIUM-HIGH | 5 | Imperative reimplementation of declarative concepts |
| 6 | Speculative Generality | `spec-` | MEDIUM | 5 | Generality built for a second user who never arrived |
| 7 | Defensive Excess | `defense-` | MEDIUM | 4 | Checks for states the type/flow already rules out |
| 8 | Type System Underuse | `types-` | LOW-MEDIUM | 6 | Runtime guards that should be types |

## Quick Reference

### 1. Reinvention (CRITICAL)

- [`reinvent-stdlib-collection-ops`](references/reinvent-stdlib-collection-ops.md) — Reach for `.map`/`.filter`/`.reduce` before writing loops
- [`reinvent-date-and-time`](references/reinvent-date-and-time.md) — Stop hand-rolling date and time arithmetic
- [`reinvent-deep-equality`](references/reinvent-deep-equality.md) — Use a real deep-equal instead of hand-recursing objects
- [`reinvent-explicit-state-machine`](references/reinvent-explicit-state-machine.md) — Surface a state machine instead of boolean flag juggling
- [`reinvent-builtin-data-structures`](references/reinvent-builtin-data-structures.md) — Recognise when a custom container is just a Map, Set, or Queue

### 2. Wrong Frame (CRITICAL)

- [`frame-function-not-class`](references/frame-function-not-class.md) — Use a function when the class has no identity
- [`frame-manager-noun-is-a-verb`](references/frame-manager-noun-is-a-verb.md) — Rename Manager/Helper/Util classes until the real verb appears
- [`frame-composition-over-inheritance-for-shared-fields`](references/frame-composition-over-inheritance-for-shared-fields.md) — Compose shared fields instead of inheriting
- [`frame-data-over-procedure`](references/frame-data-over-procedure.md) — Model the problem as data before writing procedure
- [`frame-monolith-by-cohesive-axis`](references/frame-monolith-by-cohesive-axis.md) — Split a god-function along its cohesive axis, not by line count

### 3. Hidden Duplication (HIGH)

- [`dup-parallel-types-same-shape`](references/dup-parallel-types-same-shape.md) — Collapse parallel types that share a shape
- [`dup-near-twin-functions`](references/dup-near-twin-functions.md) — Parameterize two functions that differ by a literal
- [`dup-mirrored-branches`](references/dup-mirrored-branches.md) — Lift shared lines out of mirrored if/else branches
- [`dup-config-not-copies`](references/dup-config-not-copies.md) — Replace many hardcoded copies with one table
- [`dup-cross-layer-shape`](references/dup-cross-layer-shape.md) — Collapse identical DTOs, DB rows, and domain objects

### 4. Derived State Stored (HIGH)

- [`derive-dont-store-computed`](references/derive-dont-store-computed.md) — Compute what you can compute; store only what you can't
- [`derive-single-source-of-truth`](references/derive-single-source-of-truth.md) — Pick one source of truth; derive the rest
- [`derive-boolean-from-data`](references/derive-boolean-from-data.md) — Derive booleans from the data, don't track them separately
- [`derive-cache-as-getter-not-field`](references/derive-cache-as-getter-not-field.md) — Turn cached fields into getters until profiling proves otherwise
- [`derive-url-as-state`](references/derive-url-as-state.md) — Let the URL or route be the state, not a mirror of it

### 5. Procedural Rebuilds (MEDIUM-HIGH)

- [`proc-mutation-builder-over-pipeline`](references/proc-mutation-builder-over-pipeline.md) — Compose pipelines when the mutation-builder hides the intent
- [`proc-if-chain-as-lookup`](references/proc-if-chain-as-lookup.md) — Replace if/elif returning constants with a lookup table
- [`proc-manual-recursion-of-walk`](references/proc-manual-recursion-of-walk.md) — Use a recognised tree/object walk, not hand-coded recursion
- [`proc-build-vs-declarative-template`](references/proc-build-vs-declarative-template.md) — Use the declarative form when the framework provides one
- [`proc-sequential-awaits-could-be-parallel`](references/proc-sequential-awaits-could-be-parallel.md) — Parallelise independent awaits

### 6. Speculative Generality (MEDIUM)

- [`spec-interface-of-one`](references/spec-interface-of-one.md) — Avoid defining an interface for a single implementation
- [`spec-options-bag-of-one`](references/spec-options-bag-of-one.md) — Avoid options bags where every caller passes the same values
- [`spec-flag-driven-paths`](references/spec-flag-driven-paths.md) — Split a function that a boolean flag has made into two
- [`spec-no-extension-point-without-extender`](references/spec-no-extension-point-without-extender.md) — Delete extension points that have no second user
- [`spec-generic-over-one-type`](references/spec-generic-over-one-type.md) — Drop the generic parameter when only one concrete type uses it

### 7. Defensive Excess (MEDIUM)

- [`defense-guard-against-impossible`](references/defense-guard-against-impossible.md) — Stop guarding against states the type/flow already rules out
- [`defense-validate-once-at-boundary`](references/defense-validate-once-at-boundary.md) — Validate once at the boundary, trust inside
- [`defense-let-it-throw`](references/defense-let-it-throw.md) — Let exceptions propagate; don't catch what you can't handle
- [`defense-null-pollution-from-bad-modelling`](references/defense-null-pollution-from-bad-modelling.md) — Fix the type that makes the null checks necessary

### 8. Type System Underuse (LOW-MEDIUM)

- [`types-discriminated-union-over-flags`](references/types-discriminated-union-over-flags.md) — Use a discriminated union instead of optional fields + tags
- [`types-literal-union-over-string`](references/types-literal-union-over-string.md) — Narrow `string` down to a literal union when the set is closed
- [`types-no-any-to-silence`](references/types-no-any-to-silence.md) — Avoid reaching for `any`/`as` to silence a type error
- [`types-branding-over-runtime-checks`](references/types-branding-over-runtime-checks.md) — Brand a validated value so you don't validate it twice
- [`types-exhaustive-switch-not-default`](references/types-exhaustive-switch-not-default.md) — Use exhaustiveness checks instead of a catch-all default
- [`types-readonly-and-immutable-by-default`](references/types-readonly-and-immutable-by-default.md) — Mark data `readonly` until mutation is actually needed

## How to Apply (Workflow)

When asked to review or refactor code with this skill:

1. **Run the mechanical pass first.** `knip`/`eslint`/`ruff`/`tsc --noUnusedLocals` will catch dead code, unused imports, style. Don't duplicate that work here.
2. **Read the file or PR for *intent*.** Ask: what is this code trying to do? The judgment skill is recognising when the implementation overshoots the intent.
3. **Walk the categories in priority order.**
   - Start with [Reinvention](references/reinvent-stdlib-collection-ops.md) and [Frame](references/frame-function-not-class.md) — the biggest wins live there.
   - Then [Duplication](references/dup-parallel-types-same-shape.md) and [Derived state](references/derive-dont-store-computed.md).
   - Then [Procedural rebuilds](references/proc-loop-to-collection-method.md) and [Speculative generality](references/spec-interface-of-one.md).
   - Defensive and type-system issues last — they're high frequency but localised.
4. **Propose minimal-diff transformations.** Each rule shows incorrect → correct as a tight diff; preserve that property in suggestions.
5. **Verify behaviour.** Outputs, errors, and side effects must be identical. Tests must still pass.
6. **Don't bundle unrelated changes.** Each transformation should map to one category. Mixing them makes the change hard to review.

## When NOT to Apply

- Code is younger than the rule of three (one or two duplicates) — extracting is premature.
- The pattern is genuinely a known exception (see each rule's "When NOT to use this pattern" section).
- The refactor would be a large, risky rewrite without a clear test safety net — propose, don't execute.
- Performance-critical hot paths where the "simpler" form has measurable cost — measure first.

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |

## Related Skills

- [`code-simplifier`](../code-simplifier/) — Mechanical simplification (naming, dead code, nesting). Complementary first pass.
- [`complexity-optimizer`](../complexity-optimizer/) — Algorithmic/performance complexity. Different axis.
- [`refactor`](../refactor/) — General-purpose refactoring workflow.
- [`clean-code`](../clean-code/) — Broader clean-code principles. This skill is the narrower, judgment-focused subset.
