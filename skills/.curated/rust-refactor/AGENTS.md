# Rust

**Version 2.0.0**  
Community  
February 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Architectural refactoring guide for Rust applications. Contains 91 rules across 10 categories covering type safety, ownership, error handling, API design, project organization, module structure, naming conventions, conversions, idiomatic patterns, and iterators. Merged from rust-idioms and rust-systems skills.

---

## Table of Contents

1. [Type Safety & Patterns](references/_sections.md#1-type-safety-&-patterns) — **CRITICAL**
   - 1.1 [Derive Copy for Simple Enums](references/type-enum-copy-simple.md) — MEDIUM (Copy-able enums avoid unnecessary cloning and enable value semantics)
   - 1.2 [Encode Invariants in Newtype Constructors](references/type-newtype-invariants.md) — CRITICAL (enforces validity at type level, eliminates defensive checks)
   - 1.3 [Group Related Trait Implementations Together](references/type-trait-impl-grouping.md) — LOW (Grouped impls improve code navigation and review)
   - 1.4 [Implement Operator Traits for Domain Types](references/type-operator-overload.md) — MEDIUM (Operator overloading enables natural syntax for domain-specific arithmetic)
   - 1.5 [Replace Stringly-Typed APIs with Strong Types](references/type-strong-typing-strings.md) — CRITICAL (prevents argument confusion bugs at compile time)
   - 1.6 [Use Associated Types for Related Type Relationships](references/type-associated-types.md) — HIGH (Associated types simplify trait bounds and make APIs more ergonomic)
   - 1.7 [Use async_trait for Async Trait Methods](references/type-async-trait.md) — MEDIUM (async_trait enables async methods in traits until native support stabilizes)
   - 1.8 [Use bitflags! for Type-Safe Bit Flags](references/type-bitflags.md) — MEDIUM (bitflags! prevents integer flag mixing and enables set operations)
   - 1.9 [Use Box<dyn Trait> for Runtime Polymorphism](references/type-boxed-trait-objects.md) — MEDIUM (Trait objects enable runtime polymorphism when types aren't known at compile time)
   - 1.10 [Use Builder Pattern with Method Chaining](references/type-builder-pattern.md) — MEDIUM (Builders enable flexible construction while keeping structs immutable)
   - 1.11 [Use Consistent Derive Order for Data Structs](references/type-standard-derives.md) — MEDIUM (Consistent derive ordering improves code review and grep-ability)
   - 1.12 [Use Enums for Type-Safe Variants](references/type-enum-variants.md) — HIGH (Enum variants with data enable exhaustive matching and prevent invalid states)
   - 1.13 [Use Newtype Pattern for Unit Safety](references/type-newtype-units.md) — CRITICAL (prevents unit confusion bugs at compile time)
   - 1.14 [Use Non-Exhaustive for Extensible Enums](references/type-non-exhaustive-enums.md) — CRITICAL (enables adding variants without breaking downstream code)
   - 1.15 [Use Option<T> for Nullable Fields](references/type-option-nullable-fields.md) — HIGH (Option<T> enforces null-safety at compile time and prevents null pointer panics)
   - 1.16 [Use PhantomData for Type-Level State](references/type-phantom-data.md) — CRITICAL (encodes state machines in types, prevents invalid state transitions)
   - 1.17 [Use PhantomData for Unused Generic Parameters](references/type-phantom-unused-params.md) — MEDIUM (PhantomData maintains type relationships without runtime overhead)
   - 1.18 [Use Public Fields for Data Structs](references/type-public-fields.md) — MEDIUM (Public fields reduce boilerplate for pure data containers)
   - 1.19 [Use Type Aliases for Complex Generics](references/type-type-aliases.md) — LOW (Type aliases simplify signatures and improve readability)
   - 1.20 [Use Typestate Builders for Required Fields](references/type-builder-required-fields.md) — CRITICAL (prevents constructing incomplete objects at compile time)
2. [Ownership & Borrowing](references/_sections.md#2-ownership-&-borrowing) — **CRITICAL**
   - 2.1 [Accept Borrowed Types Over Owned References](references/own-accept-borrowed-types.md) — CRITICAL (2× input type flexibility with single function signature)
   - 2.2 [Avoid Unnecessary Clone Calls](references/own-avoid-unnecessary-clone.md) — CRITICAL (eliminates O(n) allocations in hot paths)
   - 2.3 [Leverage Lifetime Elision Rules](references/own-lifetime-elision.md) — CRITICAL (reduces noise in 87% of lifetime annotation cases)
   - 2.4 [Prefer Borrowing Over Ownership in Function Parameters](references/own-prefer-borrowing.md) — CRITICAL (reduces unnecessary clones, enables caller flexibility)
   - 2.5 [Return Owned Types for Caller Flexibility](references/own-return-owned-for-flexibility.md) — CRITICAL (eliminates forced clones when caller needs ownership)
   - 2.6 [Use Cow for Conditional Ownership](references/own-cow-conditional-clone.md) — CRITICAL (avoids clones when mutation is rare, zero-cost when borrowing)
3. [Error Handling](references/_sections.md#3-error-handling) — **HIGH**
   - 3.1 [Define Module-Local Result Type Alias](references/err-result-alias.md) — LOW (Result aliases reduce verbosity and make error types consistent)
   - 3.2 [Include Path Context in IO Errors](references/err-path-context.md) — HIGH (Path context in errors enables debugging without access to the running system)
   - 3.3 [Reserve panic! for Unrecoverable Situations](references/err-panic-unrecoverable.md) — HIGH (Panics terminate the program - use only when continuation is impossible)
   - 3.4 [Use #[source] for Error Chaining](references/err-source-attribute.md) — MEDIUM (Source attributes enable error chain traversal for debugging)
   - 3.5 [Use anyhow for Application Error Handling](references/err-anyhow-for-applications.md) — HIGH (reduces error handling boilerplate by 40%)
   - 3.6 [Use bail! for Validation Failures](references/err-bail-validation.md) — MEDIUM (bail! provides clean early exit for validation checks)
   - 3.7 [Use context() and with_context() for Error Messages](references/err-anyhow-context.md) — MEDIUM (Context methods add information without losing the original error chain)
   - 3.8 [Use expect() with Descriptive Messages](references/err-expect-message.md) — LOW (expect() documents why the unwrap should never fail)
   - 3.9 [Use Graceful Degradation for Non-Critical Operations](references/err-graceful-degradation.md) — MEDIUM (Logging errors instead of propagating keeps systems running when subsystems fail)
   - 3.10 [Use ok_or_else for Expensive Error Construction](references/err-ok-or-else.md) — LOW (Lazy evaluation prevents allocation when the Option is Some)
   - 3.11 [Use Option for Absence, Not Sentinel Values](references/err-option-for-absence.md) — HIGH (eliminates null-related bugs, makes absence explicit)
   - 3.12 [Use Result Instead of panic! for Recoverable Errors](references/err-use-result-not-panic.md) — HIGH (enables graceful error handling, prevents crashes)
   - 3.13 [Use the Question Mark Operator for Error Propagation](references/err-question-mark-propagation.md) — HIGH (reduces error handling boilerplate by 60%)
   - 3.14 [Use thiserror for Custom Error Types](references/err-thiserror-enum.md) — HIGH (thiserror provides automatic Error trait implementation with minimal boilerplate)
   - 3.15 [Use Two-Tier Error Strategy](references/err-two-tier-strategy.md) — HIGH (Separating library and application errors enables both precision and convenience)
4. [API Design & Traits](references/_sections.md#4-api-design-&-traits) — **HIGH**
   - 4.1 [Derive Common Traits for Public Types](references/api-derive-common-traits.md) — HIGH (enables standard library integration, improves debugging)
   - 4.2 [Implement Standard Traits for Ergonomic APIs](references/api-impl-standard-traits.md) — HIGH (enables idiomatic usage patterns, integrates with ecosystem)
   - 4.3 [Use Builder Pattern for Complex Construction](references/api-builder-pattern.md) — HIGH (enables optional parameters without function overloading)
   - 4.4 [Use Extension Traits to Add Methods to Foreign Types](references/api-extension-traits.md) — HIGH (adds functionality without wrapping, maintains ergonomic API)
   - 4.5 [Use Sealed Traits to Prevent External Implementation](references/api-sealed-traits.md) — HIGH (enables future API evolution without breaking changes)
   - 4.6 [Use Trait Bounds for Generic Flexibility](references/api-generic-bounds.md) — HIGH (10× code reuse through single generic implementation)
5. [Project Organization](references/_sections.md#5-project-organization) — **HIGH**
   - 5.1 [Group Crates by Feature Domain](references/org-feature-domain-grouping.md) — MEDIUM (Domain-based organization creates natural boundaries and improves code discoverability)
   - 5.2 [Keep Crate Structure Flat](references/org-flat-crate-structure.md) — MEDIUM (Flat structures reduce cognitive overhead and make files easy to locate)
   - 5.3 [Separate Binary and Library Crates](references/org-binary-library-separation.md) — HIGH (Enables code reuse, cleaner dependencies, and testable library code)
   - 5.4 [Use Cargo Workspace for Multi-Crate Projects](references/org-cargo-workspace.md) — HIGH (Enables independent compilation, clear crate boundaries, and faster incremental builds)
   - 5.5 [Use Dedicated Common Crate for Shared Utilities](references/org-common-crate.md) — MEDIUM (Centralizes shared code, prevents duplication, and avoids scattered utils directories)
   - 5.6 [Use snake_case for All Directory Names](references/org-directory-naming.md) — HIGH (Consistent naming prevents module resolution issues and follows Rust ecosystem conventions)
6. [Module & Visibility](references/_sections.md#6-module-&-visibility) — **MEDIUM-HIGH**
   - 6.1 [Co-locate Tests as test.rs Files](references/mod-colocated-tests.md) — HIGH (Co-located tests are easier to maintain and update alongside the code they test)
   - 6.2 [Minimize Public API Surface](references/mod-minimize-pub-api.md) — MEDIUM-HIGH (enables internal refactoring without breaking changes)
   - 6.3 [Separate Types and Errors into Dedicated Files](references/mod-types-errors-files.md) — MEDIUM (Dedicated files for types and errors improve discoverability and enable focused reviews)
   - 6.4 [Split Large Modules into Submodules](references/mod-split-large-modules.md) — MEDIUM-HIGH (improves navigation, enables parallel compilation)
   - 6.5 [Use cfg Attributes for Conditional Modules](references/mod-conditional-compilation.md) — MEDIUM (Conditional compilation enables platform-specific code and optional features cleanly)
   - 6.6 [Use crate Prefix for Internal Imports](references/mod-crate-prefix-imports.md) — MEDIUM-HIGH (reduces import churn by 50% during refactors)
   - 6.7 [Use Explicit Module Declarations in lib.rs](references/mod-explicit-declarations.md) — HIGH (Explicit declarations make module structure visible and prevent accidental public exposure)
   - 6.8 [Use pub use for Clean Module Re-exports](references/mod-pub-use-reexports.md) — MEDIUM-HIGH (reduces import paths by 2-3 segments)
   - 6.9 [Use tests Submodule for Unit Tests](references/mod-tests-submodule.md) — MEDIUM-HIGH (enables private function testing, zero runtime overhead)
7. [Naming Conventions](references/_sections.md#7-naming-conventions) — **MEDIUM-HIGH**
   - 7.1 [Include Unit Suffixes in Field Names](references/name-field-unit-suffixes.md) — LOW (Unit suffixes prevent unit confusion bugs and make code self-documenting)
   - 7.2 [Name Test Files as test.rs](references/name-test-files.md) — LOW (Consistent test file naming makes test location predictable)
   - 7.3 [Prefix Getter Functions with get_](references/name-getter-prefix.md) — MEDIUM (Consistent prefixes make API predictable and self-documenting)
   - 7.4 [Use Descriptive or Single-Letter Generic Parameters](references/name-generic-parameters.md) — LOW (Appropriate generic naming balances readability with convention)
   - 7.5 [Use Descriptive Suffixes for Type Specialization](references/name-type-suffixes.md) — MEDIUM (Semantic suffixes communicate type purpose without reading implementation)
   - 7.6 [Use is_, has_, should_ for Boolean Predicates](references/name-boolean-predicates.md) — MEDIUM (Question-like prefixes make boolean return types self-evident)
   - 7.7 [Use new for Constructors](references/name-constructor-new.md) — HIGH (Consistent constructor naming follows Rust conventions and IDE expectations)
   - 7.8 [Use PascalCase for Types](references/name-type-pascal-case.md) — HIGH (Consistent with Rust RFC 430 and visually distinguishes types from values)
   - 7.9 [Use SCREAMING_SNAKE_CASE for Constants](references/name-constant-screaming.md) — MEDIUM (Visual distinction for immutable values helps identify compile-time constants)
   - 7.10 [Use Single Lowercase Letters for Lifetimes](references/name-lifetime-parameters.md) — LOW (Consistent lifetime naming follows Rust conventions)
   - 7.11 [Use snake_case for Functions and Methods](references/name-function-snake-case.md) — HIGH (Consistent with Rust RFC 430 and enables automatic lint warnings for violations)
   - 7.12 [Use snake_case for Module Names](references/name-module-snake-case.md) — HIGH (Module naming must match Rust's module resolution rules)
   - 7.13 [Use to_ and from_ for Conversions](references/name-conversion-to-from.md) — MEDIUM (Conversion prefixes indicate data flow direction and transformation semantics)
8. [Conversion Traits](references/_sections.md#8-conversion-traits) — **MEDIUM**
   - 8.1 [Accept AsRef for Flexible String Parameters](references/conv-asref-for-flexibility.md) — MEDIUM (accepts String, &str, PathBuf, &Path with single signature)
   - 8.2 [Implement Deref for Transparent Newtype Access](references/conv-impl-deref-for-newtypes.md) — MEDIUM (enables calling inner type methods without explicit unwrapping)
   - 8.3 [Implement From Instead of Into](references/conv-impl-from-not-into.md) — MEDIUM (50% less code, automatic Into via blanket implementation)
   - 8.4 [Use Inner Function Pattern to Reduce Monomorphization](references/conv-inner-function-pattern.md) — MEDIUM (reduces code bloat from generic functions)
   - 8.5 [Use TryFrom for Fallible Conversions](references/conv-tryfrom-for-fallible.md) — MEDIUM (prevents panic on invalid input, enables graceful handling)
9. [Idiomatic Patterns](references/_sections.md#9-idiomatic-patterns) — **MEDIUM**
   - 9.1 [Follow Constructor Naming Conventions](references/idiom-constructor-naming.md) — MEDIUM (reduces API learning curve, enables IDE autocomplete discovery)
   - 9.2 [Implement Default Instead of new() Without Arguments](references/idiom-default-trait.md) — MEDIUM (enables derive(Default) propagation, reduces manual initialization)
   - 9.3 [Use Destructuring for Multiple Returns and Field Access](references/idiom-destructuring-assignment.md) — MEDIUM (reduces temporary variables, makes intent clear)
   - 9.4 [Use let-else for Early Returns on Pattern Match Failure](references/idiom-let-else.md) — MEDIUM (reduces nesting, makes happy path clear)
   - 9.5 [Use Match Guards for Complex Conditions](references/idiom-match-guards.md) — MEDIUM (reduces nesting depth by 2-3 levels)
   - 9.6 [Use Struct Update Syntax for Partial Overrides](references/idiom-struct-update-syntax.md) — MEDIUM (reduces boilerplate when creating variants of structs)
10. [Iterator & Collections](references/_sections.md#10-iterator-&-collections) — **LOW-MEDIUM**
   - 10.1 [Avoid Collecting Then Iterating](references/iter-avoid-collect-then-iterate.md) — LOW-MEDIUM (eliminates intermediate allocation, enables lazy evaluation)
   - 10.2 [Prefer Iterator Methods Over Manual Loops](references/iter-prefer-iterators-over-loops.md) — LOW-MEDIUM (reduces boilerplate, enables compiler optimizations)
   - 10.3 [Use enumerate Instead of Manual Index Tracking](references/iter-enumerate-for-indices.md) — LOW-MEDIUM (eliminates off-by-one errors, clearer intent)
   - 10.4 [Use filter_map for Combined Filter and Transform](references/iter-filter-map-combined.md) — LOW-MEDIUM (reduces iterator chain length, clearer intent)
   - 10.5 [Use Turbofish for Explicit collect Type](references/iter-use-collect-turbofish.md) — LOW-MEDIUM (makes collection type explicit, avoids type inference errors)

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