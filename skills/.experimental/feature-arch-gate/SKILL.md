---
name: feature-arch-gate
description: Adversarial pass/fail review gate that enforces the feature-arch skill's React feature-based architecture rules. Use when a diff, branch, PR, or src/ tree must be judged for architecture conformance before merge — feature folder structure, import boundaries, cross-feature isolation, data-fetching, state, testing, and naming rules. Two blind reviewers independently render per-rule PASS/FAIL verdicts with cited evidence and the verdict merges fail-closed. Use the feature-arch skill itself to design or migrate an architecture; use this gate to judge whether work conforms to it.
---

# Feature-Arch Gate

Enforce React feature-based architecture conformance — a pass/fail gate: two blind, identical reviewer subagents independently judge the work against the rules of feature-arch v1.1.0, and the work passes only if both say PASS. This skill renders verdicts; it never fixes the work.

This is a **companion gate**: it owns no rules. The 33 decidable rules it enforces (of the source's 43) live in the `feature-arch` distillation skill and are listed, with the evidence that decides each, in [references/rules-source.md](references/rules-source.md).

## When to Apply

- A PR or branch touching a feature-organized React codebase needs an architecture conformance verdict before merge.
- A migration step from a `FEATURE-ARCH-TARGET.md` blueprint is claimed complete and needs independent verification.
- A full `src/` tree audit is requested ("does this codebase conform to feature-arch?").
- Agent-generated feature work needs a gate that is blind to the conversation that produced it.

Do NOT apply this gate to design or migrate an architecture — that is the `feature-arch` skill's job (it produces the blueprint; this skill judges conformance to the rules).

## Review Protocol

Follow these steps exactly — the gate's value is that every review runs the same way.

1. **Identify the target.** Pin down exactly what is under review (a diff, a set of files, or a full `src/` tree) and note the ref/paths so both reviewers see the same thing. Record two context facts the reviewers need: does the codebase use React Server Components, and is a query library (TanStack Query etc.) present — two rules are N/A without them.
2. **Load the rules.** Read [references/rules-source.md](references/rules-source.md) and resolve the 33 imported rule files it lists against the source skill at `skills/.curated/feature-arch/references/`. If the source skill is missing or any listed rule file is unreadable, **STOP and report the error** — never proceed with partial rules or silently pass.
3. **Compose the reviewer prompt.** Fill [references/reviewer-prompt.md](references/reviewer-prompt.md) with the rule file paths, the target, and (if the target repo has one) its `docs/architecture/FEATURE-ARCH-TARGET.md` blueprint. The composed prompt must be fully self-contained — a reviewer sees no conversation history, so nothing may refer to context outside the prompt.
4. **Dispatch two blind reviewers.** Launch two Task subagents in a single message (parallel) with the identical composed prompt. Do not share either reviewer's output with the other.
5. **Merge fail-closed.**

   | Reviewer A | Reviewer B | Final |
   |-----------|-----------|-------|
   | PASS | PASS | **PASS** |
   | FAIL | FAIL | **FAIL** |
   | PASS | FAIL (either order) | **FAIL** — rule marked **CONTESTED** |

   N/A splits: N/A vs N/A → N/A; N/A vs PASS → PASS; N/A vs FAIL → CONTESTED (counts as FAIL). Overall verdict is PASS only when both reviewers' overall verdicts are PASS. Contested rules count as FAIL and show both rationales.
6. **Render the verdict.** Fill [assets/templates/verdict.md](assets/templates/verdict.md). On FAIL, aggregate every reviewer's "missing for PASS" suggestions into the fix list, each with its location, ordered by the source skill's category priority (struct → import → bound → fquery → fcomp → fstate → test → name).

If the same rule is repeatedly contested across reviews, the rule is not decidable enough — record it in [gotchas.md](gotchas.md) and sharpen the rule; do not override the gate.

## Verdict Format

Each reviewer returns, per rule: `PASS | FAIL | N/A`, evidence (`file:line` or a quote — required for PASS as well as FAIL), and for every FAIL, what is missing to reach PASS. The final report follows [assets/templates/verdict.md](assets/templates/verdict.md).

## Rule Categories

The categories, their priority order, and every rule live in the source skill; the imported subset and the 10 excluded rules (with reasons) are listed in [references/rules-source.md](references/rules-source.md).

## Reference Files

| File | Description |
|------|-------------|
| [references/reviewer-prompt.md](references/reviewer-prompt.md) | Self-contained prompt template for each blind reviewer |
| [assets/templates/verdict.md](assets/templates/verdict.md) | Verdict report template |
| [references/rules-source.md](references/rules-source.md) | Source skill pointer + imported rule subset |
| [metadata.json](metadata.json) | Version and source references |

## Related Skills

- `feature-arch` — the source distillation skill; designs the target architecture and holds every rule this gate enforces (plus the 10 judgment-call rules the gate excludes).
