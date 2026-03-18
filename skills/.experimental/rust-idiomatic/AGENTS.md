# Idiomatic Rust

**Version 1.0.0**  
Rust Community  
March 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive guide to idiomatic Rust patterns from top contributors, designed for AI agents and LLMs. Contains 41 rules across 8 categories covering ownership and borrowing, error propagation, type safety, collections and iterators, async patterns, API design, serialization, and performance. Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated code generation.

---

## Table of Contents

1. [Ownership and Borrowing](references/_sections.md#1-ownership-and-borrowing) — **CRITICAL**
   - 1.1 [Avoid Unnecessary Clone in Closures](references/own-avoid-unnecessary-clone.md) — CRITICAL (eliminates N allocations per loop iteration in hot paths)
   - 1.2 [Borrow References Instead of Cloning](references/own-borrow-over-clone.md) — CRITICAL (2-10x less memory pressure in data-heavy paths)
   - 1.3 [Use Arc for Shared Async State](references/own-arc-shared-state.md) — CRITICAL (enables safe shared ownership across spawned tasks)
   - 1.4 [Use Cow for Conditional Ownership](references/own-cow-conditional.md) — CRITICAL (avoids allocation when borrowed data suffices)
   - 1.5 [Use Into Conversions for Ergonomic APIs](references/own-into-conversions.md) — CRITICAL (reduces callsite verbosity, accepts both &str and String)
   - 1.6 [Use move Closures for tokio spawn](references/own-move-closures-spawn.md) — CRITICAL (prevents lifetime errors in spawned async tasks)
2. [Error Propagation](references/_sections.md#2-error-propagation) — **CRITICAL**
   - 2.1 [Add context to Every Fallible Operation](references/errprop-context-annotations.md) — CRITICAL (saves 5-30min per debug session with actionable error messages)
   - 2.2 [Convert Errors at Module Boundaries](references/errprop-boundary-conversion.md) — CRITICAL (isolates error domains, prevents leaking internal types)
   - 2.3 [Define Custom Error Types for Domain Boundaries](references/errprop-custom-error-types.md) — CRITICAL (enables exhaustive error matching and typed recovery logic)
   - 2.4 [Use anyhow for Application-Level Error Handling](references/errprop-anyhow-applications.md) — CRITICAL (reduces error boilerplate by 50-70% in application code)
   - 2.5 [Use the Question Mark Operator for Error Propagation](references/errprop-question-mark.md) — CRITICAL (eliminates boilerplate match arms, 60-80% fewer error-handling lines)
   - 2.6 [Use thiserror for Library Error Definitions](references/errprop-thiserror-libraries.md) — CRITICAL (2-3x less boilerplate per error enum)
3. [Type Safety](references/_sections.md#3-type-safety) — **HIGH**
   - 3.1 [Implement From and Into for Type Conversions](references/safe-from-into-traits.md) — HIGH (enables automatic conversion with ? operator and .into())
   - 3.2 [Use Builder Pattern for Complex Object Construction](references/safe-builder-construction.md) — HIGH (eliminates constructor parameter confusion, self-documenting callsites)
   - 3.3 [Use Enums to Represent State Machines](references/safe-enum-state-machines.md) — HIGH (eliminates invalid state combinations at compile time)
   - 3.4 [Use Newtype Pattern for Type-Safe Identifiers](references/safe-newtype-identifiers.md) — HIGH (eliminates identifier confusion bugs at compile time)
   - 3.5 [Use non_exhaustive on Public Enums](references/safe-non-exhaustive.md) — HIGH (enables adding variants without breaking downstream crates)
   - 3.6 [Use PhantomData for Type-Level Constraints](references/safe-phantom-data.md) — HIGH (O(0) runtime overhead, prevents misuse at compile time)
4. [Collections and Iterators](references/_sections.md#4-collections-and-iterators) — **HIGH**
   - 4.1 [Prefer Iterator Chaining Over Manual Loops](references/iter-chain-over-loops.md) — HIGH (30-50% fewer lines, enables compiler auto-vectorization)
   - 4.2 [Use BTreeMap for Deterministic Iteration](references/iter-btreemap-determinism.md) — HIGH (eliminates nondeterministic serialization and flaky test failures)
   - 4.3 [Use filter_map Instead of filter Then map](references/iter-filter-map.md) — HIGH (single pass instead of two, handles Option unwrapping cleanly)
   - 4.4 [Use Method References Over Closures](references/iter-method-references.md) — HIGH (reduces visual noise, Clippy lint redundant_closure_for_method_calls)
   - 4.5 [Use Turbofish on collect for Clarity](references/iter-collect-turbofish.md) — HIGH (eliminates type inference ambiguity, makes target collection explicit)
5. [Async Patterns](references/_sections.md#5-async-patterns) — **MEDIUM-HIGH**
   - 5.1 [Design for Cancellation Safety in Async Code](references/asyncp-cancellation-safety.md) — MEDIUM-HIGH (prevents resource leaks and partial state corruption on cancel)
   - 5.2 [Ensure Futures Are Send for Multi-Threaded Runtimes](references/asyncp-send-bounds.md) — MEDIUM-HIGH (required for tokio::spawn, prevents runtime panics)
   - 5.3 [Pin Boxed Futures to Reduce Async Stack Size](references/asyncp-pin-box-futures.md) — MEDIUM-HIGH (prevents stack overflows in deeply nested async call chains)
   - 5.4 [Use JoinSet for Structured Concurrency](references/asyncp-structured-concurrency.md) — MEDIUM-HIGH (automatic cleanup of spawned tasks, prevents orphaned futures)
   - 5.5 [Use tokio select for Concurrent Branch Waiting](references/asyncp-tokio-select.md) — MEDIUM-HIGH (enables responsive cancellation and timeout handling)
6. [API Design](references/_sections.md#6-api-design) — **MEDIUM**
   - 6.1 [Accept impl AsRef for Flexible String Parameters](references/api-accept-asref.md) — MEDIUM (3-5x fewer conversion calls at callsites)
   - 6.2 [Derive Default for Configuration Structs](references/api-derive-default.md) — MEDIUM (enables struct update syntax, simplifies test setup)
   - 6.3 [Implement Display for User-Facing Types](references/api-display-user-facing.md) — MEDIUM (enables format!, println!, and .to_string() for error messages and logs)
   - 6.4 [Return impl Iterator Over Collected Vec](references/api-return-impl-iterator.md) — MEDIUM (avoids intermediate allocation, enables lazy evaluation)
   - 6.5 [Use Sealed Traits for Extension Prevention](references/api-sealed-traits.md) — MEDIUM (prevents downstream crates from implementing internal traits)
7. [Serialization](references/_sections.md#7-serialization) — **MEDIUM**
   - 7.1 [Use deny_unknown_fields for Strict Deserialization](references/serial-deny-unknown.md) — MEDIUM (catches 100% of field typos at parse time vs silent data loss)
   - 7.2 [Use rename_all for Consistent Wire Format](references/serial-rename-all.md) — MEDIUM (eliminates field-by-field rename annotations, enforces naming convention)
   - 7.3 [Use serde default for Backward Compatibility](references/serial-default-values.md) — MEDIUM (enables adding new fields without breaking existing serialized data)
   - 7.4 [Use serde flatten for Struct Composition](references/serial-flatten-composition.md) — MEDIUM (enables composable config types without nesting in wire format)
8. [Performance](references/_sections.md#8-performance) — **LOW-MEDIUM**
   - 8.1 [Preallocate Vec and String Capacity](references/perf-preallocate-capacity.md) — LOW-MEDIUM (eliminates 2-4 reallocations per collection, reduces allocator pressure)
   - 8.2 [Use Arc str Over Arc String for Shared Strings](references/perf-arc-str.md) — LOW-MEDIUM (saves 24 bytes per shared string, one fewer indirection)
   - 8.3 [Use Cow to Avoid Unnecessary Allocations](references/perf-cow-avoid-alloc.md) — LOW-MEDIUM (0 allocations on 90%+ of calls vs 1 allocation per call)
   - 8.4 [Use LazyLock for Thread-Safe Lazy Initialization](references/perf-lazy-lock.md) — LOW-MEDIUM (O(1) amortized access after one-time initialization)

---

## References

1. [https://doc.rust-lang.org/book/](https://doc.rust-lang.org/book/)
2. [https://rust-lang.github.io/rust-clippy/master/index.html](https://rust-lang.github.io/rust-clippy/master/index.html)
3. [https://rust-lang.github.io/api-guidelines/](https://rust-lang.github.io/api-guidelines/)
4. [https://doc.rust-lang.org/std/borrow/enum.Cow.html](https://doc.rust-lang.org/std/borrow/enum.Cow.html)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |