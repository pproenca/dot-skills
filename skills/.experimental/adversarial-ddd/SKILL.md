---
name: adversarial-ddd
description: Use this skill to gate DDD and ubiquitous-language quality with a pass/fail adversarial review — two blind reviewer subagents independently judge a diff, a module/bounded context, or a DSL/semantic-model surface against 20 decidable rules across glossary lifecycle (a recorded ubiquitous language is required once domain concepts exist — absence is FAIL; code must conform; entries stay live and carry business meaning), language consistency (one name per concept, one meaning per name, no Manager/Helper/Data names on domain rules, transitions named as operations, one vocabulary across code, tests, docs, UI copy), domain model integrity (anemic models, valid-on-construction, value types over primitives, named states over flag piles), context boundaries (foreign-model reach, vendor-type absorption, infrastructure in the domain, multiple writers), and DSL surfaces. Language-agnostic; repeated runs converge code, team, and stakeholders on one recorded vocabulary. Verdicts only.
---

# Adversarial DDD Gate

A domain-driven design and ubiquitous-language gate for any codebase — a pass/fail gate: two blind, identical reviewer subagents independently judge the work against this gate's rules, and the work passes only if both say PASS. This skill renders verdicts; it never fixes the work.

The gate's engine is the **glossary lifecycle**: once a target contains domain concepts, a recorded ubiquitous language (a glossary) must exist — its absence is a FAIL whose fix list names the exact file to create and the terms it must define. Run the gate on any project and the first verdict forces the vocabulary into existence; every later run holds the code, tests, docs, and customer-facing copy to it and keeps it well-sized. That is how one skill produces a common, well-understood vocabulary across many projects, exactly as DDD prescribes.

## When to Apply

- Domain code is about to merge and needs an objective PASS/FAIL on ubiquitous-language and domain-model quality, not advisory feedback.
- A project is being started or adopted and you want the shared vocabulary forced into existence — the first run's fix list is the glossary's initial contents.
- An agent (Claude, Codex) authored the code and you want an independent check on its known defaults: `*Manager`/`*Helper` types, `setStatus()` transitions, anemic entities, vendor types absorbed into the model.
- A DSL, fluent builder, or declarative spec format is being introduced and its surface needs judging as a domain-vocabulary artifact.
- A periodic audit — the codebase, docs, and stakeholder-facing surfaces have drifted and you want the divergences named with locations.

Do not apply to targets with no domain concepts — pure infrastructure, build tooling, generic libraries (the reviewer prompt's precondition aborts with "GATE NOT APPLICABLE"). Do not apply when the user wants explanations or refactoring rather than a verdict. Rules whose prerequisite structure is absent (no identifiable contexts, no DSL, no glossary yet for the conformance rules) go N/A, not FAIL — except the two absence rules (`gloss-language-recorded`, `dsl-deterministic-validator-exists`), where the missing artifact is itself the FAIL.

## Review Protocol

Follow these steps exactly — the gate's value is that every review runs the same way.

1. **Identify the target.** Pin down exactly what is under review (a diff, a module/bounded context, a DSL surface) and note the ref/paths so both reviewers see the same thing. Always include the repo root — the `gloss-*` rules search the repo for a glossary and for term usage, and the `ctx-*` rules need sibling contexts visible beyond the diff. Note where docs and user-facing copy live if they exist.
2. **Load the rules.** Read [references/_sections.md](references/_sections.md) and every rule file in `references/` (all `gloss-*.md`, `lang-*.md`, `model-*.md`, `ctx-*.md`, `dsl-*.md` files).
3. **Compose the reviewer prompt.** Fill [references/reviewer-prompt.md](references/reviewer-prompt.md) with the rules and the target. The composed prompt must be fully self-contained — a reviewer sees no conversation history, so nothing may refer to context outside the prompt.
4. **Dispatch two blind reviewers.** Launch two Task subagents in a single message (parallel) with the identical composed prompt. Do not share either reviewer's output with the other.
5. **Merge fail-closed.**

   | Reviewer A | Reviewer B | Final |
   |-----------|-----------|-------|
   | PASS | PASS | **PASS** |
   | FAIL | FAIL | **FAIL** |
   | PASS | FAIL (either order) | **FAIL** — rule marked **CONTESTED** |

   N/A splits: N/A vs N/A → N/A; N/A vs PASS → PASS; N/A vs FAIL → CONTESTED (counts as FAIL). Overall verdict is PASS only when both reviewers' overall verdicts are PASS. Contested rules count as FAIL and show both rationales. If either reviewer returns "GATE NOT APPLICABLE" (no domain concepts in the target), stop and report that instead of a verdict.
6. **Render the verdict.** Fill [assets/templates/verdict.md](assets/templates/verdict.md). On FAIL, aggregate every reviewer's "missing for PASS" suggestions into the fix list, each with its location, ordered by category importance — glossary edits first, since creating or correcting the recorded language is what makes the remaining rules checkable.

If the same rule is repeatedly contested across reviews, the rule is not decidable enough — record it in [gotchas.md](gotchas.md) and sharpen the rule; do not override the gate.

## Verdict Format

Each reviewer returns, per rule: `PASS | FAIL | N/A`, evidence (`file:line`, a quote, or the glossary entry — required for PASS as well as FAIL), and for every FAIL, what is missing to reach PASS. Each reviewer also reports which glossary it found (or that none exists and where it searched). The final report follows [assets/templates/verdict.md](assets/templates/verdict.md).

## Rule Categories

| # | Category | Prefix | Covers |
|---|----------|--------|--------|
| 1 | Glossary Lifecycle | `gloss-` | A recorded ubiquitous language exists (absence is FAIL), code conforms to it, every entry stays live, definitions carry business meaning |
| 2 | Language Consistency | `lang-` | One name per concept, one meaning per name, no semantics-free names on domain rules, transitions named as operations, one vocabulary across code/tests/docs/UI |
| 3 | Domain Model Integrity | `model-` | Rules live with the model, valid on construction, domain types over bare primitives, named states over boolean flag piles |
| 4 | Boundaries & Context Integrity | `ctx-` | Published interfaces between contexts, anticorruption at vendor seams, infrastructure-free domain, one writer per stored model |
| 5 | Semantic Model & DSL Surface | `dsl-` | Semantic model separate from carrier syntax, illegal statements unconstructible or fail-fast, deterministic validator for external DSLs |

## Related Skills

- `domain-architect` (experimental) — teaching-style domain modeling guidance; use it when the goal is designing the model rather than gating it.
- `adversarial-ts-patterns` (experimental) — pattern-usage gate for TypeScript/React; run alongside this gate on TS targets for full coverage (it owns the state-machine and over-abstraction rules at the code-idiom level).
- `feature-arch-gate` (experimental) — folder/feature architecture gate; complementary at the project-structure level.

## Reference Files

| File | Description |
|------|-------------|
| [references/reviewer-prompt.md](references/reviewer-prompt.md) | Self-contained prompt template for each blind reviewer |
| [assets/templates/verdict.md](assets/templates/verdict.md) | Verdict report template |
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [metadata.json](metadata.json) | Version and source references |
