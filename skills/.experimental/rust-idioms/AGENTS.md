# Rust

**Version 0.1.0**  
Rust Community  
January 2026

> **Note:**
> This document is mainly for agents and LLMs to follow when maintaining,
> generating, or refactoring Rust codebases. Humans may also find it useful,
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive refactoring guidelines for Rust applications, designed for AI agents and LLMs. Contains 44 rules across 8 categories, prioritized by impact from critical (type safety, ownership patterns) to incremental (iterator idioms). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide automated refactoring and code generation.

---

## Table of Contents

1. [Type Safety & Newtype Patterns](references/_sections.md#1-type-safety-&-newtype-patterns) — **CRITICAL**
   - 1.1 [Encode Invariants in Newtype Constructors](references/type-newtype-invariants.md) — CRITICAL (enforces validity at type level, eliminates defensive checks)
   - 1.2 [Replace Stringly-Typed APIs with Strong Types](references/type-strong-typing-strings.md) — CRITICAL (prevents argument confusion bugs at compile time)
   - 1.3 [Use Newtype Pattern for Unit Safety](references/type-newtype-units.md) — CRITICAL (prevents unit confusion bugs at compile time)
   - 1.4 [Use Non-Exhaustive for Extensible Enums](references/type-non-exhaustive-enums.md) — CRITICAL (enables adding variants without breaking downstream code)
   - 1.5 [Use PhantomData for Type-Level State](references/type-phantom-data.md) — CRITICAL (encodes state machines in types, prevents invalid state transitions)
   - 1.6 [Use Typestate Builders for Required Fields](references/type-builder-required-fields.md) — CRITICAL (prevents constructing incomplete objects at compile time)
2. [Ownership & Borrowing](references/_sections.md#2-ownership-&-borrowing) — **CRITICAL**
   - 2.1 [Accept Borrowed Types Over Owned References](references/own-accept-borrowed-types.md) — CRITICAL (2× input type flexibility with single function signature)
   - 2.2 [Avoid Unnecessary Clone Calls](references/own-avoid-unnecessary-clone.md) — CRITICAL (eliminates O(n) allocations in hot paths)
   - 2.3 [Leverage Lifetime Elision Rules](references/own-lifetime-elision.md) — CRITICAL (reduces noise in 87% of lifetime annotation cases)
   - 2.4 [Prefer Borrowing Over Ownership in Function Parameters](references/own-prefer-borrowing.md) — CRITICAL (reduces unnecessary clones, enables caller flexibility)
   - 2.5 [Return Owned Types for Caller Flexibility](references/own-return-owned-for-flexibility.md) — CRITICAL (eliminates forced clones when caller needs ownership)
   - 2.6 [Use Cow for Conditional Ownership](references/own-cow-conditional-clone.md) — CRITICAL (avoids clones when mutation is rare, zero-cost when borrowing)
3. [Error Handling Patterns](references/_sections.md#3-error-handling-patterns) — **HIGH**
   - 3.1 [Use anyhow for Application Error Handling](references/err-anyhow-for-applications.md) — HIGH (reduces error handling boilerplate by 40%)
   - 3.2 [Use Option for Absence, Not Sentinel Values](references/err-option-for-absence.md) — HIGH (eliminates null-related bugs, makes absence explicit)
   - 3.3 [Use Result Instead of panic! for Recoverable Errors](references/err-use-result-not-panic.md) — HIGH (enables graceful error handling, prevents crashes)
   - 3.4 [Use the Question Mark Operator for Error Propagation](references/err-question-mark-propagation.md) — HIGH (reduces error handling boilerplate by 60%)
   - 3.5 [Use thiserror for Library Error Types](references/err-thiserror-for-libraries.md) — HIGH (reduces boilerplate, provides ergonomic error types for consumers)
4. [API Design & Traits](references/_sections.md#4-api-design-&-traits) — **HIGH**
   - 4.1 [Derive Common Traits for Public Types](references/api-derive-common-traits.md) — HIGH (enables standard library integration, improves debugging)
   - 4.2 [Implement Standard Traits for Ergonomic APIs](references/api-impl-standard-traits.md) — HIGH (enables idiomatic usage patterns, integrates with ecosystem)
   - 4.3 [Use Builder Pattern for Complex Construction](references/api-builder-pattern.md) — HIGH (enables optional parameters without function overloading)
   - 4.4 [Use Extension Traits to Add Methods to Foreign Types](references/api-extension-traits.md) — HIGH (adds functionality without wrapping, maintains ergonomic API)
   - 4.5 [Use Sealed Traits to Prevent External Implementation](references/api-sealed-traits.md) — HIGH (enables future API evolution without breaking changes)
   - 4.6 [Use Trait Bounds for Generic Flexibility](references/api-generic-bounds.md) — HIGH (10× code reuse through single generic implementation)
5. [Module & Visibility](references/_sections.md#5-module-&-visibility) — **MEDIUM-HIGH**
   - 5.1 [Minimize Public API Surface](references/mod-minimize-pub-api.md) — MEDIUM-HIGH (enables internal refactoring without breaking changes)
   - 5.2 [Split Large Modules into Submodules](references/mod-split-large-modules.md) — MEDIUM-HIGH (improves navigation, enables parallel compilation)
   - 5.3 [Use crate Prefix for Internal Imports](references/mod-crate-prefix-imports.md) — MEDIUM-HIGH (reduces import churn by 50% during refactors)
   - 5.4 [Use pub use for Clean Module Re-exports](references/mod-pub-use-reexports.md) — MEDIUM-HIGH (reduces import paths by 2-3 segments)
   - 5.5 [Use tests Submodule for Unit Tests](references/mod-tests-submodule.md) — MEDIUM-HIGH (enables private function testing, zero runtime overhead)
6. [Conversion Traits](references/_sections.md#6-conversion-traits) — **MEDIUM**
   - 6.1 [Accept AsRef for Flexible String Parameters](references/conv-asref-for-flexibility.md) — MEDIUM (accepts String, &str, PathBuf, &Path with single signature)
   - 6.2 [Implement Deref for Transparent Newtype Access](references/conv-impl-deref-for-newtypes.md) — MEDIUM (enables calling inner type methods without explicit unwrapping)
   - 6.3 [Implement From Instead of Into](references/conv-impl-from-not-into.md) — MEDIUM (50% less code, automatic Into via blanket implementation)
   - 6.4 [Use Inner Function Pattern to Reduce Monomorphization](references/conv-inner-function-pattern.md) — MEDIUM (reduces code bloat from generic functions)
   - 6.5 [Use TryFrom for Fallible Conversions](references/conv-tryfrom-for-fallible.md) — MEDIUM (prevents panic on invalid input, enables graceful handling)
7. [Idiomatic Patterns](references/_sections.md#7-idiomatic-patterns) — **MEDIUM**
   - 7.1 [Follow Constructor Naming Conventions](references/idiom-constructor-naming.md) — MEDIUM (reduces API learning curve, enables IDE autocomplete discovery)
   - 7.2 [Implement Default Instead of new() Without Arguments](references/idiom-default-trait.md) — MEDIUM (enables derive(Default) propagation, reduces manual initialization)
   - 7.3 [Use Destructuring for Multiple Returns and Field Access](references/idiom-destructuring-assignment.md) — MEDIUM (reduces temporary variables, makes intent clear)
   - 7.4 [Use let-else for Early Returns on Pattern Match Failure](references/idiom-let-else.md) — MEDIUM (reduces nesting, makes happy path clear)
   - 7.5 [Use Match Guards for Complex Conditions](references/idiom-match-guards.md) — MEDIUM (reduces nesting depth by 2-3 levels)
   - 7.6 [Use Struct Update Syntax for Partial Overrides](references/idiom-struct-update-syntax.md) — MEDIUM (reduces boilerplate when creating variants of structs)
8. [Iterator & Collections](references/_sections.md#8-iterator-&-collections) — **LOW-MEDIUM**
   - 8.1 [Avoid Collecting Then Iterating](references/iter-avoid-collect-then-iterate.md) — LOW-MEDIUM (eliminates intermediate allocation, enables lazy evaluation)
   - 8.2 [Prefer Iterator Methods Over Manual Loops](references/iter-prefer-iterators-over-loops.md) — LOW-MEDIUM (reduces boilerplate, enables compiler optimizations)
   - 8.3 [Use enumerate Instead of Manual Index Tracking](references/iter-enumerate-for-indices.md) — LOW-MEDIUM (eliminates off-by-one errors, clearer intent)
   - 8.4 [Use filter_map for Combined Filter and Transform](references/iter-filter-map-combined.md) — LOW-MEDIUM (reduces iterator chain length, clearer intent)
   - 8.5 [Use Turbofish for Explicit collect Type](references/iter-use-collect-turbofish.md) — LOW-MEDIUM (makes collection type explicit, avoids type inference errors)

---

## References

1. [https://rust-lang.github.io/api-guidelines/](https://rust-lang.github.io/api-guidelines/)
2. [https://rust-unofficial.github.io/patterns/](https://rust-unofficial.github.io/patterns/)
3. [https://doc.rust-lang.org/book/](https://doc.rust-lang.org/book/)
4. [https://www.lurklurk.org/effective-rust/](https://www.lurklurk.org/effective-rust/)
5. [https://rust-lang.github.io/rust-clippy/](https://rust-lang.github.io/rust-clippy/)
6. [https://doc.rust-lang.org/reference/lifetime-elision.html](https://doc.rust-lang.org/reference/lifetime-elision.html)
7. [https://doc.rust-lang.org/nomicon/](https://doc.rust-lang.org/nomicon/)
8. [https://refactoring.guru/design-patterns/rust](https://refactoring.guru/design-patterns/rust)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |