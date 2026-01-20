# Rust

**Version 0.1.0**  
Community  
January 2026

> **Note:**
> This document is for agents and LLMs working with Rust code. It provides
> guidelines for maintaining, generating, or refactoring Rust codebases.
> Humans may also find it useful, but guidance is optimized for AI-assisted workflows.

---

## Abstract

Comprehensive performance optimization guide for Rust applications, designed for AI agents and LLMs. Contains 42+ rules across 8 categories, prioritized by impact from critical (memory allocation, ownership patterns) to incremental (micro-optimizations). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Memory Allocation](references/_sections.md#1-memory-allocation) — **CRITICAL**
   - 1.1 [Avoid format! for Simple Concatenation](references/mem-avoid-format-for-simple-concatenation.md) — CRITICAL (eliminates allocation for string literals)
   - 1.2 [Avoid Unnecessary Clone Calls](references/mem-avoid-unnecessary-clone.md) — CRITICAL (eliminates heap allocations per call)
   - 1.3 [Preallocate Vec Capacity](references/mem-preallocate-vec-capacity.md) — CRITICAL (reduces allocations by 3-5× for growing vectors)
   - 1.4 [Use Arc for Shared Immutable Data](references/mem-use-arc-for-shared-immutable-data.md) — CRITICAL (eliminates N clones for N readers)
   - 1.5 [Use Cow for Conditional Ownership](references/mem-use-cow-for-conditional-ownership.md) — CRITICAL (avoids allocation in read-only path)
   - 1.6 [Use SmallVec for Small Collections](references/mem-use-smallvec-for-small-collections.md) — CRITICAL (eliminates heap allocation for typical cases)
2. [Ownership & Borrowing](references/_sections.md#2-ownership-&-borrowing) — **CRITICAL**
   - 2.1 [Accept &[T] Instead of &Vec<T>](references/own-accept-slice-not-vec.md) — CRITICAL (eliminates allocation for array callers)
   - 2.2 [Accept &str Instead of &String](references/own-accept-str-slice-not-string.md) — CRITICAL (eliminates allocation for &str callers)
   - 2.3 [Return Borrowed Data When Possible](references/own-return-borrowed-when-possible.md) — CRITICAL (eliminates allocation for accessor methods)
   - 2.4 [Use AsRef<T> for Generic Borrows](references/own-use-asref-for-generic-borrows.md) — CRITICAL (eliminates allocation for borrowed callers)
   - 2.5 [Use Into<T> for Flexible Ownership Transfer](references/own-use-into-for-flexible-ownership.md) — CRITICAL (avoids allocation when caller already owns data)
3. [Data Structure Selection](references/_sections.md#3-data-structure-selection) — **HIGH**
   - 3.1 [Use BTreeMap for Sorted Iteration](references/ds-use-btreemap-for-sorted-iteration.md) — HIGH (avoids O(n log n) sort after each insertion)
   - 3.2 [Use Entry API for Conditional Insert](references/ds-use-entry-api-for-conditional-insert.md) — HIGH (single lookup instead of two)
   - 3.3 [Use HashMap for Key-Value Lookups](references/ds-use-hashmap-for-key-lookup.md) — HIGH (O(n) to O(1) per lookup)
   - 3.4 [Use HashSet for Membership Tests](references/ds-use-hashset-for-membership.md) — HIGH (O(n) to O(1) per lookup)
   - 3.5 [Use VecDeque for Queue Operations](references/ds-use-vecdeque-for-queue-operations.md) — HIGH (O(n) to O(1) for front operations)
4. [Iterator & Collection Patterns](references/_sections.md#4-iterator-&-collection-patterns) — **HIGH**
   - 4.1 [Chain Iterators Instead of Intermediate Collect](references/iter-chain-instead-of-intermediate-collect.md) — HIGH (eliminates intermediate allocations)
   - 4.2 [Use extend() for Bulk Append](references/iter-use-extend-for-bulk-append.md) — HIGH (single reallocation instead of N)
   - 4.3 [Use filter_map for Combined Filter and Map](references/iter-use-filter-map-for-combined-operations.md) — HIGH (single pass instead of two)
   - 4.4 [Use flat_map for Nested Iteration](references/iter-use-flat-map-for-nested-iteration.md) — HIGH (avoids nested loops and intermediate collections)
   - 4.5 [Use fold() for Complex Accumulation](references/iter-use-fold-for-accumulation.md) — HIGH (single pass with custom accumulator)
   - 4.6 [Use iter() Over into_iter() When Borrowing](references/iter-use-iter-over-into-iter-when-borrowing.md) — HIGH (preserves original collection)
5. [Async & Concurrency](references/_sections.md#5-async-&-concurrency) — **MEDIUM-HIGH**
   - 5.1 [Avoid Blocking in Async Context](references/async-avoid-blocking-in-async-context.md) — MEDIUM-HIGH (prevents executor starvation)
   - 5.2 [Avoid Holding Lock Across await Points](references/async-avoid-holding-lock-across-await.md) — MEDIUM-HIGH (prevents deadlocks and starvation)
   - 5.3 [Minimize Lock Scope](references/async-minimize-lock-scope.md) — MEDIUM-HIGH (reduces contention time)
   - 5.4 [Use buffered() for Bounded Concurrency](references/async-use-buffered-for-bounded-concurrency.md) — MEDIUM-HIGH (prevents resource exhaustion)
   - 5.5 [Use join! for Concurrent Futures](references/async-use-join-for-concurrent-futures.md) — MEDIUM-HIGH (2-5× faster for multiple independent operations)
   - 5.6 [Use RwLock Over Mutex for Read-Heavy Workloads](references/async-use-rwlock-over-mutex-for-read-heavy.md) — MEDIUM-HIGH (2-10× throughput for read-heavy workloads)
6. [Algorithm Complexity](references/_sections.md#6-algorithm-complexity) — **MEDIUM**
   - 6.1 [Avoid Nested Loops for Lookups](references/algo-avoid-nested-loops-for-lookup.md) — MEDIUM (O(n×m) to O(n+m))
   - 6.2 [Use Binary Search for Sorted Data](references/algo-use-binary-search-for-sorted-data.md) — MEDIUM (O(n) to O(log n))
   - 6.3 [Use chunks() for Batch Processing](references/algo-use-chunks-for-batch-processing.md) — MEDIUM (reduces overhead per element)
   - 6.4 [Use select_nth_unstable for Partial Sorting](references/algo-use-select-nth-unstable-for-partial-sort.md) — MEDIUM (O(n log n) to O(n) for finding kth element)
   - 6.5 [Use sort_unstable When Order of Equal Elements Is Irrelevant](references/algo-use-sort-unstable-when-order-irrelevant.md) — MEDIUM (10-30% faster sorting)
7. [Compile-Time Optimization](references/_sections.md#7-compile-time-optimization) — **MEDIUM**
   - 7.1 [Avoid Repeated Parsing of Static Data](references/comp-avoid-repeated-parsing-of-static-data.md) — MEDIUM (100-1000× speedup for repeated operations)
   - 7.2 [Prefer Static Dispatch Over Dynamic Dispatch](references/comp-prefer-static-dispatch.md) — MEDIUM (enables inlining and eliminates vtable lookup)
   - 7.3 [Reduce Monomorphization Bloat](references/comp-reduce-monomorphization-bloat.md) — MEDIUM (smaller binaries, better instruction cache usage)
   - 7.4 [Use const for Compile-Time Computation](references/comp-use-const-for-compile-time-computation.md) — MEDIUM (eliminates runtime computation entirely)
   - 7.5 [Use Const Generics for Array Sizes](references/comp-use-const-generics-for-array-sizes.md) — MEDIUM (eliminates runtime bounds checks)
8. [Micro-optimizations](references/_sections.md#8-micro-optimizations) — **LOW**
   - 8.1 [Apply inline Attribute to Small Hot Functions](references/micro-use-inline-for-small-functions.md) — LOW (eliminates function call overhead)
   - 8.2 [Avoid Bounds Checks in Hot Loops](references/micro-avoid-bounds-checks-in-hot-loops.md) — LOW (eliminates branch per iteration)
   - 8.3 [Use Byte Literals for ASCII Operations](references/micro-use-byte-literals-for-ascii.md) — LOW (avoids char-to-byte conversion)
   - 8.4 [Use Wrapping Arithmetic When Overflow Is Expected](references/micro-use-wrapping-arithmetic-when-safe.md) — LOW (eliminates overflow check overhead)

---

## References

1. [https://nnethercote.github.io/perf-book/](https://nnethercote.github.io/perf-book/)
2. [https://rust-lang.github.io/api-guidelines/](https://rust-lang.github.io/api-guidelines/)
3. [https://doc.rust-lang.org/nomicon/](https://doc.rust-lang.org/nomicon/)
4. [https://doc.rust-lang.org/book/](https://doc.rust-lang.org/book/)
5. [https://tokio.rs/tokio/tutorial](https://tokio.rs/tokio/tutorial)
6. [https://doc.rust-lang.org/reference/behavior-considered-undefined.html](https://doc.rust-lang.org/reference/behavior-considered-undefined.html)
7. [https://www.scylladb.com/2022/01/12/async-rust-in-practice-performance-pitfalls-profiling/](https://www.scylladb.com/2022/01/12/async-rust-in-practice-performance-pitfalls-profiling/)
8. [https://rustc-dev-guide.rust-lang.org/](https://rustc-dev-guide.rust-lang.org/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |