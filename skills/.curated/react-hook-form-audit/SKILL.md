---
name: react-hook-form-audit
description: Use this skill to audit a Next.js (App Router, 14/15+) codebase for React Hook Form anti-patterns — watch() at form root, Controller inlined in parent, async submit without try/catch, missing setError on server failures, RHF in non-"use client" files, RHF mixed with useActionState, schemas defined inside components, useFieldArray without field.id keys, register({ disabled }) for visual disabling. Trigger when the user asks to audit/review/lint RHF usage, find form anti-patterns, or run a quality check on forms — even if they don't say "react-hook-form" by name, if they mention auditing forms in a Next.js project, use this skill. Read-only; emits a markdown report with file:line citations linking back to the companion `react-hook-form` distillation skill.
---

# React Hook Form Audit for Next.js

Static-analysis audit that detects 15 React Hook Form anti-patterns in Next.js App Router codebases. Combines ripgrep (fast pass for regex-detectable rules) with ts-morph (AST pass for structural rules). Outputs a markdown report grouped by severity, with file:line references and links back to the companion `react-hook-form` distillation skill.

## When to Apply

- User asks to audit, review, or lint React Hook Form usage in a Next.js project
- User reports symptoms like "the form re-renders too much" or "we have RHF bugs we can't pin down"
- Before a PR review of new RHF-heavy code
- As a CI gate (exit code 1 on CRITICAL/HIGH findings)
- After upgrading react-hook-form, to catch advice that drifted

## Tool Requirements

- `rg` (ripgrep) — install via `brew install ripgrep` or your package manager
- `node` ≥ 18 with `npm` — used to run the AST detectors via `ts-morph`
- `jq` — for JSON munging in the orchestrator

`ts-morph` is installed on first run into `scripts/node_modules/` (one-time, ~30s). The skill never touches the audited project's `node_modules`.

## Risk Level

**Read-only.** The skill reads source files and writes one markdown report (plus an optional JSON sidecar) to the audited project root. No git operations, no package mutations, no network calls.

## Workflow Overview

```
1. detect-project.sh   Verify Next.js + react-hook-form in package.json
2. collect-files.sh    Ripgrep for "use client" files importing RHF
3. detect-fast.sh      Ripgrep detectors (rules 5, 11, 14)
4. detect-ast.mjs      ts-morph detectors (rules 1-4, 6-10, 12-13, 15)
5. render-report.mjs   Render markdown + JSON; print summary; exit 0/1
```

See [`references/workflow.md`](references/workflow.md) for the per-step contract, error handling, and CI integration.

## Usage

```bash
# Audit the current directory
bash scripts/audit.sh

# Audit a specific project
bash scripts/audit.sh --project /path/to/nextjs-app

# Preview without writing the report file
bash scripts/audit.sh --dry-run
```

Exit codes:
- `0` — no CRITICAL or HIGH findings
- `1` — CRITICAL or HIGH findings exist
- `2` — environment or configuration error (missing tool, invalid project)

## Detector Catalog

15 detectors across 4 severities. See [`references/detectors.md`](references/detectors.md) for per-rule pattern, AST shape, false-positive notes, and the line of advice each detector enforces.

| ID | Severity | What it catches |
|----|---------|-----------------|
| 01 | CRITICAL | `watch()` in same component as `useForm()` |
| 02 | CRITICAL | `watch()` with no args (subscribes to all fields) |
| 03 | CRITICAL | `useForm()` without `defaultValues` |
| 04 | CRITICAL | `useEffect` depends on the `useForm` return |
| 05 | CRITICAL | RHF imported in a non-`"use client"` file |
| 06 | HIGH | `<Controller>` inlined inside `useForm()` parent |
| 07 | HIGH | Async submit handler without `try/catch` |
| 08 | HIGH | Validation schema defined inside the component |
| 09 | HIGH | Submit calls fetch/axios but never `setError('root.*')` |
| 10 | HIGH | RHF mixed with `useActionState` in same component |
| 11 | MEDIUM | `mode: 'onChange'` without explanatory comment |
| 12 | MEDIUM | `register({ disabled: <state> })` for visual disable |
| 13 | MEDIUM | `useFieldArray` map missing `field.id` as key |
| 14 | LOW | `reValidateMode: 'onBlur'` (now demoted advice) |
| 15 | LOW | `useFormContext()` usage (manual review) |

## How to Use

1. Confirm project is a Next.js App Router app with react-hook-form installed (`detect-project.sh` will check)
2. Run `bash scripts/audit.sh [--project <path>]`
3. Read the generated `.rhf-audit-report.md` in the project root
4. For each finding, follow the link to the companion distillation rule for the fix
5. After fixing, re-run to verify a clean audit

If a detector is too noisy in your project, narrow `include_globs` / widen `exclude_globs` in `config.json` rather than disabling detectors — the catalog is small enough that each finding should be either a real issue or a documented exception worth a comment.

## Setup

The skill ships with sensible defaults in `config.json`. On first run, `audit.sh` will install `ts-morph` into `scripts/node_modules/`. Override settings by editing `config.json`:

- `project_root` — absolute path to the project (defaults to current directory)
- `report_path` / `json_report_path` — output filenames (relative to project root)
- `rule_link_base` — base URL or path for companion-rule links
- `include_globs` / `exclude_globs` — narrow the scan surface

## Reference Files

- [`references/workflow.md`](references/workflow.md) — detailed workflow, error handling, CI integration
- [`references/detectors.md`](references/detectors.md) — per-detector spec, AST shape, false-positive notes
- [`gotchas.md`](gotchas.md) — accumulated failure modes (append-only)

## Related Skills

- `react-hook-form` — the companion distillation skill with the 45 rules this auditor enforces. Findings link directly to its reference files.
- `react-19` — for Server Action / `useActionState` patterns the audit explicitly does NOT cover
