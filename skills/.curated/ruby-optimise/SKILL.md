---
name: ruby-optimise
description: Ruby performance optimization guidelines. This skill should be used when writing, reviewing, or refactoring Ruby code to ensure optimal performance patterns. Triggers on tasks involving object allocation, collection processing, ActiveRecord queries, string handling, concurrency, or Ruby runtime configuration.
---

# Community Ruby Best Practices

Comprehensive performance optimization guide for Ruby applications, maintained by the community. Contains 42 rules across 8 categories, prioritized by impact to guide automated refactoring and code generation.

## When to Apply

Reference these guidelines when:
- Writing new Ruby code or gems
- Optimizing ActiveRecord queries and database access patterns
- Processing large collections or building data pipelines
- Reviewing code for memory bloat and GC pressure
- Configuring Ruby runtime settings for production

## Rule Categories by Priority

| Priority | Category | Impact | Prefix |
|----------|----------|--------|--------|
| 1 | Object Allocation | CRITICAL | `alloc-` |
| 2 | Collection & Enumeration | CRITICAL | `enum-` |
| 3 | I/O & Database | HIGH | `io-` |
| 4 | String Handling | HIGH | `str-` |
| 5 | Method & Dispatch | MEDIUM-HIGH | `meth-` |
| 6 | Data Structures | MEDIUM | `ds-` |
| 7 | Concurrency | MEDIUM | `conc-` |
| 8 | Runtime & Configuration | LOW-MEDIUM | `runtime-` |

## Quick Reference

### 1. Object Allocation (CRITICAL)

- [`alloc-avoid-unnecessary-dup`](references/alloc-avoid-unnecessary-dup.md) - Avoid Unnecessary Object Duplication
- [`alloc-freeze-constants`](references/alloc-freeze-constants.md) - Freeze Constant Collections
- [`alloc-lazy-initialization`](references/alloc-lazy-initialization.md) - Use Lazy Initialization for Expensive Objects
- [`alloc-avoid-temp-arrays`](references/alloc-avoid-temp-arrays.md) - Avoid Temporary Array Creation
- [`alloc-reuse-buffers`](references/alloc-reuse-buffers.md) - Reuse Buffers in Loops
- [`alloc-avoid-implicit-conversions`](references/alloc-avoid-implicit-conversions.md) - Avoid Repeated Computation in Hot Paths

### 2. Collection & Enumeration (CRITICAL)

- [`enum-single-pass`](references/enum-single-pass.md) - Use Single-Pass Collection Transforms
- [`enum-lazy-large-collections`](references/enum-lazy-large-collections.md) - Use Lazy Enumerators for Large Collections
- [`enum-flat-map`](references/enum-flat-map.md) - Use flat_map Instead of map.flatten
- [`enum-each-with-object`](references/enum-each-with-object.md) - Use each_with_object Over inject for Building Collections
- [`enum-avoid-count-in-loops`](references/enum-avoid-count-in-loops.md) - Avoid Recomputing Collection Size in Conditions
- [`enum-chunk-batch-processing`](references/enum-chunk-batch-processing.md) - Use each_slice for Batch Processing

### 3. I/O & Database (HIGH)

- [`io-eager-load-associations`](references/io-eager-load-associations.md) - Eager Load ActiveRecord Associations
- [`io-select-only-needed-columns`](references/io-select-only-needed-columns.md) - Select Only Needed Columns
- [`io-batch-find-each`](references/io-batch-find-each.md) - Use find_each for Large Record Sets
- [`io-avoid-queries-in-loops`](references/io-avoid-queries-in-loops.md) - Avoid Database Queries Inside Loops
- [`io-stream-large-files`](references/io-stream-large-files.md) - Stream Large Files Line by Line
- [`io-connection-pool-sizing`](references/io-connection-pool-sizing.md) - Size Connection Pools to Match Thread Count
- [`io-cache-expensive-queries`](references/io-cache-expensive-queries.md) - Cache Expensive Database Results

### 4. String Handling (HIGH)

- [`str-frozen-literals`](references/str-frozen-literals.md) - Enable Frozen String Literals
- [`str-shovel-over-plus`](references/str-shovel-over-plus.md) - Use Shovel Operator for String Building
- [`str-interpolation-over-concatenation`](references/str-interpolation-over-concatenation.md) - Use String Interpolation Over Concatenation
- [`str-avoid-repeated-gsub`](references/str-avoid-repeated-gsub.md) - Chain gsub Calls into a Single Replacement
- [`str-symbol-for-identifiers`](references/str-symbol-for-identifiers.md) - Use Symbols for Identifiers and Hash Keys

### 5. Method & Dispatch (MEDIUM-HIGH)

- [`meth-avoid-method-missing-hot-paths`](references/meth-avoid-method-missing-hot-paths.md) - Avoid method_missing in Hot Paths
- [`meth-cache-method-references`](references/meth-cache-method-references.md) - Cache Method References for Repeated Calls
- [`meth-block-vs-proc`](references/meth-block-vs-proc.md) - Pass Blocks Directly Instead of Converting to Proc
- [`meth-avoid-dynamic-send`](references/meth-avoid-dynamic-send.md) - Avoid Dynamic send in Performance-Critical Code
- [`meth-reduce-method-chain-depth`](references/meth-reduce-method-chain-depth.md) - Reduce Method Chain Depth in Hot Loops

### 6. Data Structures (MEDIUM)

- [`ds-set-for-membership`](references/ds-set-for-membership.md) - Use Set for Membership Tests
- [`ds-struct-over-openstruct`](references/ds-struct-over-openstruct.md) - Use Struct Over OpenStruct
- [`ds-sort-by-over-sort`](references/ds-sort-by-over-sort.md) - Use sort_by Instead of sort with Block
- [`ds-array-preallocation`](references/ds-array-preallocation.md) - Preallocate Arrays When Size Is Known
- [`ds-hash-default-value`](references/ds-hash-default-value.md) - Use Hash Default Values Instead of Conditional Assignment

### 7. Concurrency (MEDIUM)

- [`conc-fiber-for-io`](references/conc-fiber-for-io.md) - Use Fibers for I/O-Bound Concurrency
- [`conc-thread-pool-sizing`](references/conc-thread-pool-sizing.md) - Size Thread Pools to Match Workload
- [`conc-ractor-cpu-bound`](references/conc-ractor-cpu-bound.md) - Use Ractors for CPU-Bound Parallelism
- [`conc-avoid-shared-mutable-state`](references/conc-avoid-shared-mutable-state.md) - Avoid Shared Mutable State Between Threads

### 8. Runtime & Configuration (LOW-MEDIUM)

- [`runtime-enable-yjit`](references/runtime-enable-yjit.md) - Enable YJIT for Production
- [`runtime-tune-gc-parameters`](references/runtime-tune-gc-parameters.md) - Tune GC Parameters for Your Workload
- [`runtime-frozen-string-literal-default`](references/runtime-frozen-string-literal-default.md) - Set Frozen String Literal as Project Default
- [`runtime-optimize-require`](references/runtime-optimize-require.md) - Optimize Require Load Order

## How to Use

Read individual reference files for detailed explanations and code examples:

- [Section definitions](references/_sections.md) - Category structure and impact levels
- [Rule template](assets/templates/_template.md) - Template for adding new rules

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and reference information |
