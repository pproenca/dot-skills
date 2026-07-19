---
name: feature-arch-gate
description: Adversarial pass/fail review gate that enforces the feature-arch skill's React feature-based architecture rules. Use when a diff, branch, PR, or src/ tree must be judged for architecture conformance before merge — feature folder structure, import boundaries, cross-feature isolation, data-fetching, state, testing, and naming rules. A single blind reviewer renders per-rule PASS/FAIL verdicts with cited evidence, and the reviewer's structured output is the verdict fail-closed. Use the feature-arch skill itself to design or migrate an architecture; use this gate to judge whether work conforms to it.
---

# Feature-Arch Gate

Enforce React feature-based architecture conformance — a pass/fail gate: a single blind reviewer subagent judges the work against the rules of feature-arch v1.1.0 with an adversarial mandate, and the work passes only when every rule is PASS or N/A. This skill renders verdicts; it never fixes the work.

The gate is **self-sufficient**: the 33 decidable rules it enforces (of the source's 43) are vendored into this skill's `references/` directory as a snapshot of feature-arch v1.1.0, so a review needs nothing outside this folder. [references/_rule-evidence.md](references/_rule-evidence.md) records the provenance, the evidence that decides each rule, and the 10 source rules excluded as non-decidable.

## When to Apply

- A PR or branch touching a feature-organized React codebase needs an architecture conformance verdict before merge.
- A migration step from a `FEATURE-ARCH-TARGET.md` blueprint is claimed complete and needs independent verification.
- A full `src/` tree audit is requested ("does this codebase conform to feature-arch?").
- Agent-generated feature work needs a gate that is blind to the conversation that produced it.

Do NOT apply this gate to design or migrate an architecture — that is the `feature-arch` skill's job (it produces the blueprint; this skill judges conformance to the rules).

## Review Protocol

Follow these steps exactly — the gate's value is that every review runs the same way.

1. **Identify the target.** Pin down exactly what is under review (a diff, a set of files, or a full `src/` tree) and note the ref/paths so the review runs against an unambiguous, fixed target. Record two context facts the reviewer needs: does the codebase use React Server Components, and is a query library (TanStack Query etc.) present — two rules are N/A without them.
2. **Load the rules.** Read [references/_rule-evidence.md](references/_rule-evidence.md) and resolve the 33 vendored rule files it lists against this skill's own `references/` directory. If any listed rule file is missing or unreadable, **STOP and report the error** — never proceed with partial rules or silently pass.
3. **Compose the reviewer prompt.** Fill [references/reviewer-prompt.md](references/reviewer-prompt.md) with the rule file paths, the target, and (if the target repo has one) its `docs/architecture/FEATURE-ARCH-TARGET.md` blueprint. The composed prompt must be fully self-contained — a reviewer sees no conversation history, so nothing may refer to context outside the prompt.
4. **Dispatch one blind reviewer.** Launch a single Task subagent whose entire input is the composed prompt — no conversation context, no commentary alongside it.
5. **Render fail-closed.** The reviewer's structured output is the verdict — there is no merge step. Overall verdict is PASS only when every rule is PASS or N/A; any single FAIL fails the gate. Never average, weigh severity, or waive a rule — a "minor" FAIL is a FAIL.
6. **Render the verdict.** Fill [assets/templates/verdict.md](assets/templates/verdict.md). On FAIL, aggregate the reviewer's "missing for PASS" suggestions into the fix list, each with its location, ordered by the source skill's category priority (struct → import → bound → fquery → fcomp → fstate → test → name). Every rule whose final result is FAIL must appear in the fix list with a change concrete enough to apply as written — if the reviewer's suggestion only restates the violation, derive the fix from the rule's Correct example before rendering.

If the same rule flips verdicts across re-reviews of an unchanged target, or a human reads the evidence and overrides the verdict, that is a decidability bug in the rule — record it in [gotchas.md](gotchas.md) and sharpen the rule; do not override the gate.

## Verdict Format

The reviewer returns, per rule: `PASS | FAIL | N/A`, evidence (`file:line` or a quote — required for PASS as well as FAIL), and for every FAIL, the fix that flips the rule to PASS once applied — the named change plus its location, never a restatement of the violation. The final report follows [assets/templates/verdict.md](assets/templates/verdict.md).

## Rule Categories

The eight categories and their priority order are defined in [references/_sections.md](references/_sections.md); the 33 vendored rule files live alongside it in `references/`, and [references/_rule-evidence.md](references/_rule-evidence.md) lists them with the evidence that decides each, plus the 10 excluded source rules (with reasons).

## Reference Files

| File | Description |
|------|-------------|
| [references/reviewer-prompt.md](references/reviewer-prompt.md) | Self-contained prompt template for the blind reviewer |
| [assets/templates/verdict.md](assets/templates/verdict.md) | Verdict report template |
| [references/_rule-evidence.md](references/_rule-evidence.md) | Vendoring provenance + per-rule deciding evidence + exclusions |
| [references/_sections.md](references/_sections.md) | Category definitions and fix-list priority order |
| `references/<category>-*.md` | The 33 vendored rule files (struct/import/bound/fquery/fcomp/fstate/test/name) |
| [metadata.json](metadata.json) | Version and source references |

## Related Skills

- `feature-arch` — the source distillation skill this gate's rules were vendored from; use it (if available) to design or migrate the target architecture, and to read the 10 judgment-call rules the gate excludes. The gate itself never needs it at review time.
