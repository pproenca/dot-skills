# classical computer science algorithms

**Version 0.1.0**  
Community  
May 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

A practitioner-oriented reference of classical algorithms and data structures organized by execution-lifecycle impact. 43 rules across 8 categories — asymptotic complexity, data-structure selection, sorting & searching, dynamic programming, graph algorithms, divide & conquer, greedy algorithms, and string/sequence algorithms — each with incorrect/correct code examples, the cascade rationale, and pointers to canonical sources (CLRS, Sedgewick & Wayne, Skiena, cp-algorithms.com, USACO Guide). Designed for AI agents to consult when choosing or reviewing algorithmic code.

---

## Table of Contents

1. [Asymptotic Complexity & Algorithm Selection](references/_sections.md#1-asymptotic-complexity-&-algorithm-selection) — **CRITICAL**
   - 1.1 [Avoid Linear `in` Checks Inside Loops](references/comp-watch-for-quadratic-blowup-from-membership-in-list.md) — CRITICAL (O(n²) to O(n) — common 100-1000x speedup)
   - 1.2 [Build Strings With Join Or Buffers, Not Repeated Concatenation](references/comp-prefer-iterative-builders-over-string-concatenation.md) — CRITICAL (O(n²) to O(n) when concatenating in a loop)
   - 1.3 [Derive Recurrences With The Master Theorem Before Coding Recursion](references/comp-derive-recurrences-via-master-theorem.md) — CRITICAL (prevents shipping accidentally-exponential recursive algorithms)
   - 1.4 [Pick Algorithm Class From The Input Bound, Not From Familiarity](references/comp-pick-algorithm-class-from-input-bound.md) — CRITICAL (O(n²) → O(n log n) or better — orders of magnitude on n ≥ 10⁴)
   - 1.5 [Reason About Amortized Cost, Not Just Worst-Case Per Operation](references/comp-amortize-instead-of-worst-casing.md) — CRITICAL (prevents discarding O(1) amortized structures (dynamic arrays, hash tables) for false O(n) fears)
   - 1.6 [Treat Space Complexity As First-Class, Not An Afterthought](references/comp-treat-space-complexity-as-first-class.md) — HIGH (prevents OOM kills at production scale even when time complexity is fine)
2. [Data Structure Selection](references/_sections.md#2-data-structure-selection) — **CRITICAL**
   - 2.1 [Use A Balanced BST Or Sorted Container For Order-Sensitive Queries](references/ds-balanced-bst-or-sorted-container-for-range-queries.md) — HIGH (O(n) per range query to O(log n) — required when both order and lookup matter)
   - 2.2 [Use A Deque For Both-End Operations, Not List Pop-From-Front](references/ds-deque-for-both-end-operations.md) — HIGH (O(n) per pop-front to O(1) — 100-1000x on queue-heavy workloads)
   - 2.3 [Use A Fenwick Or Segment Tree For Mutable Range Queries](references/ds-fenwick-or-segment-tree-for-mutable-range-queries.md) — MEDIUM-HIGH (O(n) per update OR query to O(log n) for both)
   - 2.4 [Use A Hash Map For Keyed Lookup, Not Repeated Linear Scans](references/ds-hash-map-for-keyed-lookup.md) — CRITICAL (O(n) per lookup to O(1) average — typically 100-10000x at scale)
   - 2.5 [Use A Heap For Top-K And Priority Queues, Not Sort-Then-Slice](references/ds-heap-for-top-k-and-priority-queues.md) — HIGH (O(n log n) to O(n log k) — huge when k << n)
   - 2.6 [Use A Set For Uniqueness And Membership, Not A List](references/ds-set-for-uniqueness-and-membership.md) — CRITICAL (O(n) per membership check to O(1) — dedup goes from O(n²) to O(n))
   - 2.7 [Use Prefix Sums For Repeated Range Sums](references/ds-prefix-sums-for-repeated-range-sums.md) — HIGH (O(n) per range sum to O(1) after O(n) preprocessing)
   - 2.8 [Use Union-Find For Dynamic Connectivity And Grouping](references/ds-union-find-for-dynamic-connectivity.md) — HIGH (O(n) per query to nearly O(1) amortized (inverse-Ackermann))
3. [Sorting & Searching](references/_sections.md#3-sorting-&-searching) — **HIGH**
   - 3.1 [Binary Search Sorted Data Instead Of Linear Scan](references/srch-binary-search-on-sorted-data.md) — HIGH (O(n) per query to O(log n) — 1000x at n = 10⁶)
   - 3.2 [Use Counting Or Radix Sort For Bounded Integer Keys](references/srch-counting-and-radix-sort-for-bounded-integer-keys.md) — MEDIUM (O(n log n) to O(n + k) — 5-10x at large n with small key range)
   - 3.3 [Use Quickselect (Or `nth_element`) For The K-th Element](references/srch-quickselect-for-k-th-element.md) — MEDIUM-HIGH (O(n log n) sort to O(n) average — 20x at n = 10⁶)
   - 3.4 [Use The Standard-Library Sort, Not A Hand-Rolled One](references/srch-use-builtin-sort-not-hand-rolled.md) — HIGH (prevents O(n²) bugs and ~3-10x slower implementations)
   - 3.5 [Use Two Pointers On Sorted Data To Replace Nested Loops](references/srch-two-pointers-on-sorted-data.md) — MEDIUM-HIGH (O(n²) to O(n log n) including sort, or O(n) if already sorted)
4. [Dynamic Programming](references/_sections.md#4-dynamic-programming) — **HIGH**
   - 4.1 [Define DP State Precisely Before Writing The Recurrence](references/dp-define-state-precisely.md) — HIGH (prevents whole classes of "almost-right" DP bugs and over-large state spaces)
   - 4.2 [Memoize Recursions With Overlapping Subproblems](references/dp-memoize-overlapping-subproblems.md) — HIGH (O(2ⁿ) to O(n) or O(n²) — turns exponential into polynomial)
   - 4.3 [Prove Optimal Substructure Before Writing The DP](references/dp-prove-optimal-substructure-before-coding.md) — MEDIUM-HIGH (prevents shipping DPs that produce subtly wrong answers)
   - 4.4 [Recognize The Knapsack Pattern For Subset-Sum Decisions](references/dp-knapsack-pattern.md) — MEDIUM-HIGH (exponential subset search to pseudo-polynomial O(n·W))
   - 4.5 [Tabulate Bottom-Up When Recursion Depth Or Eviction Order Matters](references/dp-tabulate-when-recursion-depth-or-order-matters.md) — HIGH (prevents stack overflow on deep DPs; enables O(1) space via rolling arrays)
   - 4.6 [Use Bitmask DP When The State Includes A Small Subset](references/dp-bitmask-for-small-set-states.md) — MEDIUM (factorial (n!) to O(2ⁿ·n) — practical up to n ≈ 20)
5. [Graph Algorithms](references/_sections.md#5-graph-algorithms) — **HIGH**
   - 5.1 [Detect Cycles With DFS Colours, Not "Visited" Alone](references/graph-detect-cycles-during-dfs.md) — MEDIUM-HIGH (prevents wrong cycle answers and infinite recursion bugs)
   - 5.2 [Represent Sparse Graphs As Adjacency Lists, Not Matrices](references/graph-represent-as-adjacency-list-not-matrix.md) — MEDIUM-HIGH (O(V²) memory and per-iteration cost to O(V+E))
   - 5.3 [Use BFS For Unweighted Shortest Paths, Not Dijkstra](references/graph-bfs-for-unweighted-shortest-path.md) — HIGH (O((V+E) log V) Dijkstra to O(V+E) BFS — 5-50x faster)
   - 5.4 [Use Dijkstra With A Heap For Non-Negative Weighted Shortest Paths](references/graph-dijkstra-for-non-negative-weights.md) — HIGH (O(V·E) Bellman-Ford to O((V+E) log V) — orders of magnitude on dense graphs)
   - 5.5 [Use Kruskal Or Prim For Minimum Spanning Trees](references/graph-kruskal-or-prim-for-mst.md) — MEDIUM (O(E log E) — the only practical algorithms for MST on real graphs)
   - 5.6 [Use Topological Sort For Dependency Ordering And DAG DP](references/graph-topological-sort-for-dependency-order.md) — HIGH (O(V+E) — enables linear-time DP on DAGs and reliable cycle detection)
6. [Divide & Conquer and Recursion](references/_sections.md#6-divide-&-conquer-and-recursion) — **MEDIUM-HIGH**
   - 6.1 [Partition Carefully — Pivot Choice Decides Worst Case](references/divide-quickselect-vs-quicksort-partitioning.md) — MEDIUM (O(n²) to O(n log n) — random or median-of-3 pivots avoid pathological inputs)
   - 6.2 [Reuse The Merge-Sort Skeleton For Order-Pair Counting Problems](references/divide-merge-sort-pattern-for-counting-inversions.md) — MEDIUM-HIGH (O(n²) to O(n log n) — inversion counting, reverse pairs)
   - 6.3 [Use Meet-In-The-Middle When 2ⁿ Is Too Big But 2^(n/2) Fits](references/divide-meet-in-the-middle-for-subset-problems.md) — MEDIUM (O(2ⁿ) to O(2^(n/2) · n) — n = 40 becomes feasible)
   - 6.4 [Watch Recursion Depth — Convert To Iteration Or Raise The Stack](references/divide-watch-recursion-depth-and-stack.md) — MEDIUM (prevents RecursionError / stack overflow on deep recursion)
7. [Greedy Algorithms](references/_sections.md#7-greedy-algorithms) — **MEDIUM**
   - 7.1 [Prove A Greedy Choice With An Exchange Argument Before Coding It](references/greedy-prove-exchange-argument-before-using.md) — MEDIUM (prevents shipping greedy algorithms that are silently incorrect)
   - 7.2 [Sort By The Right Key — Earliest Deadline, Smallest Ratio, Largest Density](references/greedy-sort-by-the-right-key-for-scheduling.md) — MEDIUM (turns O(n!) brute force into O(n log n) for many scheduling problems)
   - 7.3 [Use A Priority Queue For "Always Pick The Smallest" Greedies](references/greedy-huffman-and-priority-queue-greedies.md) — LOW-MEDIUM (O(n²) repeated min-scans to O(n log n) — Huffman, scheduling, merge-k-lists)
   - 7.4 [Use Sweep-Line For Interval Overlap And Maximum-Concurrency Problems](references/greedy-interval-merge-and-sweep-line.md) — MEDIUM (O(n²) pairwise checks to O(n log n) sort + linear sweep)
8. [String & Sequence Algorithms](references/_sections.md#8-string-&-sequence-algorithms) — **MEDIUM**
   - 8.1 [Use A Trie For Prefix Queries Over Many Strings](references/str-trie-for-prefix-queries.md) — MEDIUM (O(n·m) per query to O(m) — autocompleter / spellchecker workloads)
   - 8.2 [Use Rolling Hashes For Many Substring Comparisons](references/str-rolling-hash-for-multiple-substring-comparisons.md) — MEDIUM (O(m) per equality check to O(1) — enables O(n) algorithms for hard string problems)
   - 8.3 [Use Suffix Arrays Or Suffix Automata For Heavy Substring Queries](references/str-suffix-array-or-automaton-for-substring-queries.md) — LOW-MEDIUM (O(n²) substring enumeration to O(n log n) construction + O(m) per query)
   - 8.4 [Use The Stdlib Or KMP For Substring Search, Not Naive Matching](references/str-kmp-or-builtin-find-not-naive-search.md) — MEDIUM (O(n·m) worst case to O(n+m) — orders of magnitude on adversarial input)

---

## References

1. [https://mitpress.mit.edu/9780262046305/introduction-to-algorithms/](https://mitpress.mit.edu/9780262046305/introduction-to-algorithms/)
2. [https://algs4.cs.princeton.edu/](https://algs4.cs.princeton.edu/)
3. [http://www.algorist.com/](http://www.algorist.com/)
4. [https://cses.fi/book/book.pdf](https://cses.fi/book/book.pdf)
5. [https://cp-algorithms.com/](https://cp-algorithms.com/)
6. [https://usaco.guide/](https://usaco.guide/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |