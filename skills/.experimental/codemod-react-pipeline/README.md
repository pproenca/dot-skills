# Codemod React Pipeline

A guided, scripted pipeline for running **JSX / TSX / React codemods safely on large legacy
codebases** — from 50 files to several hundred thousand.

It composes the [Codemod CLI](https://docs.codemod.com) (JSSG, ast-grep, workflows) into a
repeatable inner/outer loop:

```
goal → scaffold → inner loop → dry-run → validate findings → batched apply → verify
```

This is a **composition** skill (a workflow). For the *why* behind each transformation
decision, see the sibling [`codemod`](../codemod/) best-practices reference.

## Why a pipeline

A naive `codemod jssg run ./transform.ts ./src` on a large repo is a footgun: you discover the
bug after 1,800 files changed, the diff is unreviewable, a mid-run crash forces a restart, and a
non-idempotent transform corrupts files on the second pass. This pipeline removes those failure
modes by gating mass application behind a dry-run and a set of validation checks, then applying
in resumable, individually-verified, individually-committed batches.

## Structure

```
codemod-react-pipeline/
├── SKILL.md                  # Entry point: workflow overview + triggers
├── metadata.json             # discipline: composition, type: automation
├── config.json               # Per-project setup (globs, language, gate commands, batch size)
├── gotchas.md                # Failure points discovered in the field
├── scripts/
│   ├── lib/common.sh         # Shared helpers (config, logging, git, affected files)
│   ├── 00-plan.sh            # Goal intake + blast-radius estimate
│   ├── 01-scaffold.sh        # codemod init + render templates
│   ├── 02-inner-loop.sh      # Fixture tests + single-file run (tight loop)
│   ├── 03-dry-run.sh         # Preview changes, write findings report + sentinel
│   ├── 04-validate-findings.sh  # Idempotency / typecheck / lint / format / tests
│   ├── 05-run-batched.sh     # Resumable batched apply with checkpoint commits
│   ├── verify.sh             # Final assertions over the whole migration
│   ├── guardrail.sh          # Hook backend: block mass apply without a dry-run
│   └── selftest.sh           # Self-test for this skill's scripts
├── hooks/
│   └── hooks.json            # PreToolUse guard, active during the skill session
├── assets/templates/         # transform.ts, ast-grep rule, workflow.yaml, fixtures, codemod.yaml
└── references/               # workflow.md, inner-outer-loop.md, safety-and-scale.md
```

## Requirements

- [`codemod` CLI](https://www.npmjs.com/package/codemod) — `npm i -g codemod` (or `npx codemod`)
- `git` — the pipeline relies on a clean working tree and per-batch commits
- `jq` — used by the scripts to read `config.json`
- Project tooling for the gates you enable (TypeScript, ESLint, Prettier, a test runner)

## Quick start

```bash
cd /path/to/your/repo                      # the target codebase
SKILL=/path/to/codemod-react-pipeline

bash "$SKILL/scripts/00-plan.sh" "Replace <FieldGroup> with <Fieldset> across the app"
bash "$SKILL/scripts/01-scaffold.sh" rename-fieldgroup
# ...edit codemods/rename-fieldgroup/transform.ts + tests...
bash "$SKILL/scripts/02-inner-loop.sh" rename-fieldgroup
bash "$SKILL/scripts/03-dry-run.sh" rename-fieldgroup
bash "$SKILL/scripts/04-validate-findings.sh" rename-fieldgroup
bash "$SKILL/scripts/05-run-batched.sh" rename-fieldgroup
bash "$SKILL/scripts/verify.sh" rename-fieldgroup
```

See [`SKILL.md`](SKILL.md) for the full workflow and [`references/workflow.md`](references/workflow.md)
for per-step inputs, outputs, failure handling, and rollback.

## Self-test

```bash
bash scripts/selftest.sh
```

Checks script syntax, strict-mode headers, hook JSON validity, and (if the `codemod` CLI is
installed) validates the workflow template.
