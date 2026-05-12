# Gotchas

Specific failure points encountered while running this skill. Append-only with dates.

## Seeded gotchas (Next.js 16)

### `next build` no longer prints First Load JS per route
**Why it matters:** Older scripts that grep build output for "First Load JS" or "Size" will silently find nothing.
**Fix:** Use `next experimental-analyze --output` + the `build-manifest.json` sums computed by `scripts/baseline.sh`. Do not regress to grepping stdout.
Added: 2026-05-12 (initial seed — Next.js 16 release note)

### `experimental.optimizePackageImports` is a no-op under Turbopack
**Why it matters:** Turbopack (default in Next 16) auto-optimizes barrel imports. Adding packages to `optimizePackageImports` does nothing under Turbopack — yet the same change applied to a webpack-mode project would help.
**Fix:** `scripts/_common.sh` detects the bundler. The diagnose step only suggests `optimizePackageImports` when bundler is `webpack`. If you find yourself reaching for this option under Turbopack, the issue is somewhere else.
Added: 2026-05-12 (initial seed)

### Comparing cold vs warm builds invalidates timing deltas
**Why it matters:** `experimental.turbopackFileSystemCacheForBuild` (Next 16 opt-in) makes second builds dramatically faster. If the baseline was cold and the measurement is warm (or vice versa), the time delta is mostly cache, not your optimization.
**Fix:** `baseline.sh` always runs cold (`rm -rf .next`). `measure.sh` defaults to cold; use `--warm` deliberately if you want to measure warm-build savings specifically.
Added: 2026-05-12 (initial seed)

### Dirty working tree pollutes measurements
**Why it matters:** Each iteration must isolate the impact of ONE change. Uncommitted changes from previous iterations or unrelated work attribute results to the wrong cause.
**Fix:** `_common.sh::ensure_clean_git` aborts before any measurement run if `git status --porcelain` is non-empty. Commit or stash first.
Added: 2026-05-12 (initial seed)

### `experimental-analyze` may fail in restrictive CI environments
**Why it matters:** The analyzer writes to `.next/diagnostics/analyze/`. Some sandboxes restrict writing outside the cwd or have permission quirks.
**Fix:** `baseline.sh` and `analyze.sh` treat analyzer failure as a warning (not fatal) and fall back to manifest-only snapshots. You lose the treemap but retain per-route byte totals — enough for compare.sh to function.
Added: 2026-05-12 (initial seed)

---

## How to add a gotcha

When something surprises you during a run, append a new entry below:

```markdown
### One-line title
**Why it matters:** 1-2 sentences on the symptom and what it cost you.
**Fix:** Concrete steps or pointer to the script that handles it.
Added: YYYY-MM-DD
```
