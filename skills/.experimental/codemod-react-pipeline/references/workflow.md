# Codemod React Pipeline — Workflow Reference

Per-step documentation: what each step needs, produces, how it fails, and how to undo it. Run all
scripts from the **root of the codebase you are transforming** (not the skill directory).

## Prerequisites

- `codemod` CLI installed (or `npx codemod` reachable), `git`, `jq`.
- A clean git working tree (the pipeline refuses to run otherwise — see "Why clean tree" below).
- `config.json` filled in for this repo.

---

## Step 0 — `00-plan.sh "<goal>" [name]`

**Action:** Records the goal, counts files matching `src_globs` (blast radius), suggests a scale
tier, and writes a `plan.md` checklist that forces a classification decision (syntactic vs
programmatic vs semantic).
**Input:** A one-sentence goal. Optional kebab-case codemod name (derived from the goal otherwise).
**Output:** `<state_dir>/<name>/plan.md`.
**On failure:** Usually "not a git repo" or "jq missing" — install/cd and retry. Zero candidate
files means `src_globs` is wrong.
**Rollback:** N/A — read-only (writes only into the ignored state dir).

---

## Step 1 — `01-scaffold.sh <name> [--rule] [--force]`

**Action:** Renders `codemods/<name>/` from templates: `transform.ts` (or `rule.yml` with
`--rule`), a `tests/basic/{input,expected}.<ext>` fixture pair, `workflow.yaml`, and `codemod.yaml`.
**Input:** Codemod name; `--rule` for declarative ast-grep; `--force` to overwrite.
**Output:** The scaffolded codemod project.
**On failure:** Exits 2 if the codemod already exists (use `--force`). Bad name → kebab-case error.
**Rollback:** `rm -rf codemods/<name>` (nothing else is touched).

> Choosing the engine: declarative `rule.yml` for pure pattern→rewrite; `transform.ts` (JSSG) the
> moment you need conditionals, derived names, or multiple edits per match. See
> [inner-outer-loop.md](inner-outer-loop.md).

---

## Step 2 — `02-inner-loop.sh <name> [--watch | --file <path> | -u]`

**Action:** The tight loop. Default runs `codemod jssg test` against your fixtures. `--watch`
re-runs on change. `--file <path>` does a trial `jssg run` on one real file, prints the diff, then
**reverts it** (the inner loop never keeps edits). `-u` updates fixture snapshots (intentional only).
**Input:** Working fixtures and a transform under edit.
**Output:** Pass/fail test report, or a single-file diff.
**On failure:** Failing fixtures print the expected/actual diff — fix the transform or the fixture.
"No change produced" on `--file` means the pattern isn't matching: explore the AST
(https://ast-grep.github.io/playground.html).
**Rollback:** N/A — `--file` auto-reverts; tests never modify the tree.

Promote any real-file surprise into a new fixture case dir so it's covered forever.

---

## Step 3 — `03-dry-run.sh <name> [--target <dir>] [--sample N]`

**Action:** Previews the codemod across the codebase **without keeping changes**. Captures an exact
diff and an affected-file list, writes a findings report, then reverts the tree. On success writes
the **dry-run sentinel** that step 5 requires.
**Input:** A clean tree; a working transform.
**Output:** `<state_dir>/<name>/findings.txt`, `dry-run.diff`, and `dry-run.ok` (sentinel).
**On failure:** 0 changes → the sentinel is **not** written and it exits non-zero (the transform
isn't matching; return to step 2). A dirty tree is rejected so the captured diff is purely the
codemod's doing.
**Rollback:** Automatic — the tree is restored before the script returns.

`--sample N` previews a random N-file subset for a fast read on huge repos (cites
`test-run-on-subset-first`).

---

## Step 4 — `04-validate-findings.sh <name>`

**Action:** Applies the codemod to the clean tree, runs the enabled gates, then reverts. Nothing is
committed. Gates: **idempotency** (apply twice → no further change), **typecheck**, **lint**,
**format**, **tests** (the file-scoped gates receive the affected file list).
**Input:** Clean tree; gate commands set in `config.json`.
**Output:** Per-gate PASS/FAIL summary; gate logs in the state dir.
**On failure:** Exits non-zero and names the failing gate + log. Fix the transform or the gate
config; do **not** proceed to step 5.
**Rollback:** Automatic (an EXIT trap restores the tree even on error).

Idempotency failure is the most common and most important catch — it means a second pass keeps
editing (e.g. the pattern matches its own output). Fix per `pattern-ensure-idempotency`.

---

## Step 5 — `05-run-batched.sh <name> [--batch-size N] [--dry] [--resume]`

**Action:** The mass apply. Builds the file list, splits into batches of `batch_size`, and for each
batch: apply → per-batch gates (typecheck/lint/tests) → `git commit`. Progress is recorded in
`progress.tsv`; re-running **skips completed batches** (resumable). Requires the dry-run sentinel.
**Input:** Passing step 4; clean tree; sentinel present.
**Output:** One checkpoint commit per non-empty batch (message tagged
`[codemod-react-pipeline]`); updated `progress.tsv`.
**On failure:** The failing batch is **reverted** (its commit is never made), the script stops, and
the log path is printed. Fix, then re-run to resume from that batch — earlier commits stand.
**Rollback:**
- Undo one batch: `git revert <sha>` (or `git reset --hard <sha>^` if not pushed).
- Undo everything: `git log --oneline --grep='\[codemod-react-pipeline\]'` then reset/revert the range.

`--dry` prints the batch plan and changes nothing. `--batch-size` overrides the config value.

> The codemod-native alternative is `codemod workflow run -w codemods/<name>/workflow.yaml` with
> matrix sharding + a manual approval gate. Use it when you want the run orchestrated by the CLI;
> note the cloud-only `commit:` caveat in [gotchas.md](../gotchas.md).

---

## Step 6 — `verify.sh <name>`

**Action:** Final sign-off. Asserts: every batch recorded complete (none failed); **re-running the
codemod is a no-op** (migration complete + idempotent); the project type-checks; no `CODEMOD-TODO`
markers remain.
**Input:** A completed, committed migration.
**Output:** Pass/fail assertion summary.
**On failure:** Names the failed assertion. A non-no-op re-run means files were missed — re-run
step 5; leftover markers mean manual follow-ups are outstanding.
**Rollback:** N/A — read-only (reverts its probe re-application).

---

## Why a clean tree

Every reverting step (`03`, `04`) and every checkpoint (`05`) relies on `git checkout -- .` to undo
the codemod's edits. If the tree already had unrelated changes, that undo would also discard your
work. The pipeline refuses to start dirty so rollback is always exact. Stash or commit first.

## Troubleshooting

### "No dry-run on record for '<name>'"
**Cause:** Step 5 (or the hook) found no `dry-run.ok` sentinel.
**Fix:** Run `03-dry-run.sh <name>` and `04-validate-findings.sh <name>` first.

### Dry-run shows 0 changes
**Cause:** The pattern doesn't match real code. **Fix:** Open the AST playground, compare your
pattern to the actual node kinds, widen/narrow meta-variables, re-test fixtures (step 2).

### A gate passes locally but fails in a batch
**Cause:** Cross-file effects (a batch breaks a file in another batch). **Fix:** Re-shard so related
files land together (workflow.yaml matrix by module), or run a project-wide typecheck gate.

### `xargs` "argument list too long" on a huge affected set
**Cause:** Too many files for one command. **Fix:** Lower `batch_size`; the per-batch gates then run
on smaller file lists.
