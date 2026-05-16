---
name: computer-science-algorithms
description: Use this skill whenever choosing or implementing an algorithm or data structure — covers asymptotic complexity, data-structure selection, sorting & searching, dynamic programming, graph algorithms, divide & conquer, greedy algorithms, and string/sequence algorithms. Trigger on tasks involving "what's the right algorithm for…", performance-critical code, code with nested loops over the same input, recursive solutions, shortest-path / scheduling / matching / DP problems, and code review for accidental O(n²) blowup — even if the user doesn't explicitly mention "algorithm" or "complexity."
---

# Community Classical Computer Science Algorithms Best Practices

A practitioner-oriented reference for choosing and implementing classical algorithms and data structures correctly. Organized by execution-lifecycle impact: the earliest decisions (asymptotic class, data-structure choice) cascade through everything else, so the rules near the top of the table matter most.

**Scope:** the patterns that show up in everyday production code review and reasonable interview / contest problems — not an exhaustive cover of CLRS. Topics intentionally outside v0.1.0: network flow, modular arithmetic, Bellman-Ford and Floyd-Warshall as standalone rules, SCC (Tarjan/Kosaraju), computational geometry, FFT, Manacher / Z-function as standalone rules. They're flagged inline in the relevant rules.

Distilled from CLRS (*Introduction to Algorithms*, 4th ed.), Sedgewick & Wayne (*Algorithms*, 4th ed., Princeton), Skiena's *Algorithm Design Manual*, Laaksonen's *Competitive Programmer's Handbook*, [cp-algorithms.com](https://cp-algorithms.com/), and the [USACO Guide](https://usaco.guide).

## When to Apply

Use these rules when:

- Choosing an algorithm or data structure for a new problem ("what's the right way to do X?")
- Reviewing code for hidden O(n²) blowup — repeated `in`-checks on lists, `pop(0)` on lists, string concatenation in loops, naive substring search
- Picking a DP state or recurrence, before writing the memoization
- Modeling a problem as a graph (BFS vs Dijkstra vs topological sort)
- Refactoring brute force / naive solutions that work on toy inputs but time out at scale
- Deciding whether greedy applies, or whether DP / branch-and-bound is required

## Rule Categories By Priority

| # | Category | Prefix | Impact | Why it cascades |
|---|----------|--------|--------|-----------------|
| 1 | Asymptotic Complexity & Algorithm Selection | `comp-` | CRITICAL | Wrong O() class makes every other optimization irrelevant |
| 2 | Data Structure Selection | `ds-` | CRITICAL | The container determines which operations are cheap |
| 3 | Sorting & Searching | `srch-` | HIGH | Foundation for greedy, two-pointer, sweep-line, binary-search-on-the-answer |
| 4 | Dynamic Programming | `dp-` | HIGH | Exponential → polynomial transformations |
| 5 | Graph Algorithms | `graph-` | HIGH | Networks, dependencies, routing, scheduling all reduce to graphs |
| 6 | Divide & Conquer / Recursion | `divide-` | MEDIUM-HIGH | Logarithmic-factor speedups; stack-depth and recurrence traps |
| 7 | Greedy Algorithms | `greedy-` | MEDIUM | Fast when correct, silently wrong when not |
| 8 | String & Sequence Algorithms | `str-` | MEDIUM | Pattern matching, parsing, substring queries |

## Quick Reference

### 1. Asymptotic Complexity & Algorithm Selection (CRITICAL)

- [`comp-pick-algorithm-class-from-input-bound`](references/comp-pick-algorithm-class-from-input-bound.md) — Match O() to n before writing code
- [`comp-amortize-instead-of-worst-casing`](references/comp-amortize-instead-of-worst-casing.md) — Total cost, not per-op worst case
- [`comp-watch-for-quadratic-blowup-from-membership-in-list`](references/comp-watch-for-quadratic-blowup-from-membership-in-list.md) — Linear `in` checks in loops are O(n²)
- [`comp-prefer-iterative-builders-over-string-concatenation`](references/comp-prefer-iterative-builders-over-string-concatenation.md) — Join / buffers, not `+=`
- [`comp-derive-recurrences-via-master-theorem`](references/comp-derive-recurrences-via-master-theorem.md) — Write the recurrence before coding recursion
- [`comp-treat-space-complexity-as-first-class`](references/comp-treat-space-complexity-as-first-class.md) — Memory kills services before time does

### 2. Data Structure Selection (CRITICAL)

- [`ds-hash-map-for-keyed-lookup`](references/ds-hash-map-for-keyed-lookup.md) — Build the index once, then O(1) lookups
- [`ds-set-for-uniqueness-and-membership`](references/ds-set-for-uniqueness-and-membership.md) — Dedup and "have I seen this?" in O(1)
- [`ds-heap-for-top-k-and-priority-queues`](references/ds-heap-for-top-k-and-priority-queues.md) — O(n log k), priority-queue idioms
- [`ds-deque-for-both-end-operations`](references/ds-deque-for-both-end-operations.md) — O(1) pop-front for BFS queues and sliding windows
- [`ds-balanced-bst-or-sorted-container-for-range-queries`](references/ds-balanced-bst-or-sorted-container-for-range-queries.md) — Predecessor / successor / range scan
- [`ds-union-find-for-dynamic-connectivity`](references/ds-union-find-for-dynamic-connectivity.md) — Near-O(1) grouping and merging
- [`ds-prefix-sums-for-repeated-range-sums`](references/ds-prefix-sums-for-repeated-range-sums.md) — O(1) range sum after O(n) preprocessing
- [`ds-fenwick-or-segment-tree-for-mutable-range-queries`](references/ds-fenwick-or-segment-tree-for-mutable-range-queries.md) — O(log n) updates + queries

### 3. Sorting & Searching (HIGH)

- [`srch-use-builtin-sort-not-hand-rolled`](references/srch-use-builtin-sort-not-hand-rolled.md) — Timsort / introsort beat any hand-roll
- [`srch-binary-search-on-sorted-data`](references/srch-binary-search-on-sorted-data.md) — `bisect`, plus binary search on the answer
- [`srch-quickselect-for-k-th-element`](references/srch-quickselect-for-k-th-element.md) — O(n) average for k-th / median
- [`srch-counting-and-radix-sort-for-bounded-integer-keys`](references/srch-counting-and-radix-sort-for-bounded-integer-keys.md) — Beat O(n log n) for integer keys
- [`srch-two-pointers-on-sorted-data`](references/srch-two-pointers-on-sorted-data.md) — O(n) on sorted arrays, sliding window

### 4. Dynamic Programming (HIGH)

- [`dp-memoize-overlapping-subproblems`](references/dp-memoize-overlapping-subproblems.md) — `@cache` collapses exponentials
- [`dp-tabulate-when-recursion-depth-or-order-matters`](references/dp-tabulate-when-recursion-depth-or-order-matters.md) — Bottom-up + rolling arrays
- [`dp-define-state-precisely`](references/dp-define-state-precisely.md) — Underspecified state = silent wrong answers
- [`dp-knapsack-pattern`](references/dp-knapsack-pattern.md) — 0/1 vs unbounded; loop direction is correctness
- [`dp-bitmask-for-small-set-states`](references/dp-bitmask-for-small-set-states.md) — n! → 2ⁿ · poly for n ≤ ~20
- [`dp-prove-optimal-substructure-before-coding`](references/dp-prove-optimal-substructure-before-coding.md) — DP requires substructure; verify before coding

### 5. Graph Algorithms (HIGH)

- [`graph-bfs-for-unweighted-shortest-path`](references/graph-bfs-for-unweighted-shortest-path.md) — O(V+E), no heap needed
- [`graph-dijkstra-for-non-negative-weights`](references/graph-dijkstra-for-non-negative-weights.md) — Lazy-deletion heap variant
- [`graph-topological-sort-for-dependency-order`](references/graph-topological-sort-for-dependency-order.md) — Kahn's algorithm + DAG DP
- [`graph-represent-as-adjacency-list-not-matrix`](references/graph-represent-as-adjacency-list-not-matrix.md) — Sparse graphs need lists
- [`graph-detect-cycles-during-dfs`](references/graph-detect-cycles-during-dfs.md) — Three-colour scheme for directed graphs
- [`graph-kruskal-or-prim-for-mst`](references/graph-kruskal-or-prim-for-mst.md) — MST with Union-Find or heap

### 6. Divide & Conquer / Recursion (MEDIUM-HIGH)

- [`divide-merge-sort-pattern-for-counting-inversions`](references/divide-merge-sort-pattern-for-counting-inversions.md) — Piggy-back counting onto the merge step
- [`divide-watch-recursion-depth-and-stack`](references/divide-watch-recursion-depth-and-stack.md) — Iterate, or raise the stack
- [`divide-meet-in-the-middle-for-subset-problems`](references/divide-meet-in-the-middle-for-subset-problems.md) — 2ⁿ → 2^(n/2)
- [`divide-quickselect-vs-quicksort-partitioning`](references/divide-quickselect-vs-quicksort-partitioning.md) — Random pivots; 3-way Dutch flag

### 7. Greedy Algorithms (MEDIUM)

- [`greedy-prove-exchange-argument-before-using`](references/greedy-prove-exchange-argument-before-using.md) — Greedy needs a correctness proof
- [`greedy-sort-by-the-right-key-for-scheduling`](references/greedy-sort-by-the-right-key-for-scheduling.md) — Finish time, deadline, value/weight
- [`greedy-interval-merge-and-sweep-line`](references/greedy-interval-merge-and-sweep-line.md) — Events + sort + linear sweep
- [`greedy-huffman-and-priority-queue-greedies`](references/greedy-huffman-and-priority-queue-greedies.md) — Heap-based "pick smallest repeatedly"

### 8. String & Sequence Algorithms (MEDIUM)

- [`str-kmp-or-builtin-find-not-naive-search`](references/str-kmp-or-builtin-find-not-naive-search.md) — Linear worst-case substring search
- [`str-trie-for-prefix-queries`](references/str-trie-for-prefix-queries.md) — Autocomplete in O(|query|)
- [`str-rolling-hash-for-multiple-substring-comparisons`](references/str-rolling-hash-for-multiple-substring-comparisons.md) — Two independent hashes, please
- [`str-suffix-array-or-automaton-for-substring-queries`](references/str-suffix-array-or-automaton-for-substring-queries.md) — Heavy-duty substring tooling

## How to Use

Start with the category that matches the question:

- **"What's the right algorithm for n = 10⁶?"** → `comp-` (input-bound)
- **"I'm looking things up in a list inside a loop"** → `ds-hash-map-for-keyed-lookup` or `comp-watch-for-quadratic-blowup-from-membership-in-list`
- **"My recursion is slow"** → `dp-memoize-overlapping-subproblems` and `comp-derive-recurrences-via-master-theorem`
- **"Shortest path / connectivity / ordering tasks"** → `graph-`
- **"Choose items to maximize value"** → start with `greedy-prove-exchange-argument-before-using`; fall back to `dp-knapsack-pattern`
- **"Find / match strings"** → `str-`

Code examples are in Python (most readable across audiences). The reasoning generalizes to any language — equivalent stdlib primitives are listed where they differ.

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
| [AGENTS.md](AGENTS.md) | Auto-built TOC navigation |

## Related Skills

- `complexity-optimizer` — Static analysis that finds the patterns these rules diagnose
