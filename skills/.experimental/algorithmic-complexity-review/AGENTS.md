# Algorithmic Complexity (Big-O)

**Version 0.1.0**  
dot-skills  
May 2026

> **Note:**  
> This document covers Algorithmic Complexity (Big-O) analysis and remediation.  
> It is mainly for agents and LLMs to follow when maintaining, generating, or  
> refactoring codebases. Humans may also find it useful, but guidance here is  
> optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Language-agnostic algorithmic complexity review guide for AI agents. Contains 39 rules across 8 categories covering accidental quadratic patterns, N+1 I/O, data-structure mismatch, exponential recursion, redundant computation, collection-building anti-patterns, search/sort selection, and space-complexity traps. Each rule includes a minimal-diff incorrect/correct code example, an explanation of the cascade effect, and exceptions. Designed to help agents find, classify, and fix Big-O issues in code reviews, refactors, and performance investigations across Python, JavaScript/TypeScript, Java, Go, and similar languages.

---

## Table of Contents

1. [Nested Iteration Patterns](references/_sections.md#1-nested-iteration-patterns) — **CRITICAL**
   - 1.1 [Avoid `.includes()` / `.indexOf()` Inside a Loop](references/nested-includes-in-loop.md) — CRITICAL (O(n*m) to O(n+m) — typical 50-500× speedup)
   - 1.2 [Group by Key Instead of Cartesian Comparison](references/nested-cartesian-comparison.md) — CRITICAL (O(n²) to O(n) — "find duplicates / similar pairs" is the canonical case)
   - 1.3 [Index Lookups Once Instead of `.find()` per Iteration](references/nested-find-in-loop.md) — CRITICAL (O(n*m) to O(n+m) — application-side join speedup of 50-1000×)
   - 1.4 [Replace Pairwise Loops With Hash-Based Single Passes](references/nested-explicit-quadratic-loops.md) — CRITICAL (O(n²) to O(n) — 100× faster at n=10,000)
   - 1.5 [Tokenize Once Instead of Re-scanning a String per Pattern](references/nested-substring-search-in-loop.md) — CRITICAL (O(p*L) to O(L+p) per document — across D docs, O(D*p*L) drops to O(D*(L+p)))
   - 1.6 [Use Sets for Intersection, Union, and Difference](references/nested-set-operations-on-arrays.md) — CRITICAL (O(n*m) to O(n+m) — typical 100× speedup on large lists)
2. [Loop-Invariant I/O and N+1 Queries](references/_sections.md#2-loop-invariant-i/o-and-n+1-queries) — **CRITICAL**
   - 2.1 [Declare Eager-Loading for ORM Relations You Will Access](references/io-missing-eager-load.md) — CRITICAL (N+1 to 1-2 queries — same as N+1 but framed at the schema-traversal level)
   - 2.2 [Eliminate N+1 Queries by Fetching Related Data in One Round Trip](references/io-n-plus-one-query.md) — CRITICAL (N+1 round trips to 1-2 — typical 10-100× wall-clock speedup)
   - 2.3 [Read or Stat Files Outside Tight Loops](references/io-file-read-in-loop.md) — HIGH (O(n) syscalls eliminated — 10-100× speedup on disk-bound code)
   - 2.4 [Run Independent Async Operations in Parallel](references/io-sequential-await-in-loop.md) — CRITICAL (sum(latencies) to max(latencies) — typical 5-20× wall-clock speedup)
   - 2.5 [Use Batch Endpoints Instead of Per-Item Calls](references/io-batch-instead-of-per-item.md) — CRITICAL (N calls to 1 batched call — 10-100× latency reduction)
3. [Data Structure Mismatch](references/_sections.md#3-data-structure-mismatch) — **HIGH**
   - 3.1 [Store Records Keyed in a Hashmap, Not as Parallel Arrays](references/ds-hashmap-for-keyed-access.md) — HIGH (O(n) per lookup to O(1) — flips entire access patterns linear)
   - 3.2 [Use a Deque for Front Insertions and Removals](references/ds-deque-for-front-operations.md) — HIGH (O(n) per op to O(1) — flips queue/sliding-window code from quadratic to linear)
   - 3.3 [Use a Heap for Top-K, Not Full Sort + Slice](references/ds-heap-for-top-k.md) — HIGH (O(n log n) to O(n log k) — 10-1000× speedup when k << n)
   - 3.4 [Use a Sorted Structure for Range Queries](references/ds-sorted-structure-for-range-queries.md) — HIGH (O(n) per range query to O(log n + k) — k = result size)
   - 3.5 [Use a Trie for Prefix Search](references/ds-trie-for-prefix-search.md) — MEDIUM-HIGH (O(n*L) per query to O(L + k) — k = matches, L = query length)
   - 3.6 [Use Counter / Multiset for Frequency Counting](references/ds-counter-for-histograms.md) — MEDIUM-HIGH (O(n²) to O(n) — and replaces 5-10 lines with one)
4. [Recursion Complexity](references/_sections.md#4-recursion-complexity) — **HIGH**
   - 4.1 [Memoize Recursion With Overlapping Subproblems](references/rec-memoize-overlapping-subproblems.md) — CRITICAL (O(2ⁿ) to O(n) — 1,000,000× faster at n=30)
   - 4.2 [Prune Recursive Search With Bounds and Constraints](references/rec-prune-with-bounds.md) — HIGH (Worst-case exponential, practical 10-1000× speedup)
   - 4.3 [Share Memoization Across Top-Level Calls](references/rec-share-memo-across-top-level-calls.md) — HIGH (O(q*n) to O(q+n) for q queries — eliminates repeat exponential work)
   - 4.4 [Tabulate Bottom-Up to Eliminate Recursion Overhead](references/rec-tabulate-bottom-up.md) — MEDIUM-HIGH (Same Big-O but 2-10× constant-factor speedup; eliminates stack-depth risk)
   - 4.5 [Use an Explicit Stack Instead of Deep Recursion](references/rec-iterative-for-deep-recursion.md) — HIGH (Prevents stack overflow on n > ~1,000; modest perf win from removing frames)
5. [Redundant Computation](references/_sections.md#5-redundant-computation) — **MEDIUM-HIGH**
   - 5.1 [Cache Expensive Pure-Function Results](references/compute-cache-expensive-pure-results.md) — MEDIUM-HIGH (Eliminates repeated heavy computation — common 10-100× speedups)
   - 5.2 [Cache Repeated Property Lookups in Hot Loops](references/compute-cache-property-lookup.md) — MEDIUM (2-20× speedup when property access traverses multiple objects or proxies)
   - 5.3 [Compile Regex Patterns Once at Module Level](references/compute-precompile-regex.md) — MEDIUM (5-50× per regex use — compilation typically dominates matching for short inputs)
   - 5.4 [Defer or Short-Circuit Work You Might Not Need](references/compute-defer-or-short-circuit.md) — MEDIUM (Eliminates work entirely — speedup depends on hit rate but often 2-10×)
   - 5.5 [Hoist Loop-Invariant Computation Outside the Loop](references/compute-hoist-loop-invariants.md) — MEDIUM-HIGH (Eliminates O(n) repeated work per loop body — 2-50× when invariant is heavy)
6. [Collection Building](references/_sections.md#6-collection-building) — **MEDIUM**
   - 6.1 [Allocate Collections With the Known Final Length](references/build-presize-when-length-known.md) — LOW-MEDIUM (2-5× constant-factor speedup; avoids GC pressure from repeated reallocs)
   - 6.2 [Build Strings With Joins or Builders, Not Repeated Concatenation](references/build-avoid-quadratic-string-concat.md) — HIGH (O(n²) to O(n) — orders of magnitude on large strings)
   - 6.3 [Push to a Mutable Accumulator Instead of Spreading](references/build-avoid-spread-in-reducer.md) — HIGH (O(n²) to O(n) — common 100-1000× speedup on JS reducers)
   - 6.4 [Use a Plain Object Build Phase, Then Freeze](references/build-avoid-immutable-object-spread.md) — MEDIUM-HIGH (O(n*k) to O(n) — k = property count of the growing object)
7. [Search & Sort Selection](references/_sections.md#7-search-&-sort-selection) — **MEDIUM**
   - 7.1 [Build the Index Once When Queries Dominate](references/search-build-index-once-amortize.md) — MEDIUM-HIGH (O(q*n) to O(n + q) — break-even at q ≥ 1 for most index types)
   - 7.2 [Sort Once Outside the Loop, Not on Every Iteration](references/search-sort-once-outside-loop.md) — HIGH (O(n²·log n) to O(n·log n + n) — orders of magnitude on hot paths)
   - 7.3 [Use Binary Search on Sorted Data](references/search-binary-search-on-sorted.md) — MEDIUM-HIGH (O(n) per lookup to O(log n) — 1,000× speedup at n=1,000,000)
   - 7.4 [Use Quickselect for the K-th Element, Not Full Sort](references/search-quickselect-not-full-sort.md) — MEDIUM (O(n log n) to O(n) average — useful when k is fixed and small)
8. [Space Complexity Traps](references/_sections.md#8-space-complexity-traps) — **LOW-MEDIUM**
   - 8.1 [Pipe Through Generators Instead of Materializing Intermediate Lists](references/space-generators-over-intermediate-lists.md) — MEDIUM (O(n) intermediate storage to O(1) — also enables early exit)
   - 8.2 [Release References That Prevent Garbage Collection](references/space-release-retained-references.md) — LOW-MEDIUM (Prevents long-tail memory growth; GC pressure shows up as latency, not OOM)
   - 8.3 [Stream Large Inputs Instead of Loading Them Whole](references/space-stream-dont-load.md) — HIGH (O(n) memory to O(1) — enables processing files larger than RAM)
   - 8.4 [Use Shallow Copies (or No Copy) Instead of Deep Clones](references/space-shallow-not-deep-copy.md) — MEDIUM (O(size × depth) to O(1) or O(top-level) — 10-100× on nested structures)

---

## References

1. [https://wiki.python.org/moin/TimeComplexity](https://wiki.python.org/moin/TimeComplexity)
2. [https://en.cppreference.com/w/cpp/algorithm](https://en.cppreference.com/w/cpp/algorithm)
3. [https://docs.oracle.com/javase/8/docs/technotes/guides/collections/overview.html](https://docs.oracle.com/javase/8/docs/technotes/guides/collections/overview.html)
4. [https://xlinux.nist.gov/dads/](https://xlinux.nist.gov/dads/)
5. [https://algs4.cs.princeton.edu/](https://algs4.cs.princeton.edu/)
6. [https://www.bigocheatsheet.com/](https://www.bigocheatsheet.com/)
7. [https://use-the-index-luke.com/](https://use-the-index-luke.com/)
8. [https://v8.dev/blog/elements-kinds](https://v8.dev/blog/elements-kinds)
9. [https://web.dev/articles/avoid-large-complex-layouts-and-layout-thrashing](https://web.dev/articles/avoid-large-complex-layouts-and-layout-thrashing)
10. [https://docs.djangoproject.com/en/stable/ref/models/querysets/#select-related](https://docs.djangoproject.com/en/stable/ref/models/querysets/#select-related)
11. [https://github.com/graphql/dataloader](https://github.com/graphql/dataloader)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |