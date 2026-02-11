# Ruby

**Version 0.1.0**
Community
February 2026

> **Note:** This document is for agents and LLMs to follow when writing, reviewing, or refactoring ruby codebases.
> Humans may also find it useful, but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive performance optimization guide for Ruby applications, designed for AI agents and LLMs. Contains 42 rules across 8 categories, prioritized by impact from critical (object allocation, collection enumeration) to incremental (runtime configuration). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Object Allocation](references/_sections.md#1-object-allocation) — **CRITICAL**
   - 1.1 [Avoid Repeated Computation in Hot Paths](references/alloc-avoid-implicit-conversions.md) — MEDIUM-HIGH (eliminates redundant allocations from repeated to_s, to_a, Time.now)
   - 1.2 [Avoid Temporary Array Creation](references/alloc-avoid-temp-arrays.md) — HIGH (eliminates N intermediate allocations per iteration)
   - 1.3 [Avoid Unnecessary Object Duplication](references/alloc-avoid-unnecessary-dup.md) — CRITICAL (eliminates redundant allocations in hot paths)
   - 1.4 [Freeze Constant Collections](references/alloc-freeze-constants.md) — CRITICAL (prevents repeated allocation of identical objects)
   - 1.5 [Reuse Buffers in Loops](references/alloc-reuse-buffers.md) — MEDIUM-HIGH (reduces allocations from O(n) to O(1))
   - 1.6 [Use Lazy Initialization for Expensive Objects](references/alloc-lazy-initialization.md) — HIGH (defers allocation until needed, reduces startup overhead)
2. [Collection & Enumeration](references/_sections.md#2-collection--enumeration) — **CRITICAL**
   - 2.1 [Avoid Recomputing Collection Size in Conditions](references/enum-avoid-count-in-loops.md) — MEDIUM (O(n) to O(1) per check for non-Array enumerables)
   - 2.2 [Use each_slice for Batch Processing](references/enum-chunk-batch-processing.md) — MEDIUM (O(batch) memory vs O(n) for full dataset)
   - 2.3 [Use each_with_object Over inject for Building Collections](references/enum-each-with-object.md) — MEDIUM (eliminates common accumulator-return bugs and improves readability)
   - 2.4 [Use flat_map Instead of map.flatten](references/enum-flat-map.md) — HIGH (eliminates intermediate nested array allocation)
   - 2.5 [Use Lazy Enumerators for Large Collections](references/enum-lazy-large-collections.md) — CRITICAL (processes elements on demand, avoids loading entire collection)
   - 2.6 [Use Single-Pass Collection Transforms](references/enum-single-pass.md) — CRITICAL (eliminates N intermediate arrays from chained methods)
3. [I/O & Database](references/_sections.md#3-io--database) — **HIGH**
   - 3.1 [Avoid Database Queries Inside Loops](references/io-avoid-queries-in-loops.md) — HIGH (reduces N queries to 1 bulk query)
   - 3.2 [Cache Expensive Database Results](references/io-cache-expensive-queries.md) — MEDIUM (eliminates repeated identical queries across requests)
   - 3.3 [Eager Load ActiveRecord Associations](references/io-eager-load-associations.md) — HIGH (eliminates N+1 queries, reduces from 2N+1 to 3 queries)
   - 3.4 [Select Only Needed Columns](references/io-select-only-needed-columns.md) — HIGH (reduces memory allocation and query transfer time by 50-90%)
   - 3.5 [Size Connection Pools to Match Thread Count](references/io-connection-pool-sizing.md) — MEDIUM (prevents connection checkout timeouts under load)
   - 3.6 [Stream Large Files Line by Line](references/io-stream-large-files.md) — MEDIUM-HIGH (O(1) memory vs O(n) — saves GBs on large files)
   - 3.7 [Use find_each for Large Record Sets](references/io-batch-find-each.md) — HIGH (O(1000) memory vs O(n) for entire table)
4. [String Handling](references/_sections.md#4-string-handling) — **HIGH**
   - 4.1 [Chain gsub Calls into a Single Replacement](references/str-avoid-repeated-gsub.md) — MEDIUM (reduces N string allocations and regex scans to 1)
   - 4.2 [Enable Frozen String Literals](references/str-frozen-literals.md) — HIGH (reduces GC pressure by ~20%, saves ~100MB in production Rails apps)
   - 4.3 [Use Shovel Operator for String Building](references/str-shovel-over-plus.md) — HIGH (reduces N string allocations to 0 in loops)
   - 4.4 [Use String Interpolation Over Concatenation](references/str-interpolation-over-concatenation.md) — MEDIUM-HIGH (single allocation vs N intermediate strings)
   - 4.5 [Use Symbols for Identifiers and Hash Keys](references/str-symbol-for-identifiers.md) — MEDIUM (1.3-2x faster hash lookups, single allocation per symbol)
5. [Method & Dispatch](references/_sections.md#5-method--dispatch) — **MEDIUM-HIGH**
   - 5.1 [Avoid Dynamic send in Performance-Critical Code](references/meth-avoid-dynamic-send.md) — MEDIUM (send bypasses visibility checks and prevents YJIT optimization)
   - 5.2 [Avoid method_missing in Hot Paths](references/meth-avoid-method-missing-hot-paths.md) — MEDIUM-HIGH (method_missing is 2-10x slower than direct dispatch)
   - 5.3 [Cache Method References for Repeated Calls](references/meth-cache-method-references.md) — MEDIUM-HIGH (avoids repeated method lookup and Proc allocation overhead)
   - 5.4 [Pass Blocks Directly Instead of Converting to Proc](references/meth-block-vs-proc.md) — MEDIUM (avoids Proc allocation on each call)
   - 5.5 [Reduce Method Chain Depth in Hot Loops](references/meth-reduce-method-chain-depth.md) — MEDIUM (reduces N × depth dispatch calls to N × 1)
6. [Data Structures](references/_sections.md#6-data-structures) — **MEDIUM**
   - 6.1 [Preallocate Arrays When Size Is Known](references/ds-array-preallocation.md) — LOW-MEDIUM (avoids repeated resizing and memory copies)
   - 6.2 [Use Hash Default Values Instead of Conditional Assignment](references/ds-hash-default-value.md) — LOW-MEDIUM (eliminates conditional branches and simplifies accumulation)
   - 6.3 [Use Set for Membership Tests](references/ds-set-for-membership.md) — MEDIUM (O(1) lookup vs O(n) with Array#include?)
   - 6.4 [Use sort_by Instead of sort with Block](references/ds-sort-by-over-sort.md) — MEDIUM (2-5x faster for large collections via Schwartzian transform)
   - 6.5 [Use Struct Over OpenStruct](references/ds-struct-over-openstruct.md) — MEDIUM (Struct is 10-50x faster to instantiate than OpenStruct)
7. [Concurrency](references/_sections.md#7-concurrency) — **MEDIUM**
   - 7.1 [Avoid Shared Mutable State Between Threads](references/conc-avoid-shared-mutable-state.md) — MEDIUM (prevents race conditions and eliminates mutex contention overhead)
   - 7.2 [Size Thread Pools to Match Workload](references/conc-thread-pool-sizing.md) — MEDIUM (prevents GVL contention and resource exhaustion)
   - 7.3 [Use Fibers for I/O-Bound Concurrency](references/conc-fiber-for-io.md) — MEDIUM (reduces memory 250x per concurrent task (~4KB vs ~1MB))
   - 7.4 [Use Ractors for CPU-Bound Parallelism](references/conc-ractor-cpu-bound.md) — MEDIUM (2-8x throughput improvement on multi-core for CPU-bound work)
8. [Runtime & Configuration](references/_sections.md#8-runtime--configuration) — **LOW-MEDIUM**
   - 8.1 [Enable YJIT for Production](references/runtime-enable-yjit.md) — MEDIUM (15-25% latency reduction with zero code changes)
   - 8.2 [Optimize Require Load Order](references/runtime-optimize-require.md) — LOW (reduces boot time by deferring heavy gem loading)
   - 8.3 [Set Frozen String Literal as Project Default](references/runtime-frozen-string-literal-default.md) — LOW-MEDIUM (reduces string allocations across entire codebase)
   - 8.4 [Tune GC Parameters for Your Workload](references/runtime-tune-gc-parameters.md) — LOW-MEDIUM (reduces GC pause frequency by 30-50% for known allocation patterns)

---

## References

1. [https://docs.ruby-lang.org](https://docs.ruby-lang.org)
2. [https://github.com/rubocop/ruby-style-guide](https://github.com/rubocop/ruby-style-guide)
3. [https://ruby-style-guide.shopify.dev](https://ruby-style-guide.shopify.dev)
4. [https://shopify.engineering/ruby-yjit-is-production-ready](https://shopify.engineering/ruby-yjit-is-production-ready)
5. [https://railsatscale.com/2025-01-10-yjit-3-4-even-faster-and-more-memory-efficient/](https://railsatscale.com/2025-01-10-yjit-3-4-even-faster-and-more-memory-efficient/)
6. [https://www.datadoghq.com/blog/ruby-performance-optimization/](https://www.datadoghq.com/blog/ruby-performance-optimization/)
7. [https://guides.rubyonrails.org/active_record_querying.html](https://guides.rubyonrails.org/active_record_querying.html)
8. [https://blog.appsignal.com/2021/11/17/practical-garbage-collection-tuning-in-ruby.html](https://blog.appsignal.com/2021/11/17/practical-garbage-collection-tuning-in-ruby.html)
9. [https://pragprog.com/titles/adrpo/ruby-performance-optimization/](https://pragprog.com/titles/adrpo/ruby-performance-optimization/)
10. [https://github.com/fastruby/fast-ruby](https://github.com/fastruby/fast-ruby)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |
