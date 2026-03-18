---
name: rust-idiomatic
description: Comprehensive idiomatic Rust patterns covering ownership, borrowing, error handling, async, type safety, collections, API design, serialization, and performance with 41 rules across 8 categories
---

# Rust Community Idiomatic Rust Best Practices

A structured guide to writing idiomatic Rust code based on patterns established by top contributors. Each rule includes incorrect/correct examples with realistic domain names and quantified impact metrics.

## When to Apply

- Writing new Rust code in any project or crate
- Reviewing pull requests for idiomatic patterns
- Refactoring code that uses excessive cloning, manual loops, or opaque error handling
- Designing public APIs for libraries or shared modules
- Optimizing async code for correctness and cancellation safety

## Rule Categories by Priority

| # | Category | Prefix | Impact | Rules |
|---|----------|--------|--------|-------|
| 1 | Ownership and Borrowing | own- | CRITICAL | 6 |
| 2 | Error Propagation | errprop- | CRITICAL | 6 |
| 3 | Type Safety | safe- | HIGH | 6 |
| 4 | Collections and Iterators | iter- | HIGH | 5 |
| 5 | Async Patterns | asyncp- | MEDIUM-HIGH | 5 |
| 6 | API Design | api- | MEDIUM | 5 |
| 7 | Serialization | serial- | MEDIUM | 4 |
| 8 | Performance | perf- | LOW-MEDIUM | 4 |
| | **Total** | | | **41** |

## Quick Reference

### Ownership and Borrowing (CRITICAL)
- `own-borrow-over-clone` - Borrow references instead of cloning
- `own-cow-conditional` - Use Cow for conditional ownership
- `own-arc-shared-state` - Use Arc for shared async state
- `own-avoid-unnecessary-clone` - Avoid unnecessary clone in closures
- `own-move-closures-spawn` - Use move closures for tokio spawn
- `own-into-conversions` - Use Into conversions for ergonomic APIs

### Error Propagation (CRITICAL)
- `errprop-question-mark` - Use the question mark operator for error propagation
- `errprop-context-annotations` - Add context to every fallible operation
- `errprop-custom-error-types` - Define custom error types for domain boundaries
- `errprop-anyhow-applications` - Use anyhow for application-level error handling
- `errprop-thiserror-libraries` - Use thiserror for library error definitions
- `errprop-boundary-conversion` - Convert errors at module boundaries

### Type Safety (HIGH)
- `safe-newtype-identifiers` - Use newtype pattern for type-safe identifiers
- `safe-enum-state-machines` - Use enums to represent state machines
- `safe-builder-construction` - Use builder pattern for complex object construction
- `safe-from-into-traits` - Implement From and Into for type conversions
- `safe-non-exhaustive` - Use non_exhaustive on public enums
- `safe-phantom-data` - Use PhantomData for type-level constraints

### Collections and Iterators (HIGH)
- `iter-btreemap-determinism` - Use BTreeMap for deterministic iteration
- `iter-method-references` - Use method references over closures
- `iter-collect-turbofish` - Use turbofish on collect for clarity
- `iter-chain-over-loops` - Prefer iterator chaining over manual loops
- `iter-filter-map` - Use filter_map instead of filter then map

### Async Patterns (MEDIUM-HIGH)
- `asyncp-tokio-select` - Use tokio select for concurrent branch waiting
- `asyncp-pin-box-futures` - Pin boxed futures to reduce async stack size
- `asyncp-cancellation-safety` - Design for cancellation safety in async code
- `asyncp-send-bounds` - Ensure futures are Send for multi-threaded runtimes
- `asyncp-structured-concurrency` - Use JoinSet for structured concurrency

### API Design (MEDIUM)
- `api-accept-asref` - Accept impl AsRef for flexible string parameters
- `api-return-impl-iterator` - Return impl Iterator over collected Vec
- `api-derive-default` - Derive Default for configuration structs
- `api-display-user-facing` - Implement Display for user-facing types
- `api-sealed-traits` - Use sealed traits for extension prevention

### Serialization (MEDIUM)
- `serial-rename-all` - Use rename_all for consistent wire format
- `serial-deny-unknown` - Use deny_unknown_fields for strict deserialization
- `serial-default-values` - Use serde default for backward compatibility
- `serial-flatten-composition` - Use serde flatten for struct composition

### Performance (LOW-MEDIUM)
- `perf-preallocate-capacity` - Pre-allocate Vec and String capacity
- `perf-cow-avoid-alloc` - Use Cow to avoid unnecessary allocations
- `perf-arc-str` - Use Arc str over Arc String for shared strings
- `perf-lazy-lock` - Use LazyLock for thread-safe lazy initialization

## How to Use

1. **Before writing code**: Review the CRITICAL rules (Ownership, Error Propagation) as they prevent the most impactful bugs and performance issues.
2. **During implementation**: Follow Type Safety and Collections rules to leverage the compiler as a correctness tool.
3. **When designing APIs**: Apply API Design and Serialization rules to create ergonomic, evolution-safe interfaces.
4. **When optimizing**: Use Performance rules for targeted improvements in measured hot paths.

## Reference Files

| File | Description |
|------|-------------|
| `references/_sections.md` | Section definitions and ordering |
| `references/own-*.md` | Ownership and borrowing rules (6 files) |
| `references/errprop-*.md` | Error propagation rules (6 files) |
| `references/safe-*.md` | Type safety rules (6 files) |
| `references/iter-*.md` | Collections and iterators rules (5 files) |
| `references/asyncp-*.md` | Async patterns rules (5 files) |
| `references/api-*.md` | API design rules (5 files) |
| `references/serial-*.md` | Serialization rules (4 files) |
| `references/perf-*.md` | Performance rules (4 files) |
