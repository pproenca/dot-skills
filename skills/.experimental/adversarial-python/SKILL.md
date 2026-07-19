---
name: adversarial-python
description: Use this skill to gate Python code (floors 3.10+, rules verified through 3.14) with a pass/fail adversarial review — a single blind reviewer subagent judges a diff or file set against 20 decidable rules hunting two failure modes. First, code modern Python makes unnecessary — branch ladders over match/registries, hand-written init/repr/eq over dataclasses, TypeVar ritual over PEP 695, typing.Optional over PEP 604 unions, os.path over pathlib, hand-rolled stdlib batteries, deprecated utcnow, orphan create_task over TaskGroup. Second, legacy-pattern propagation — single-implementation ABCs, pass-through layers, single-method classes, concrete-inheritance reuse, boolean-forked functions, shapeless payloads and parameter clumps — judged as if greenfield; consistency with legacy code is not PASS evidence. A version probe reads the target's Python floor, marks rules above it N/A, and fetches the official what's-new delta when the floor exceeds the verified version. Verdicts only, never fixes.
---

# Adversarial Python Gate

A modern-idiom and code-structure review gate for Python — pass/fail: a single blind reviewer subagent judges the work against this gate's rules with an adversarial mandate, and the work passes only when every rule is PASS or N/A. This skill renders verdicts; it never fixes the work.

The rules target two failure modes with one root cause — the author reproduced a shape instead of designing one. **Training-data inertia** produces code a modern Python feature deletes outright: the `if/elif` ladder that `match` or a registry replaces, the `__init__`/`__repr__`/`__eq__` triple that `@dataclass(slots=True)` generates, the `TypeVar` ritual PEP 695 retired, the chunking helper `itertools.batched` shipped. **Legacy-pattern propagation** produces new code faithfully extending the surrounding codebase's bad structure — one more branch on the event ladder, one more method on the pass-through service — instead of tracing the feature end-to-end and modeling it. Each rule carries an **Evidence of violation** paragraph so a reviewer can decide PASS/FAIL/N/A from artifact evidence alone, and a `Requires Python ≥ 3.X` gate where the fix depends on a language version.

## When to Apply

- A Python feature, endpoint, or module (agent-authored or human) is about to merge and needs an objective PASS/FAIL on whether modern Python and a fresh architectural look would delete or restructure it.
- An agent extended a legacy codebase and you suspect it copied the existing patterns — event/version branch ladders, service layers that only forward, stringly-typed state — instead of re-architecting the feature.
- A codebase raised its Python floor (to 3.12, 3.13, 3.14+) and changed code should be held to the idioms the new floor enables.
- A refactor claims to modernize or simplify and you want the claim verdict-checked rather than diff-skimmed.

Do not apply to targets with no Python source (the reviewer prompt's precondition aborts with "GATE NOT APPLICABLE"), or when the user wants explanations and refactors rather than a verdict. Judgment calls the gate deliberately excludes — naming taste, function length, docstring and test coverage, performance tuning — belong to advisory skills, not this gate.

## Review Protocol

Follow these steps exactly — the gate's value is that every review runs the same way.

1. **Identify the target.** Pin down exactly what is under review (a diff, a set of files, a PR) and note the ref/paths so the review runs against an unambiguous, fixed target. Include the repo root — several `alt-` and `disp-` rules must search beyond the diff for implementers, substitution sites, test doubles, and call sites (the reviewer prompt lists them).
2. **Probe the Python version.** Read the target's Python floor from `pyproject.toml` (`requires-python`), `.python-version`, `setup.cfg`, or the CI matrix — cite the source; if undeclared, judge as the newest stable Python and say so. Then compare the floor against `verified_python` in [metadata.json](metadata.json):
   - floor ≤ verified: proceed; version-gated rules above the floor will be N/A.
   - floor > verified: fetch `https://docs.python.org/3/whatsnew/3.{N}.html` for each version in the gap and compose a **delta briefing** — new stdlib batteries (they extend the `std-no-hand-rolled-batteries` table), new syntax and typing forms (they extend the `disp-`/`typing-` rules' reach), each line with its citation. The briefing goes into the reviewer prompt's `{{VERSION_DELTA_BRIEFING}}` slot. After the review, record the delta in [gotchas.md](gotchas.md) so the rules can be re-verified and `verified_python` bumped.
3. **Load the rules.** Read [references/_sections.md](references/_sections.md) and every rule file in `references/` (all `disp-*.md`, `model-*.md`, `alt-*.md`, `typing-*.md`, `std-*.md`, `flow-*.md` files).
4. **Compose the reviewer prompt.** Fill [references/reviewer-prompt.md](references/reviewer-prompt.md) with the rules, the target, the Python floor, and the delta briefing (if any). The composed prompt must be fully self-contained — a reviewer sees no conversation history, so nothing may refer to context outside the prompt.
5. **Dispatch one blind reviewer.** Launch a single Task subagent whose entire input is the composed prompt — no conversation context, no commentary alongside it.
6. **Render fail-closed.** The reviewer's structured output is the verdict — there is no merge step. Overall verdict is PASS only when every rule is PASS or N/A; any single FAIL fails the gate. Never average, weigh severity, or waive a rule — a "minor" FAIL is a FAIL. If the reviewer returns "GATE NOT APPLICABLE" (no Python source in the target), stop and report that instead of a verdict.
7. **Render the verdict.** Fill [assets/templates/verdict.md](assets/templates/verdict.md). On FAIL, aggregate the reviewer's "missing for PASS" suggestions into the fix list, each with its location, ordered by category importance. Every rule whose result is FAIL must appear in the fix list with a change concrete enough to apply as written — if the reviewer's suggestion only restates the violation, derive the fix from the rule's correct example before rendering.

If the same rule flips verdicts across re-reviews of an unchanged target, or a human reads the evidence and overrides the verdict, that is a decidability bug in the rule — record it in [gotchas.md](gotchas.md) and sharpen the rule; do not override the gate.

## Verdict Format

The reviewer returns, per rule: `PASS | FAIL | N/A`, evidence (`file:line` or a quote — required for PASS as well as FAIL), and for every FAIL, the fix that flips the rule to PASS once applied — the named change plus its location, never a restatement of the violation. The final report follows [assets/templates/verdict.md](assets/templates/verdict.md).

## Rule Categories

| # | Category | Prefix | The wrong default it gates |
|---|----------|--------|----------------------------|
| 1 | Dispatch & Control Flow | `disp-` | Branch ladders where the design has a dispatch construct — event/version `if/elif` chains over registries/`match`, isinstance ladders over patterns, repeated state literals over `StrEnum`, boolean params forking whole bodies |
| 2 | Data Modeling | `model-` | Data that never got a shape — hand-written `__init__`/`__repr__`/`__eq__` over `@dataclass(slots=True)`, parameter clumps threaded through signatures, external payloads navigated by string keys past the boundary |
| 3 | Abstraction Altitude | `alt-` | Layers that add indirection without a decision — single-method classes, 1:1 pass-through wrappers, single-implementation ABCs (a consumer-side `Protocol` is the seam), concrete inheritance for reuse |
| 4 | Modern Typing | `typing-` | Pre-3.10 spellings by habit — `typing.List`/`Optional`/`Union` over builtins and `X \| None`, `TypeVar`/`Generic` ritual over PEP 695, class-name returns over `Self` |
| 5 | Stdlib Currency | `std-` | Hand-rolled batteries — `os.path` surgery over `pathlib`, re-implemented `batched`/`pairwise`/`cache`/`tomllib`, deprecated `utcnow()`, unchecked `zip` over independent sources; extended by the version-delta briefing |
| 6 | Async & Error Flow | `flow-` | Failure paths that vanish — fire-and-forget `create_task` over `TaskGroup`, broad `except` bodies that swallow without logging or recording |

## Gotchas

Read [gotchas.md](gotchas.md) before dispatching the reviewer — it pre-records scope guards (the version probe's edge cases, shapes-not-brands, the diff-vs-repo search obligations, what "greenfield judgment" does and does not license) so the reviewer does not judge outside the rules.

## Related Skills

- `adversarial-ts-patterns` — the TypeScript/React sibling gate for the same disease (over-abstraction and under-modeling); same protocol, different language.
- `radical-simplification` — the advisory sibling: cognitive moves for collapsing complexity when you want to *fix* a failed verdict, not judge it.

## Reference Files

| File | Description |
|------|-------------|
| [references/reviewer-prompt.md](references/reviewer-prompt.md) | Self-contained prompt template for each blind reviewer |
| [assets/templates/verdict.md](assets/templates/verdict.md) | Verdict report template |
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [metadata.json](metadata.json) | Version, `verified_python`, and source references |
