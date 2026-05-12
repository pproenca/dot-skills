# Workflow — Detailed

The full iteration loop, with error handling and rollback. Read this when running the skill — SKILL.md is the quick reference; this is the operating manual.

## Mental model

> Bundle and build-time optimization is empirical. Theories about what's "slow" are usually wrong. Trust the analyzer, change one thing, measure again, keep what works.

The loop has six scripts. Each one's exit code is a checkpoint. If any step fails, you stop and revert — you don't paper over the failure and continue.

```
                git: clean tree required
                          │
                          ▼
                    baseline.sh        ──► baselines/{ts}/
                          │                ↳ symlinked as baselines/current
                          ▼
              ┌── analyze.sh             ──► iterations/{ts}/findings.json
              │           │
              │           ▼
              │     diagnose.sh          ──► stdout: ranked recipes
              │           │
              │           ▼
              │   APPLY ONE RECIPE
              │   (manual; agent helps draft)
              │           │
              │           ▼
              │     measure.sh           ──► iterations/{ts}/{bundle,timing}.json
              │           │
              │           ▼
              │     compare.sh           ──► stdout: delta table; exit 1 on regression
              │           │
              │           ▼
              │     verify.sh            ──► build + tsc + tests + no-regression
              │           │
              │           ├── PASS ─► git commit ─► (loop or stop)
              │           │
              │           └── FAIL ─► git reset --hard HEAD ─► loop with next recipe
              │
              └─────────────────────────────────────────────────────────
                            (loop back to analyze or to a fresh baseline
                             if you want a new measurement point)
```

## Step-by-step

### 0. Prerequisites (one-time)

1. `config.json` populated (see `_setup_instructions`).
2. Working tree clean: `git status` shows nothing.
3. `jq` available: `command -v jq` succeeds.
4. Production build works at all: `npm run build` (or your `build_command`) succeeds at HEAD.

If any fails: fix the prerequisite. The skill cannot help while the build is broken.

### 1. `baseline.sh` — establish the reference point

**What it does:**
- `rm -rf .next` (cold build for reproducibility)
- Runs `$BUILD_COMMAND`, captures wall-clock time
- For Next.js 16 + Turbopack: runs `next experimental-analyze --output`
- Snapshots `.next/build-manifest.json` and `.next/app-build-manifest.json`
- Sums per-chunk bytes per route → `baselines/{ts}/bundle.json`
- Saves `timing.json` with `build_seconds` and `cache: "cold"`
- Symlinks `baselines/current` → this run

**Failure modes:**
- Build fails → `exit 1`. Fix the build at HEAD; nothing this skill does helps a broken main branch.
- `experimental-analyze` fails → continues with a warning (manifest-only snapshot still works).

**When to re-baseline:**
- After a successful optimization commit, if you want to start a new "session" with the post-improvement state as the reference.
- After upgrading Next.js, React, or other foundational deps.
- Don't re-baseline mid-loop — you'll lose your ability to compare against the original.

### 2. `analyze.sh [iteration-name]` — extract findings

**What it does:**
- Runs `next experimental-analyze --output` (or reuses output if already present in `.next/`)
- Walks `build-manifest.json` to compute per-chunk sizes, per-route totals, cross-route usage counts
- Writes `iterations/{name}/findings.json` with: top_chunks, heaviest_routes, hints

**Reading the output:**
```
Top chunks (largest):
  234567 B  static/chunks/main-abc.js  (×8 routes)   ← shared & heavy
  123456 B  static/chunks/app/page-def.js (×1 route) ← route-specific & heavy

Heaviest routes:
  654321 B  app:/dashboard  (12 chunks)              ← deep-dive this one
```

A heavy chunk used by many routes is usually a barrel import, polyfill, or a shared util that's gotten bloated. A heavy chunk used by one route is usually a heavy client component, wrong-side import, or a candidate for `next/dynamic`.

### 3. `diagnose.sh [findings.json]` — map findings to recipes

**What it does:**
- Classifies each top offender by heuristics (shared/route-specific, polyfill-like, framework, threshold sizes)
- Emits a prioritized list pointing at recipes in `references/optimizations.md`

**Reading the output:**
```
1. [HIGH] 234 KB shared chunk used by 8 routes: static/chunks/main-abc.js
   Recipe:  references/optimizations.md#shared-heavy-dep
   Why:     A heavy dep imported across many routes multiplies the cost.

2. [MEDIUM] 312 KB route bundle: app:/dashboard
   Recipe:  references/optimizations.md#large-route-bundle
   Why:     Approaching the warning threshold; opportunistic optimization worthwhile.
```

**The discipline:** pick exactly ONE finding and apply its recipe. Resist the urge to fix two at once — if you do, you can't attribute the result.

### 4. Apply the recipe (manual / agent-assisted)

Open `references/optimizations.md`, find the section matching the recipe id, and apply the change. The agent should:

1. Read the recipe's "Signal", "Fix", "Expected impact", and "Verify step".
2. Locate the offending import / config in the codebase (`grep`, the analyzer treemap, or import chain trace).
3. Draft the minimal diff.
4. Confirm with the user before writing (per the project's CLAUDE.md write discipline).

### 5. `measure.sh [name]` — re-measure

**What it does:**
- `rm -rf .next` (cold by default; pass `--warm` to skip)
- Re-runs `$BUILD_COMMAND`
- Delegates to `analyze.sh` to capture new `bundle.json` and `findings.json`

**Failure modes:**
- Build fails → writes `timing.json` with `status: build_failed` and exits 1. The recipe broke the build. Revert and try another.

### 6. `compare.sh` — delta against baseline

**What it does:**
- Diffs `baselines/current/bundle.json` vs the latest iteration's `bundle.json`
- Prints overall delta + top 15 per-route changes
- Prints build-time delta
- Exit code: 0 if overall bytes decreased or stayed the same; 1 if overall grew

**Reading the output:**
```
Total: 1240.5 KB → 1098.3 KB  (-142.2 KB, -11.5%)

Top 15 route deltas:
  ↓ -78.4 KB    -23.1%   app:/dashboard
  ↓ -45.8 KB    -18.2%   app:/settings
  ↑ +2.1 KB     +0.8%    app:/login        ← acceptable noise
```

A small regression on a non-target route is normal — chunk hashes shift around as dependencies regroup. The exit code is based on overall, not per-route.

### 7. `verify.sh` — hard PASS/FAIL

**Runs in order:**
1. Build (skipped if a fresh `.next/` is present from `measure.sh`).
2. Type check (`$TYPECHECK_COMMAND`).
3. Tests (`$TEST_COMMAND`, skipped if no test files are found).
4. Bundle regression check (delegates to `compare.sh`).

**Exit 0 = safe to commit.** Exit 1 = revert. There is no in-between. The user-facing CLAUDE.md TDD discipline applies: you do not commit failures.

### 8. Commit OR revert

**On PASS:**
```bash
git add -A
git commit -m "optim(<recipe>): <route or chunk> -<delta>"
```

Example commit message: `optim(shared-heavy-dep): main-abc.js -78 KB (lodash → lodash-es subpath)`

**On FAIL:**
```bash
git reset --hard HEAD       # discard the experimental change
# Re-read diagnose.sh output and pick the next recipe.
```

If you want to investigate WHY the change failed before discarding, `git stash` instead — but commit-or-discard is the steady state. Half-applied optimizations rot.

## Rollback at any step

Every measurement script writes to `iterations/{name}/` or `baselines/{ts}/` — never back to the project. The Next.js project is only modified when you apply a recipe. So rollback is always:

```bash
git reset --hard HEAD       # last good state
rm -rf .next                # next build will be cold and clean
```

Skill state in `baselines/` and `iterations/` is fine to keep; it's historical data.

## When to stop optimizing

Stop when:
- `diagnose.sh` reports "No obvious offenders" twice in a row after iterations.
- The next ranked recipe targets a chunk under ~50KB. Returns diminish fast below that.
- Build-time has plateaued and bundle deltas are <1% per iteration.

Document where you stopped (`gotchas.md` or commit message) so the next session has a starting point.

## Troubleshooting

| Symptom | Likely cause | Action |
|---------|--------------|--------|
| `ERROR: working tree is dirty` | Uncommitted changes from previous iteration | `git stash` or `git commit` first |
| `experimental-analyze` writes no `.next/diagnostics/analyze` | Project on Next 15 / webpack mode | Skill falls back to manifest-only; consider installing `@next/bundle-analyzer` |
| `compare.sh` always shows huge deltas | Comparing cold vs warm builds | Both runs must match cache state; use `baseline.sh` (always cold) and `measure.sh` without `--warm` |
| `verify.sh` fails on tests that always pass locally | Build mutated something unexpectedly (env, snapshots) | Inspect `iterations/{name}/build.log`; revert and consider whether the recipe touches test infrastructure |
| Recipe is applied but bundle didn't change | The targeted import wasn't actually the bottleneck | Re-run `analyze.sh` from the post-change state; treemap rarely lies |
