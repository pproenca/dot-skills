---
name: complexity-optimizer
description: Analyze a software codebase for algorithmic complexity and performance hotspots, then propose or implement safe optimizations without breaking behavior. Use when the user asks to scan many files, find inefficient loops, nested iteration, repeated scans, costly rendering/recomputation, N+1 queries, avoidable O(n^2) or O(n) operations, or reduce complexity such as O(n^2) to O(n log n) / O(n), while preserving tests, APIs, outputs, and maintainability.
---

# Complexity Optimizer

Find algorithmic complexity hotspots in a codebase and produce a structured report. Optionally implement low-risk optimizations after explicit consent.

## When to Apply

Use this skill when the user asks to:
- Analyze, audit, scan, or review a codebase for performance hotspots or algorithmic complexity
- Find inefficient loops, nested iteration, N+1 queries, sort-in-loop, render-path recomputation
- Reduce complexity (e.g. O(n^2) → O(n log n) or O(n))
- "Give me a report" on a codebase's complexity profile

Do not use this skill for:
- Micro-optimizations on cold code paths
- Memory tuning (this skill targets time complexity, not allocation profiles)
- Code style refactoring unrelated to complexity

## Workflow Overview

```
Baseline → Rank → Prove behavior → Optimize (opt-in) → Verify
   ↓           ↓                       ↓
 scanner   prioritize hot          rollback if
 + manual  paths & large I/O       tests regress
```

| Step | Action | Tool | Risk |
|------|--------|------|------|
| 1 | Establish baseline: detect stack, test command, hot paths | `scripts/analyze_complexity.py` + manual inspection | read-only |
| 2 | Rank opportunities by impact, separating algorithmic wins from constant-factor cleanup | reasoning | read-only |
| 3 | Locate or add tests covering the function/component | Read + test framework | read-only |
| 4 | Apply optimization (ONLY when user explicitly requests) | Edit/Write | destructive |
| 5 | Run tests, lint, type-check, and a benchmark when warranted; report before/after complexity | Bash test commands | read-only |

## Core Rule

Optimize only when current behavior is understood and can be preserved. Prefer a small, proven improvement with tests over a broad rewrite with unclear correctness.

## Default Behavior

When the user asks to analyze, scan, audit, review, or "give me a report" for a codebase, produce the full complexity report automatically. Do not require the user to specify report fields.

Default report contents (see `references/report-template.md`):

- Scope analyzed and detected stack/test commands
- Top findings ranked by likely impact
- File and line for each finding
- Current pattern and why it may be costly
- Estimated current complexity
- Recommended change and estimated complexity after
- Risk level
- Tests, benchmarks, or manual checks needed
- Clear statement that **no files were modified**, unless the user explicitly requested implementation

Only edit files when the user uses an explicit edit verb: **implement, fix, optimize, apply, change, refactor**. If the request is analysis-only or a report-only request, do not modify files.

## Workflow Detail

### 1. Baseline

- Identify language, framework, test command, build command, and performance-sensitive paths.
- Inspect existing tests before touching code.
- Run `python3 scripts/analyze_complexity.py <repo>` for a first-pass hotspot list when scanning a repository.

### 2. Rank

- Prioritize hot paths, large-input paths, rendering loops, database/API loops, shared utilities.
- Separate algorithmic complexity from constant-factor cleanup.
- Treat scanner output as leads, not proof.
- For report-only requests, inspect enough surrounding code to estimate current and proposed complexity. Do not stop at raw scanner output.

### 3. Prove behavior

- Locate or add focused tests for the function/component being changed.
- Capture edge cases: empty input, duplicates, ordering stability, null/missing values, errors, permissions, pagination, time zones, mutation side effects.
- If tests are absent and behavior is ambiguous, make the smallest possible refactor or ask for expected behavior before changing semantics.

### 4. Optimize (only on explicit request)

- Replace repeated linear lookup with maps/sets when key equality is stable.
- Replace nested scans with indexing, grouping, two-pointer scans, sweep-line logic, binary search, memoization, batching, or precomputation — only when the data shape supports it.
- In UI code, reduce unnecessary renders with stable props, memoized derived data, virtualization, debounced work, and moving expensive work out of render paths.
- In data access code, remove N+1 with bulk fetches, joins, preloading, caching, or batching while preserving authorization and filtering.

### 5. Verify

- Run relevant tests and type/lint/build commands.
- Add a micro-benchmark or measurement when the complexity improvement is non-obvious or performance-critical.
- Report original complexity, new complexity, files changed, tests run, and any residual risk.

## First-Pass Scanner

```bash
python3 scripts/analyze_complexity.py /path/to/repo --format markdown
python3 scripts/analyze_complexity.py /path/to/repo --format json
```

**Language depth:**

- **Python** (`.py`) — AST-based analysis. High precision: nested loops, sort/membership in loops, query/I/O in loops, all tracked per-function via the Python `ast` module.
- **All other supported languages** (`.js`, `.ts`, `.jsx`, `.tsx`, `.java`, `.go`, `.rb`, `.php`, `.cs`, `.c`, `.cpp`, `.swift`, `.vue`, `.svelte`, `.kt`, `.rs`, `.dart`, `.scala`) — regex-based pattern matching with indent + function-boundary heuristics. Treat findings as leads; verify by reading the surrounding code before recommending fixes.

If the scanner reports nothing, still inspect known hot paths manually. Rendering churn, database query patterns, and framework lifecycle issues often need repository-specific context the scanner cannot see.

**Exit codes:** `0` = scanned successfully, `2` = bad input (non-existent path / file instead of directory), `3` = zero files matched, `130` = interrupted.

## Optimization Safety Checklist

Before editing:

- Confirm the data sizes are large enough for complexity to matter.
- Confirm the optimization preserves output ordering where callers may rely on it.
- Confirm object identity, mutability, and reference sharing are not part of public behavior.
- Confirm caches have a valid invalidation strategy.
- Confirm deduplication does not collapse distinct records that share a display label.
- Confirm database batching preserves tenant, permission, soft-delete, pagination, and sorting constraints.

After editing:

- Run the narrowest relevant test first, then the broader build/lint/typecheck.
- Compare before/after benchmark numbers when a benchmark exists or was added.
- Keep the patch localized — avoid formatting churn in unrelated files.

## Rollback

If the optimization breaks a test or changes observable behavior:

1. **Revert the changed file(s) immediately:**
   ```bash
   git restore <file>           # restore a single file
   git restore -SW <file>       # restore both index and working tree
   ```
   If multiple files were modified: `git restore -SW .` (only within the affected directory).

2. **Re-run the failing test** to confirm restoration.

3. **Report the failure to the user** with:
   - The exact test/assertion that failed
   - The semantics that diverged (ordering, mutation, key equality, etc.)
   - Whether to retry with a different transformation, or stay with the original code

4. **Do not** re-attempt the same optimization with a small tweak. If a transformation breaks behavior, either the data shape doesn't support it, or there's an unstated invariant — re-read the code before trying again.

## References

- `references/optimization-playbook.md` — common O(n^2) → O(n log n) / O(n) transformations, framework-specific patterns, and "What Not To Do".
- `references/report-template.md` — structure for the final analysis or audit output.
- `scripts/_sections.md` — scanner invocation, exit codes, and limitations.
