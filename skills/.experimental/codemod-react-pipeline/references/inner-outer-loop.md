# The Inner/Outer Loop Model

Large-scale codemods fail when people treat them as one big run. This pipeline splits the work into
two loops with different goals, cadences, and blast radii.

## The inner loop — make the transform correct (fast, local, reversible)

Goal: a transform that does the right thing on every shape it will meet. Cadence: seconds to
minutes. Blast radius: fixtures and one real file at a time.

```
edit transform.ts ─▶ jssg test (fixtures) ─▶ trial on 1 real file ─▶ inspect diff ─▶ revert ─▶ repeat
```

- **Drive it with fixtures, not the codebase.** Each `tests/<case>/{input,expected}` pair pins one
  behaviour. New surprise in a real file → add a fixture, never "fix it once by hand."
- **Explore the AST before writing patterns.** Node kinds and field names are not guessable; use
  https://ast-grep.github.io/playground.html (rule `ast-explore-before-writing`).
- **Keep the diff between input and expected minimal** — same names, same structure — so the
  fixture documents exactly one transformation.
- **`02-inner-loop.sh --watch`** keeps the loop tight; **`--file <path>`** sanity-checks against
  real code and auto-reverts so you never accumulate stray edits.

You leave the inner loop when fixtures cover the known edge cases (happy path, already-migrated,
nested, spread props, …) and a trial on a real file looks right.

## The outer loop — apply it safely at scale (gated, batched, committed)

Goal: land the change across the whole codebase with the build green at every step and a clean
rollback story. Cadence: minutes to hours. Blast radius: the whole `src_globs` set.

```
dry-run (preview findings) ─▶ validate (gates) ─▶ batched apply (per-batch verify + commit) ─▶ verify
```

- **Dry-run first, always.** You inspect *what* would change and *how many* files before any write
  (rule `test-run-on-subset-first`). The pipeline enforces this with a sentinel + a PreToolUse hook.
- **Validate the findings, don't trust them.** Idempotency, typecheck, lint, format, and tests run
  on the would-be result. Idempotency is the headline gate (rule `pattern-ensure-idempotency`).
- **Batch + checkpoint.** Apply in chunks, verify each, commit each. A mid-run failure costs one
  batch, not the whole migration, and the run resumes (rule `state-use-for-resumability`).
- **Verify the end state**, not just exit codes: re-running the codemod must be a no-op.

## How the loops connect

The inner loop produces an artifact (the transform + fixtures); the outer loop consumes it. The
dry-run sentinel is the handshake: the outer loop's apply step refuses to run until a dry-run has
happened, which in practice means the transform left the inner loop and was previewed.

## Picking the engine in the inner loop

| Transformation shape | Engine | Why |
|----------------------|--------|-----|
| One pattern → one rewrite, no logic | declarative **ast-grep `rule.yml`** | Fast, deterministic, least to get wrong |
| Conditional edits, derived names, many edits/match | **JSSG `transform.ts`** | Full programmatic control |
| Needs imports / symbol resolution / types | **JSSG transform.ts** (+ import fixups, optional `ai:` cleanup step) | Cross-file awareness |

When in doubt, start with a rule; promote to a transform the moment you reach for an `if`.

## Scale tiers (set expectations for the outer loop)

| Candidate files | Tier | Outer-loop posture |
|-----------------|------|--------------------|
| < 200 | small | Single batch is fine — still dry-run + validate first |
| 200–5k | medium | Batched recommended; per-batch verify catches cross-file breakage early |
| 5k–50k | large | Batched + per-batch verify mandatory; expect to resume at least once |
| > 50k | very large | Batched + resumable + parallel (`max_threads`/workflow matrix); plan for multi-hour, multi-session runs |
