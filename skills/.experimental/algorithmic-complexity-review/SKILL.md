---
name: algorithmic-complexity-review
description: Use this skill whenever writing, reviewing, or refactoring code where algorithmic complexity (Big-O) matters — finding nested loops, N+1 queries, exponential recursion, quadratic string builds, and other accidental complexity blowups. Covers Python, JavaScript/TypeScript, Java, Go, and similar languages. Trigger even when the user doesn't mention "Big-O" explicitly — if they're reviewing code for performance, refactoring a hot path, asking "why is this slow," or working with data that scales (loops, recursions, collections, ORM access), apply this skill to classify the time/space complexity and suggest the fix. Especially trigger on tasks like "review for performance," "find slow code," "make this faster," "this code is O(n²)," or when reading code that processes collections.
---

# dot-skills Algorithmic Complexity (Big-O) Best Practices

Find, classify, and fix algorithmic complexity (Big-O) problems in code — language-agnostic. The 39 rules across 8 categories cover the patterns responsible for the vast majority of accidental quadratic, exponential, and N+1 blowups in production code: nested iteration, loop-invariant I/O, data-structure mismatch, recursion explosions, redundant computation, collection-building anti-patterns, search/sort selection, and space traps.

## When to Apply

Use this skill when:

- Reviewing a pull request or function for performance regressions
- Asked "why is this slow?" or "can we make this faster?"
- Refactoring a hot path or a function that handles user-scaled input
- Reading code that contains: nested loops, `.includes`/`.find`/`x in list` inside iteration, ORM access in a loop, recursion without memoization, string/array building via `+=` or spread, file/database I/O inside iteration
- Reviewing code that processes lists, trees, or streams whose size will grow

## Workflow: Find, Classify, Fix

The skill is structured for a three-step workflow on any code under review:

### 1. Find — Scan for the Suspicion Patterns

Look for these structural signals first (highest hit rate):

| Signal | Likely Category | First Rule to Check |
|--------|-----------------|---------------------|
| Two nested `for` loops | `nested-` | [nested-explicit-quadratic-loops](references/nested-explicit-quadratic-loops.md) |
| `.includes` / `.find` / `x in list` inside a loop | `nested-` | [nested-includes-in-loop](references/nested-includes-in-loop.md) |
| ORM access inside a loop (`for o in orders: o.customer.x`) | `io-` | [io-n-plus-one-query](references/io-n-plus-one-query.md) |
| `await fetch` in `for-of` | `io-` | [io-sequential-await-in-loop](references/io-sequential-await-in-loop.md) |
| `array.find` to "join" two arrays | `ds-` | [ds-hashmap-for-keyed-access](references/ds-hashmap-for-keyed-access.md) |
| Recursive function with overlapping arguments | `rec-` | [rec-memoize-overlapping-subproblems](references/rec-memoize-overlapping-subproblems.md) |
| `s = s + part` or `[...acc, x]` in a loop | `build-` | [build-avoid-quadratic-string-concat](references/build-avoid-quadratic-string-concat.md), [build-avoid-spread-in-reducer](references/build-avoid-spread-in-reducer.md) |
| `sorted(...)` called inside a loop | `search-` | [search-sort-once-outside-loop](references/search-sort-once-outside-loop.md) |
| `readlines()` / loading whole files | `space-` | [space-stream-dont-load](references/space-stream-dont-load.md) |

### 2. Classify — Derive the Big-O

Compute complexity from the code structure:

| Structure | Complexity |
|-----------|------------|
| Single loop over n items, O(1) body | O(n) |
| Two nested loops over n / m items | O(n*m) |
| Loop calling an O(n) operation (`.includes`, `.find`, `x in list`) | O(n*m), often misread as O(n) |
| Recursive `f(n) = f(n-1) + f(n-2)` without memoization | O(2ⁿ) |
| Recursive `f(n) = 2*f(n/2) + O(n)` | O(n log n) |
| Recursive `f(n) = 2*f(n/2) + O(1)` | O(n) (full tree traversal) |
| Recursive `f(n) = f(n/2) + O(1)` | O(log n) |
| `s = s + part` in a loop | O(n²) (string immutability) |
| `[...acc, x]` in a reduce | O(n²) (copy-on-spread) |
| Query/RPC inside loop over n items | O(n) round trips |

When in doubt, ask: **"As input doubles, does runtime roughly double (linear), quadruple (quadratic), or do something worse (exponential)?"** That's the practical complexity class.

### 3. Fix — Apply the Pattern From the Matching Rule

Each reference file in `references/` is a `{category}-{slug}.md` containing:
- WHY the pattern matters (the cascade effect)
- An **Incorrect** code example with the cost annotated
- A **Correct** example with the minimal diff
- When NOT to apply the fix (the rule has exceptions)

The minimal diff philosophy is intentional: the goal is for the agent to see exactly how few lines need to change to flip the complexity class.

## Rule Categories by Priority

| # | Category | Prefix | Impact | Rules |
|---|----------|--------|--------|-------|
| 1 | Nested Iteration Patterns | `nested-` | CRITICAL | 6 |
| 2 | Loop-Invariant I/O and N+1 | `io-` | CRITICAL | 5 |
| 3 | Data Structure Mismatch | `ds-` | HIGH | 6 |
| 4 | Recursion Complexity | `rec-` | HIGH | 5 |
| 5 | Redundant Computation | `compute-` | MEDIUM-HIGH | 5 |
| 6 | Collection Building | `build-` | MEDIUM | 4 |
| 7 | Search & Sort Selection | `search-` | MEDIUM | 4 |
| 8 | Space Complexity Traps | `space-` | LOW-MEDIUM | 4 |

See [`references/_sections.md`](references/_sections.md) for the full ordering rationale.

## Quick Reference

### 1. Nested Iteration Patterns (CRITICAL)

- [`nested-explicit-quadratic-loops`](references/nested-explicit-quadratic-loops.md) — Replace pairwise loops with hash-based single passes
- [`nested-includes-in-loop`](references/nested-includes-in-loop.md) — Avoid `.includes()` / `.indexOf()` inside a loop
- [`nested-find-in-loop`](references/nested-find-in-loop.md) — Pre-index lookups instead of `.find()` per iteration
- [`nested-cartesian-comparison`](references/nested-cartesian-comparison.md) — Group by key instead of cartesian comparison
- [`nested-set-operations-on-arrays`](references/nested-set-operations-on-arrays.md) — Use sets for intersection, union, difference
- [`nested-substring-search-in-loop`](references/nested-substring-search-in-loop.md) — Tokenize once instead of re-scanning per pattern

### 2. Loop-Invariant I/O and N+1 Queries (CRITICAL)

- [`io-n-plus-one-query`](references/io-n-plus-one-query.md) — Eliminate N+1 queries by fetching related data in one round trip
- [`io-sequential-await-in-loop`](references/io-sequential-await-in-loop.md) — Run independent async operations in parallel
- [`io-batch-instead-of-per-item`](references/io-batch-instead-of-per-item.md) — Use batch endpoints instead of per-item calls
- [`io-file-read-in-loop`](references/io-file-read-in-loop.md) — Read or stat files outside tight loops
- [`io-missing-eager-load`](references/io-missing-eager-load.md) — Eager-load ORM relations you will access

### 3. Data Structure Mismatch (HIGH)

- [`ds-hashmap-for-keyed-access`](references/ds-hashmap-for-keyed-access.md) — Store records keyed in a hashmap, not as parallel arrays
- [`ds-heap-for-top-k`](references/ds-heap-for-top-k.md) — Use a heap for top-k, not full sort + slice
- [`ds-deque-for-front-operations`](references/ds-deque-for-front-operations.md) — Use a deque for front insertions and removals
- [`ds-counter-for-histograms`](references/ds-counter-for-histograms.md) — Use Counter / multiset for frequency counting
- [`ds-sorted-structure-for-range-queries`](references/ds-sorted-structure-for-range-queries.md) — Use a sorted structure for range queries
- [`ds-trie-for-prefix-search`](references/ds-trie-for-prefix-search.md) — Use a trie for prefix search

### 4. Recursion Complexity (HIGH)

- [`rec-memoize-overlapping-subproblems`](references/rec-memoize-overlapping-subproblems.md) — Memoize recursion with overlapping subproblems
- [`rec-tabulate-bottom-up`](references/rec-tabulate-bottom-up.md) — Tabulate bottom-up to eliminate recursion overhead
- [`rec-iterative-for-deep-recursion`](references/rec-iterative-for-deep-recursion.md) — Use an explicit stack instead of deep recursion
- [`rec-prune-with-bounds`](references/rec-prune-with-bounds.md) — Prune recursive search with bounds and constraints
- [`rec-share-memo-across-top-level-calls`](references/rec-share-memo-across-top-level-calls.md) — Share memoization across top-level calls

### 5. Redundant Computation (MEDIUM-HIGH)

- [`compute-hoist-loop-invariants`](references/compute-hoist-loop-invariants.md) — Hoist loop-invariant computation outside the loop
- [`compute-precompile-regex`](references/compute-precompile-regex.md) — Pre-compile regex patterns
- [`compute-cache-expensive-pure-results`](references/compute-cache-expensive-pure-results.md) — Cache expensive pure-function results
- [`compute-cache-property-lookup`](references/compute-cache-property-lookup.md) — Cache repeated property lookups in hot loops
- [`compute-defer-or-short-circuit`](references/compute-defer-or-short-circuit.md) — Defer or short-circuit work you might not need

### 6. Collection Building (MEDIUM)

- [`build-avoid-quadratic-string-concat`](references/build-avoid-quadratic-string-concat.md) — Build strings with joins or builders, not repeated concatenation
- [`build-avoid-spread-in-reducer`](references/build-avoid-spread-in-reducer.md) — Push to a mutable accumulator instead of spreading
- [`build-avoid-immutable-object-spread`](references/build-avoid-immutable-object-spread.md) — Use a plain object build phase, then freeze
- [`build-presize-when-length-known`](references/build-presize-when-length-known.md) — Pre-size collections when the length is known

### 7. Search & Sort Selection (MEDIUM)

- [`search-binary-search-on-sorted`](references/search-binary-search-on-sorted.md) — Use binary search on sorted data
- [`search-sort-once-outside-loop`](references/search-sort-once-outside-loop.md) — Sort once outside the loop, not on every iteration
- [`search-quickselect-not-full-sort`](references/search-quickselect-not-full-sort.md) — Use quickselect for the k-th element, not full sort
- [`search-build-index-once-amortize`](references/search-build-index-once-amortize.md) — Build the index once when queries dominate

### 8. Space Complexity Traps (LOW-MEDIUM)

- [`space-stream-dont-load`](references/space-stream-dont-load.md) — Stream large inputs instead of loading them whole
- [`space-generators-over-intermediate-lists`](references/space-generators-over-intermediate-lists.md) — Pipe through generators instead of materializing intermediate lists
- [`space-shallow-not-deep-copy`](references/space-shallow-not-deep-copy.md) — Use shallow copies (or no copy) instead of deep clones
- [`space-release-retained-references`](references/space-release-retained-references.md) — Release references that prevent garbage collection

## How to Use

1. Start with the **Find** signal table above to locate the most likely pattern.
2. Open the matching reference file for the WHY and the minimal-diff fix.
3. If you're classifying complexity from scratch, use the **Classify** table to derive Big-O from code structure.
4. When proposing a fix, quote the rule by file path so reviewers can verify the reasoning.
5. See [`references/_sections.md`](references/_sections.md) for category ordering rationale, and [`assets/templates/_template.md`](assets/templates/_template.md) when adding new rules.

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions, impact levels, and ordering rationale |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for adding new rules |
| [metadata.json](metadata.json) | Discipline, type, and source references |

## Related Skills

- `bug-review` — Multi-pass PR bug review (this skill is a focused complement for performance issues specifically)
- A language-specific best-practices skill (React, Python, Go) — covers idioms beyond Big-O; pair with this skill for performance-critical reviews
