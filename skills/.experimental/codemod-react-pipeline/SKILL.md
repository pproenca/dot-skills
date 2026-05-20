---
name: codemod-react-pipeline
description: Guided, scripted pipeline for running JSX/TSX/React codemods safely across large legacy codebases. Use when you need to scaffold a codemod, dry-run it, validate its findings, and apply it across many files (50 to 100k+) without breaking the build. Walks the full inner/outer loop with the Codemod CLI (JSSG, ast-grep, workflows). Triggers on large-scale refactor, legacy React migration, codemod a prop/API change, migrate components across the codebase, run a codemod safely, batched/resumable codemod apply, dry-run a codemod.
---

# Codemod React Pipeline

A safe, repeatable workflow for applying **JSX / TSX / React codemods to large legacy
codebases** — from a 50-file rename to a 100k-file API migration. It composes the
[Codemod CLI](https://docs.codemod.com) (JSSG, ast-grep, workflows) into an inner/outer loop and
gates every mass change behind a dry-run plus validation. For the *why* behind each rule it cites,
see the sibling [`codemod`](../codemod/) best-practices reference.

## When to Apply

Use this skill when:
- You're migrating a pattern across a large React/TS codebase (component/prop rename, deprecated
  API, import swap, hook migration) and a hand-run `codemod jssg run ./t.ts ./src` is too risky.
- You need the change to land **incrementally and reviewably** — per-batch commits, resumable on
  failure, with the build/typecheck/tests green at every checkpoint.
- You want to **see and validate the findings** (what would change, and whether it's safe) before
  touching files at scale.
- The transform must be **idempotent** and proven so before mass apply.

Don't use it for a one-file edit, or a change better done by hand in a single PR.

## Workflow Overview

```
00 plan ─▶ 01 scaffold ─▶ 02 inner loop ─▶ 03 dry-run ─▶ 04 validate ─▶ 05 batched apply ─▶ 06 verify
   goal       templates      fixture tests     preview       gates          per-batch            final
   + blast    (transform/    + 1-file trial    + findings     (idempotency,  apply+verify+commit  assertions
   radius     rule/wf/tests)                    report        type/lint/test) (resumable)
                                                  │                                  │
                                                  └── sentinel ──── required by ──────┘
                              (on any failure: working tree reverted; fix and re-run — nothing committed yet)
```

| Step | Action | Tool / Script | Risk |
|------|--------|---------------|------|
| 0 | Capture goal, classify transform, count blast radius | `scripts/00-plan.sh` | read-only |
| 1 | Scaffold transform + fixtures + workflow from templates | `scripts/01-scaffold.sh` | write (new files) |
| 2 | Fixture tests + single-file trial run (auto-reverted) | `scripts/02-inner-loop.sh` | read-only (reverts) |
| 3 | Preview changes; write findings report + dry-run sentinel | `scripts/03-dry-run.sh` | read-only (reverts) |
| 4 | Gate: idempotency, typecheck, lint, format, tests | `scripts/04-validate-findings.sh` | read-only (reverts) |
| 5 | Apply in resumable batches, verify + commit each | `scripts/05-run-batched.sh` | **destructive** (commits) |
| 6 | Final assertions over the whole migration | `scripts/verify.sh` | read-only |

A PreToolUse hook (`hooks/hooks.json`) blocks a broad `codemod jssg run` that lacks `--dry-run`
when no dry-run sentinel exists — so step 5 (or an ad-hoc apply) cannot skip steps 3–4.

## Requirements

- **Codemod CLI** — `npm i -g codemod` (or the scripts fall back to `npx codemod`). Provides
  `jssg run/test` and `workflow run/validate/resume/status`.
- **git** — the pipeline requires a clean tree and makes per-batch checkpoint commits.
- **jq** — the scripts read `config.json` with it.
- **Your project's gate tooling** — TypeScript, ESLint, Prettier, a test runner (whichever gates
  you enable in `config.json`).

## Setup

Edit `config.json` for the target repo (see each field's `_setup_instructions`):
- `src_globs`: the files the codemod may touch (scopes blast radius + gates)
- `language`: `tsx` | `jsx` | `typescript` | `javascript`
- `typecheck_cmd` / `lint_cmd` / `format_cmd` / `test_cmd`: gate commands (empty disables a gate)
- `batch_size`: files per checkpoint in the outer loop
- `gates`: per-gate on/off toggles

Add your `state_dir` (default `.codemod-pipeline`) to the target repo's `.gitignore`.

## Quick Reference

| Script | Purpose |
|--------|---------|
| `scripts/00-plan.sh "<goal>" [name]` | Plan + blast-radius estimate |
| `scripts/01-scaffold.sh <name> [--rule]` | Scaffold a JSSG transform (or ast-grep rule) |
| `scripts/02-inner-loop.sh <name> [--watch\|--file P\|-u]` | Tight loop: fixture tests / 1-file trial |
| `scripts/03-dry-run.sh <name> [--sample N]` | Preview; write findings + sentinel |
| `scripts/04-validate-findings.sh <name>` | Run validation gates |
| `scripts/05-run-batched.sh <name> [--batch-size N\|--dry]` | Resumable batched apply + commits |
| `scripts/verify.sh <name>` | Final sign-off assertions |
| `scripts/selftest.sh` | Self-test this skill's scripts/assets |

## How to Use

1. From the **target repo root**, run `00-plan.sh "<goal>"` and read the generated `plan.md`.
2. `01-scaffold.sh <name>`, then implement `codemods/<name>/transform.ts` and its fixtures.
3. Iterate with `02-inner-loop.sh <name> --watch` until fixtures pass; try `--file <path>` on a real file.
4. `03-dry-run.sh <name>` and read the findings report; then `04-validate-findings.sh <name>`.
5. Only after gates pass: `05-run-batched.sh <name>` (resume by re-running it after any fix).
6. `verify.sh <name>` to confirm the migration is complete and idempotent.

See [references/workflow.md](references/workflow.md) for per-step inputs, outputs, failure handling,
and rollback; [references/inner-outer-loop.md](references/inner-outer-loop.md) for the mental model;
and [references/safety-and-scale.md](references/safety-and-scale.md) for batching and rollback at
100k-file scale.

## Gotchas

See [gotchas.md](gotchas.md). The big ones: workflow `commit:` checkpoints are **cloud-only** (the
pipeline commits locally instead); always exclude generated/vendored trees; and design for
idempotency from the first line.

## Related Skills

- [`codemod`](../codemod/) — the best-practices reference (48 rules) this pipeline operationalizes.
  Steps here cite specific rules (e.g. `test-run-on-subset-first`, `state-use-for-resumability`,
  `pattern-ensure-idempotency`, `security-minimize-capabilities`).
