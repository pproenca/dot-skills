---
name: rust-optimise
description: Rust performance optimization covering memory allocation, ownership efficiency, data structure selection, iterator patterns, async concurrency, algorithm complexity, compile-time optimization, and micro-optimizations. Use when optimizing Rust code performance, profiling hot paths, reducing allocations, or choosing optimal data structures. Complements the rust-refactor skill (idiomatic patterns and architecture). Does NOT cover code style, naming conventions, or project organization (see rust-refactor skill).
---

# Rust Optimise Best Practices

Performance optimization guide for Rust applications. Contains 42 rules across 8 categories, prioritized by impact from critical (memory allocation, ownership) to incremental (micro-optimizations).

## When to Apply

- Optimizing Rust code for performance or reducing allocations
- Choosing data structures for optimal algorithmic complexity
- Working with iterators to avoid unnecessary intermediate allocations
- Writing async code with Tokio or other runtimes
- Profiling hot paths and eliminating performance bottlenecks
- Reviewing code for performance anti-patterns

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Memory Allocation | CRITICAL | `mem-` |
| 2 | Ownership & Borrowing | CRITICAL | `own-` |
| 3 | Data Structure Selection | HIGH | `ds-` |
| 4 | Iterator & Collection Patterns | HIGH | `iter-` |
| 5 | Async & Concurrency | MEDIUM-HIGH | `async-` |
| 6 | Algorithm Complexity | MEDIUM | `algo-` |
| 7 | Compile-Time Optimization | MEDIUM | `comp-` |
| 8 | Micro-optimizations | LOW | `micro-` |

## Quick Reference

### 1. Memory Allocation (CRITICAL)

- [`mem-avoid-unnecessary-clone`](references/mem-avoid-unnecessary-clone.md) - Avoid unnecessary clone calls
- [`mem-preallocate-vec-capacity`](references/mem-preallocate-vec-capacity.md) - Preallocate Vec capacity
- [`mem-use-cow-for-conditional-ownership`](references/mem-use-cow-for-conditional-ownership.md) - Use Cow for conditional ownership
- [`mem-use-arc-for-shared-immutable-data`](references/mem-use-arc-for-shared-immutable-data.md) - Use Arc for shared immutable data
- [`mem-avoid-format-for-simple-concatenation`](references/mem-avoid-format-for-simple-concatenation.md) - Avoid format! for simple concatenation
- [`mem-use-smallvec-for-small-collections`](references/mem-use-smallvec-for-small-collections.md) - Use SmallVec for small collections

### 2. Ownership & Borrowing (CRITICAL)

- [`own-accept-str-slice-not-string`](references/own-accept-str-slice-not-string.md) - Accept &str instead of &String
- [`own-accept-slice-not-vec`](references/own-accept-slice-not-vec.md) - Accept &[T] instead of &Vec<T>
- [`own-use-into-for-flexible-ownership`](references/own-use-into-for-flexible-ownership.md) - Use Into<T> for flexible ownership
- [`own-return-borrowed-when-possible`](references/own-return-borrowed-when-possible.md) - Return borrowed data when possible
- [`own-use-asref-for-generic-borrows`](references/own-use-asref-for-generic-borrows.md) - Use AsRef<T> for generic borrows

### 3. Data Structure Selection (HIGH)

- [`ds-use-hashset-for-membership`](references/ds-use-hashset-for-membership.md) - Use HashSet for membership tests
- [`ds-use-hashmap-for-key-lookup`](references/ds-use-hashmap-for-key-lookup.md) - Use HashMap for key-value lookups
- [`ds-use-btreemap-for-sorted-iteration`](references/ds-use-btreemap-for-sorted-iteration.md) - Use BTreeMap for sorted iteration
- [`ds-use-vecdeque-for-queue-operations`](references/ds-use-vecdeque-for-queue-operations.md) - Use VecDeque for queue operations
- [`ds-use-entry-api-for-conditional-insert`](references/ds-use-entry-api-for-conditional-insert.md) - Use Entry API for conditional insert

### 4. Iterator & Collection Patterns (HIGH)

- [`iter-chain-instead-of-intermediate-collect`](references/iter-chain-instead-of-intermediate-collect.md) - Chain iterators instead of intermediate collect
- [`iter-use-iter-over-into-iter-when-borrowing`](references/iter-use-iter-over-into-iter-when-borrowing.md) - Use iter() over into_iter() when borrowing
- [`iter-use-filter-map-for-combined-operations`](references/iter-use-filter-map-for-combined-operations.md) - Use filter_map for combined operations
- [`iter-use-flat-map-for-nested-iteration`](references/iter-use-flat-map-for-nested-iteration.md) - Use flat_map for nested iteration
- [`iter-use-extend-for-bulk-append`](references/iter-use-extend-for-bulk-append.md) - Use extend() for bulk append
- [`iter-use-fold-for-accumulation`](references/iter-use-fold-for-accumulation.md) - Use fold() for complex accumulation

### 5. Async & Concurrency (MEDIUM-HIGH)

- [`async-avoid-blocking-in-async-context`](references/async-avoid-blocking-in-async-context.md) - Avoid blocking in async context
- [`async-use-join-for-concurrent-futures`](references/async-use-join-for-concurrent-futures.md) - Use join! for concurrent futures
- [`async-use-rwlock-over-mutex-for-read-heavy`](references/async-use-rwlock-over-mutex-for-read-heavy.md) - Use RwLock over Mutex for read-heavy
- [`async-minimize-lock-scope`](references/async-minimize-lock-scope.md) - Minimize lock scope
- [`async-use-buffered-for-bounded-concurrency`](references/async-use-buffered-for-bounded-concurrency.md) - Use buffered() for bounded concurrency
- [`async-avoid-holding-lock-across-await`](references/async-avoid-holding-lock-across-await.md) - Avoid holding lock across await

### 6. Algorithm Complexity (MEDIUM)

- [`algo-avoid-nested-loops-for-lookup`](references/algo-avoid-nested-loops-for-lookup.md) - Avoid nested loops for lookups
- [`algo-use-binary-search-for-sorted-data`](references/algo-use-binary-search-for-sorted-data.md) - Use binary search for sorted data
- [`algo-use-sort-unstable-when-order-irrelevant`](references/algo-use-sort-unstable-when-order-irrelevant.md) - Use sort_unstable when order irrelevant
- [`algo-use-select-nth-unstable-for-partial-sort`](references/algo-use-select-nth-unstable-for-partial-sort.md) - Use select_nth_unstable for partial sort
- [`algo-use-chunks-for-batch-processing`](references/algo-use-chunks-for-batch-processing.md) - Use chunks() for batch processing

### 7. Compile-Time Optimization (MEDIUM)

- [`comp-use-const-for-compile-time-computation`](references/comp-use-const-for-compile-time-computation.md) - Use const for compile-time computation
- [`comp-prefer-static-dispatch`](references/comp-prefer-static-dispatch.md) - Prefer static dispatch over dynamic
- [`comp-reduce-monomorphization-bloat`](references/comp-reduce-monomorphization-bloat.md) - Reduce monomorphization bloat
- [`comp-use-const-generics-for-array-sizes`](references/comp-use-const-generics-for-array-sizes.md) - Use const generics for array sizes
- [`comp-avoid-repeated-parsing-of-static-data`](references/comp-avoid-repeated-parsing-of-static-data.md) - Avoid repeated parsing of static data

### 8. Micro-optimizations (LOW)

- [`micro-use-inline-for-small-functions`](references/micro-use-inline-for-small-functions.md) - Apply inline attribute to small hot functions
- [`micro-avoid-bounds-checks-in-hot-loops`](references/micro-avoid-bounds-checks-in-hot-loops.md) - Avoid bounds checks in hot loops
- [`micro-use-wrapping-arithmetic-when-safe`](references/micro-use-wrapping-arithmetic-when-safe.md) - Use wrapping arithmetic when safe
- [`micro-use-byte-literals-for-ascii`](references/micro-use-byte-literals-for-ascii.md) - Use byte literals for ASCII

## References

1. [https://nnethercote.github.io/perf-book/](https://nnethercote.github.io/perf-book/)
2. [https://rust-lang.github.io/api-guidelines/](https://rust-lang.github.io/api-guidelines/)
3. [https://doc.rust-lang.org/nomicon/](https://doc.rust-lang.org/nomicon/)
4. [https://tokio.rs/tokio/tutorial](https://tokio.rs/tokio/tutorial)

## Related Skills

- For idiomatic patterns, architecture, and code organization, see `rust-refactor` skill
