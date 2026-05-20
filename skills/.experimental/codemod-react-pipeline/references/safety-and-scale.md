# Safety & Scale

How this pipeline keeps a 100k-file codemod from becoming a 100k-file incident — and how to roll
back when something still slips through.

## The four safety layers

1. **Dry-run before any write.** `03-dry-run.sh` previews the full change set and reverts. You read
   `findings.txt` (count + affected files + sample diff) before committing to anything.
2. **A sentinel + a hook enforce the dry-run.** `05-run-batched.sh` refuses to run without
   `dry-run.ok`. `hooks/hooks.json` additionally blocks an ad-hoc broad `codemod jssg run` that
   lacks `--dry-run` when no sentinel exists — so the gate can't be skipped by typing the command
   manually.
3. **Validation gates.** `04-validate-findings.sh` proves idempotency and runs typecheck/lint/
   format/tests on the would-be result. Per-batch gates in step 5 re-check each chunk.
4. **Per-batch checkpoint commits + clean-tree precondition.** Every batch is isolated and
   reversible; the pipeline starts only from a clean tree so any revert is exact.

## Batching strategy

`05-run-batched.sh` splits `src_globs` into `batch_size`-file batches. Each batch is applied,
verified, and committed atomically; `progress.tsv` records completion so re-running resumes.

Tuning `batch_size`:
- **Smaller (100–250):** more checkpoints, finer rollback granularity, more commits, more gate
  runs (slower overall). Good for risky transforms or flaky test suites.
- **Larger (1000+):** fewer commits, faster, coarser rollback. Good for mechanical, well-tested
  transforms.

Batches are file-ordered by default. If your transform has **cross-file effects** (renaming an
export consumed elsewhere), order won't keep related files together — use the `workflow.yaml`
matrix to shard by **module/team directory** instead, so a shard is internally consistent and its
typecheck gate is meaningful.

## Parallelism

- JSSG: `config.max_threads` → `codemod jssg run --max-threads N` (per-batch internal parallelism).
- Workflow: `strategy: { type: matrix, from_state: shards }` fans shards out concurrently. Each
  shard commits independently — ideal for branch/PR-per-module review at scale.

Parallelism multiplies a non-idempotent or non-deterministic transform's damage. Pass step 4's
idempotency gate before turning threads up.

## Resumability

State lives in `<state_dir>/<name>/`:
- `dry-run.ok` — the gate sentinel
- `files.txt` — the frozen work list (built once, reused on resume)
- `progress.tsv` — `<batch-index>\tok\t<sha>` per completed batch

To resume after any interruption, just re-run `05-run-batched.sh <name>` — completed batches are
skipped. To start over, delete the state dir.

> The codemod CLI has its own run-level resume: `codemod workflow resume -i <run-id>` (and
> `workflow status -i <run-id>` to inspect). Use that when you drive the migration through
> `workflow run` instead of the batch script.

## Rollback playbook

| Situation | Action |
|-----------|--------|
| One batch looks wrong, not pushed | `git reset --hard <sha>^` (sha from `progress.tsv`) |
| One batch looks wrong, already pushed | `git revert <sha>` |
| Whole migration, not pushed | `git log --oneline --grep='\[codemod-react-pipeline\]'`, then `git reset --hard <first-sha>^` |
| Whole migration, already pushed | `git revert <oldest>..<newest>` over the tagged range |
| Mid-inner-loop stray edits | `git checkout -- .` (inner loop should auto-revert, but this is the safety net) |

All checkpoint commits carry `[codemod-react-pipeline]` in the message, so the range is always
greppable.

## Excluding the wrong files

The fastest way to a bad large-scale run is touching files you didn't mean to:
- Narrow `src_globs` to the real surface area.
- Add `exclude` globs in `workflow.yaml` for tests, type decls, generated, and vendored code
  (`**/*.test.*`, `**/*.d.ts`, `**/__generated__/**`, `**/vendor/**`).
- The pipeline respects `.gitignore` by default (it lists files via `git ls-files`); `codemod jssg
  run` does too unless `--no-gitignore` is passed.

## Capabilities (least privilege)

JSSG is deny-by-default. Grant only the capabilities the transform truly needs in `codemod.yaml`
(rule `security-minimize-capabilities`). A pure AST rewrite needs none; reading sibling files for
context needs `fs`; nothing should need network. Review third-party codemods before running them
(`security-review-before-running-third-party`).
