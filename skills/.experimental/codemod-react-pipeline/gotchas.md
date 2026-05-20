# Gotchas

Failure points discovered building and running large React/TSX codemods with this pipeline. Add to
this list as the field teaches you more.

## Workflow `commit:` checkpoints are cloud-only

The `commit:` step option in `workflow.yaml` (`commit: { message, add }`) is a **Codemod
Campaign/cloud** feature. A local `codemod workflow run` will not create those commits. This
pipeline sidesteps it two ways: `05-run-batched.sh` commits per batch itself, and the generated
`workflow.yaml` checkpoints via an explicit `run: git add -A && git commit` step. Don't rely on
`commit:` locally.

## Placeholder syntax vs. Codemod interpolation

The scaffolder substitutes `__NAME__`-style tokens. Codemod's own templating uses `${{ matrix.x }}`
and `${{ state.x }}`. They don't collide — but if you hand-edit templates, keep your placeholders in
the `__UPPER__` form and leave every `${{ … }}` untouched.

## Idempotency is on you, and it bites at scale

A transform that matches its own output keeps editing on every pass: re-runs never settle, parallel
shards corrupt overlapping regions, and `verify.sh` will fail. Make the pattern unable to match the
result (e.g. rewrite `<FieldGroup>`→`<Fieldset>`, never `<X>`→`<X …>`). Step 4's idempotency gate
catches this before mass apply — don't disable it.

## Dirty working tree blocks the pipeline (by design)

Reverting steps and checkpoints use `git checkout -- .`. With unrelated uncommitted changes present,
that would discard your work, so the pipeline refuses to start dirty. Commit or `git stash` first.
This is a feature, not a bug.

## `tsc --noEmit` is project-wide, not file-scoped

TypeScript type-checks the whole program; you can't reliably check "just these 500 files." The
typecheck gate therefore runs project-wide each batch — correct, but slower on big repos. For very
large codebases, consider checking typecheck only at the end (`verify.sh`) and relying on lint+tests
per batch, accepting that a type break surfaces later.

## Embedded languages need a separate pass

GraphQL in `gql\`…\``, CSS in styled-components, SQL in template literals — the `tsx` parser sees
these as plain template strings. A single transform won't reach inside them. Handle embedded
languages with a dedicated parse pass (rule `parse-handle-embedded-languages`); don't try to regex
them from the TSX transform.

## `git ls-files` only sees tracked files

The work list is built from `git ls-files`, so untracked new files aren't included (and `.gitignore`
is respected). Usually what you want for a migration; if you must transform untracked files, add
them first or pass `--no-gitignore` to `codemod jssg run` knowingly.

## JSSG import names can drift between CLI versions

The transform template imports `Codemod` and `langs/<lang>` per
https://docs.codemod.com/jssg/reference. If your installed `codemod` version exports `Transform`
instead of `Codemod`, or a different langs path, adjust the import — the rest of the API
(`findAll`/`getMatch`/`replace`/`commitEdits`) is stable.

## `xargs` argument limits on huge affected sets

File-scoped gates pipe the affected list through `xargs`. A pathological batch can exceed the OS arg
limit; lower `batch_size` so each batch's file list stays manageable.

## The PreToolUse hook only guards this session

`hooks/hooks.json` is an on-demand hook active while the skill is in use. It is not a permanent
safeguard on the repo — it won't protect a teammate running `codemod jssg run` from a fresh shell.
Treat the dry-run discipline as a team convention, not just a hook.
