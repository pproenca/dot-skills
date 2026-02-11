---
name: rust-refactor
description: Architectural refactoring guide for Rust applications covering type safety, ownership patterns, error handling strategies, API design, project organization, module structure, naming conventions, conversion traits, and idiomatic patterns. Use when refactoring Rust codebases, reviewing PRs for architectural issues, improving type safety, designing error handling strategies, or organizing project structure. Complements the rust-optimise skill (performance patterns). Does NOT cover performance optimization, memory allocation, or async concurrency tuning (see rust-optimise skill).
---

# Rust Refactor Best Practices

Architectural refactoring guide for Rust applications. Contains 91 rules across 10 categories, prioritized by impact from critical (type safety, ownership) to incremental (iterator idioms).

## When to Apply

- Refactoring existing Rust codebases or planning large-scale restructuring
- Reviewing PRs for architectural issues and code smells
- Designing type-safe APIs with proper error handling
- Organizing Rust project structure with Cargo workspaces
- Improving module boundaries and visibility control
- Applying consistent naming conventions (RFC 430)
- Replacing stringly-typed APIs with strong types

## Rule Categories

| Category | Impact | Rules | Key Topics |
|----------|--------|-------|------------|
| Type Safety & Patterns | CRITICAL | 20 | Newtypes, typestate builders, PhantomData, enums, trait objects, associated types |
| Ownership & Borrowing | CRITICAL | 6 | Borrowing, Cow, lifetime elision, clone avoidance |
| Error Handling | HIGH | 15 | thiserror/anyhow, two-tier strategy, context, graceful degradation |
| API Design & Traits | HIGH | 6 | Sealed traits, extension traits, generic bounds, builder pattern |
| Project Organization | HIGH | 6 | Cargo workspaces, crate separation, feature grouping |
| Module & Visibility | MEDIUM-HIGH | 9 | Re-exports, visibility control, test co-location, module splitting |
| Naming Conventions | MEDIUM-HIGH | 13 | RFC 430, snake_case, PascalCase, predicates, unit suffixes |
| Conversion Traits | MEDIUM | 5 | From/Into, AsRef, TryFrom, Deref |
| Idiomatic Patterns | MEDIUM | 6 | Default, let-else, destructuring, match guards |
| Iterator & Collections | LOW-MEDIUM | 5 | Iterator methods, collect turbofish, filter_map |

## Quick Reference

**Critical patterns** — get these right first:
- Use newtype patterns to prevent unit confusion and encode invariants
- Prefer borrowing over ownership in function parameters
- Use thiserror for library errors, anyhow for application errors
- Use typestate builders for compile-time required field enforcement

**Common mistakes** — avoid these anti-patterns:
- Stringly-typed APIs instead of strong types
- Unnecessary clone calls when borrowing would work
- panic! for recoverable errors instead of Result
- Over-exposing internal types with pub visibility

## Table of Contents

1. [Type Safety & Patterns](references/_sections.md#1-type-safety--patterns) — **CRITICAL**
   - 1.1 [Encode Invariants in Newtype Constructors](references/type-newtype-invariants.md) — CRITICAL
   - 1.2 [Use Newtype Pattern for Unit Safety](references/type-newtype-units.md) — CRITICAL
   - 1.3 [Replace Stringly-Typed APIs with Strong Types](references/type-strong-typing-strings.md) — CRITICAL
   - 1.4 [Use Non-Exhaustive for Extensible Enums](references/type-non-exhaustive-enums.md) — CRITICAL
   - 1.5 [Use PhantomData for Type-Level State](references/type-phantom-data.md) — CRITICAL
   - 1.6 [Use Typestate Builders for Required Fields](references/type-builder-required-fields.md) — CRITICAL
   - 1.7 [Use Associated Types for Related Type Relationships](references/type-associated-types.md) — HIGH
   - 1.8 [Use Enums for Type-Safe Variants](references/type-enum-variants.md) — HIGH
   - 1.9 [Use Option&lt;T&gt; for Nullable Fields](references/type-option-nullable-fields.md) — HIGH
   - 1.10 [Use async_trait for Async Trait Methods](references/type-async-trait.md) — MEDIUM
   - 1.11 [Use bitflags! for Type-Safe Bit Flags](references/type-bitflags.md) — MEDIUM
   - 1.12 [Use Box&lt;dyn Trait&gt; for Runtime Polymorphism](references/type-boxed-trait-objects.md) — MEDIUM
   - 1.13 [Use Builder Pattern with Method Chaining](references/type-builder-pattern.md) — MEDIUM
   - 1.14 [Derive Copy for Simple Enums](references/type-enum-copy-simple.md) — MEDIUM
   - 1.15 [Implement Operator Traits for Domain Types](references/type-operator-overload.md) — MEDIUM
   - 1.16 [Use PhantomData for Unused Generic Parameters](references/type-phantom-unused-params.md) — MEDIUM
   - 1.17 [Use Public Fields for Data Structs](references/type-public-fields.md) — MEDIUM
   - 1.18 [Use Consistent Derive Order for Data Structs](references/type-standard-derives.md) — MEDIUM
   - 1.19 [Group Related Trait Implementations Together](references/type-trait-impl-grouping.md) — LOW
   - 1.20 [Use Type Aliases for Complex Generics](references/type-type-aliases.md) — LOW
2. [Ownership & Borrowing](references/_sections.md#2-ownership--borrowing) — **CRITICAL**
   - 2.1 [Accept Borrowed Types Over Owned References](references/own-accept-borrowed-types.md) — CRITICAL
   - 2.2 [Avoid Unnecessary Clone Calls](references/own-avoid-unnecessary-clone.md) — CRITICAL
   - 2.3 [Use Cow for Conditional Ownership](references/own-cow-conditional-clone.md) — CRITICAL
   - 2.4 [Leverage Lifetime Elision Rules](references/own-lifetime-elision.md) — CRITICAL
   - 2.5 [Prefer Borrowing Over Ownership in Function Parameters](references/own-prefer-borrowing.md) — CRITICAL
   - 2.6 [Return Owned Types for Caller Flexibility](references/own-return-owned-for-flexibility.md) — CRITICAL
3. [Error Handling](references/_sections.md#3-error-handling) — **HIGH**
   - 3.1 [Use Two-Tier Error Strategy](references/err-two-tier-strategy.md) — HIGH
   - 3.2 [Use thiserror for Custom Error Types](references/err-thiserror-enum.md) — HIGH
   - 3.3 [Use anyhow for Application Error Handling](references/err-anyhow-for-applications.md) — HIGH
   - 3.4 [Use Result Instead of panic! for Recoverable Errors](references/err-use-result-not-panic.md) — HIGH
   - 3.5 [Reserve panic! for Unrecoverable Situations](references/err-panic-unrecoverable.md) — HIGH
   - 3.6 [Include Path Context in IO Errors](references/err-path-context.md) — HIGH
   - 3.7 [Use Option for Absence, Not Sentinel Values](references/err-option-for-absence.md) — HIGH
   - 3.8 [Use the Question Mark Operator for Error Propagation](references/err-question-mark-propagation.md) — HIGH
   - 3.9 [Use context() and with_context() for Error Messages](references/err-anyhow-context.md) — MEDIUM
   - 3.10 [Use bail! for Validation Failures](references/err-bail-validation.md) — MEDIUM
   - 3.11 [Use Graceful Degradation for Non-Critical Operations](references/err-graceful-degradation.md) — MEDIUM
   - 3.12 [Use #[source] for Error Chaining](references/err-source-attribute.md) — MEDIUM
   - 3.13 [Use expect() with Descriptive Messages](references/err-expect-message.md) — LOW
   - 3.14 [Use ok_or_else for Expensive Error Construction](references/err-ok-or-else.md) — LOW
   - 3.15 [Define Module-Local Result Type Alias](references/err-result-alias.md) — LOW
4. [API Design & Traits](references/_sections.md#4-api-design--traits) — **HIGH**
   - 4.1 [Derive Common Traits for Public Types](references/api-derive-common-traits.md) — HIGH
   - 4.2 [Implement Standard Traits for Ergonomic APIs](references/api-impl-standard-traits.md) — HIGH
   - 4.3 [Use Trait Bounds for Generic Flexibility](references/api-generic-bounds.md) — HIGH
   - 4.4 [Use Sealed Traits to Prevent External Implementation](references/api-sealed-traits.md) — HIGH
   - 4.5 [Use Builder Pattern for Complex Construction](references/api-builder-pattern.md) — HIGH
   - 4.6 [Use Extension Traits to Add Methods to Foreign Types](references/api-extension-traits.md) — HIGH
5. [Project Organization](references/_sections.md#5-project-organization) — **HIGH**
   - 5.1 [Use Cargo Workspace for Multi-Crate Projects](references/org-cargo-workspace.md) — HIGH
   - 5.2 [Use snake_case for All Directory Names](references/org-directory-naming.md) — HIGH
   - 5.3 [Separate Binary and Library Crates](references/org-binary-library-separation.md) — HIGH
   - 5.4 [Group Crates by Feature Domain](references/org-feature-domain-grouping.md) — MEDIUM
   - 5.5 [Use Dedicated Common Crate for Shared Utilities](references/org-common-crate.md) — MEDIUM
   - 5.6 [Keep Crate Structure Flat](references/org-flat-crate-structure.md) — MEDIUM
6. [Module & Visibility](references/_sections.md#6-module--visibility) — **MEDIUM-HIGH**
   - 6.1 [Use Explicit Module Declarations in lib.rs](references/mod-explicit-declarations.md) — HIGH
   - 6.2 [Co-locate Tests as test.rs Files](references/mod-colocated-tests.md) — HIGH
   - 6.3 [Minimize Public API Surface](references/mod-minimize-pub-api.md) — MEDIUM-HIGH
   - 6.4 [Use pub use for Clean Module Re-exports](references/mod-pub-use-reexports.md) — MEDIUM-HIGH
   - 6.5 [Split Large Modules into Submodules](references/mod-split-large-modules.md) — MEDIUM-HIGH
   - 6.6 [Use crate Prefix for Internal Imports](references/mod-crate-prefix-imports.md) — MEDIUM-HIGH
   - 6.7 [Use tests Submodule for Unit Tests](references/mod-tests-submodule.md) — MEDIUM-HIGH
   - 6.8 [Use cfg Attributes for Conditional Modules](references/mod-conditional-compilation.md) — MEDIUM
   - 6.9 [Separate Types and Errors into Dedicated Files](references/mod-types-errors-files.md) — MEDIUM
7. [Naming Conventions](references/_sections.md#7-naming-conventions) — **MEDIUM-HIGH**
   - 7.1 [Use snake_case for Functions and Methods](references/name-function-snake-case.md) — HIGH
   - 7.2 [Use PascalCase for Types](references/name-type-pascal-case.md) — HIGH
   - 7.3 [Use snake_case for Module Names](references/name-module-snake-case.md) — HIGH
   - 7.4 [Use new for Constructors](references/name-constructor-new.md) — HIGH
   - 7.5 [Use SCREAMING_SNAKE_CASE for Constants](references/name-constant-screaming.md) — MEDIUM
   - 7.6 [Prefix Getter Functions with get_](references/name-getter-prefix.md) — MEDIUM
   - 7.7 [Use is_, has_, should_ for Boolean Predicates](references/name-boolean-predicates.md) — MEDIUM
   - 7.8 [Use to_ and from_ for Conversions](references/name-conversion-to-from.md) — MEDIUM
   - 7.9 [Use Descriptive Suffixes for Type Specialization](references/name-type-suffixes.md) — MEDIUM
   - 7.10 [Include Unit Suffixes in Field Names](references/name-field-unit-suffixes.md) — LOW
   - 7.11 [Use Descriptive or Single-Letter Generic Parameters](references/name-generic-parameters.md) — LOW
   - 7.12 [Use Single Lowercase Letters for Lifetimes](references/name-lifetime-parameters.md) — LOW
   - 7.13 [Name Test Files as test.rs](references/name-test-files.md) — LOW
8. [Conversion Traits](references/_sections.md#8-conversion-traits) — **MEDIUM**
   - 8.1 [Implement From Instead of Into](references/conv-impl-from-not-into.md) — MEDIUM
   - 8.2 [Accept AsRef for Flexible String Parameters](references/conv-asref-for-flexibility.md) — MEDIUM
   - 8.3 [Implement Deref for Transparent Newtype Access](references/conv-impl-deref-for-newtypes.md) — MEDIUM
   - 8.4 [Use TryFrom for Fallible Conversions](references/conv-tryfrom-for-fallible.md) — MEDIUM
   - 8.5 [Use Inner Function Pattern to Reduce Monomorphization](references/conv-inner-function-pattern.md) — MEDIUM
9. [Idiomatic Patterns](references/_sections.md#9-idiomatic-patterns) — **MEDIUM**
   - 9.1 [Implement Default Instead of new() Without Arguments](references/idiom-default-trait.md) — MEDIUM
   - 9.2 [Follow Constructor Naming Conventions](references/idiom-constructor-naming.md) — MEDIUM
   - 9.3 [Use let-else for Early Returns on Pattern Match Failure](references/idiom-let-else.md) — MEDIUM
   - 9.4 [Use Struct Update Syntax for Partial Overrides](references/idiom-struct-update-syntax.md) — MEDIUM
   - 9.5 [Use Destructuring for Multiple Returns and Field Access](references/idiom-destructuring-assignment.md) — MEDIUM
   - 9.6 [Use Match Guards for Complex Conditions](references/idiom-match-guards.md) — MEDIUM
10. [Iterator & Collections](references/_sections.md#10-iterator--collections) — **LOW-MEDIUM**
    - 10.1 [Prefer Iterator Methods Over Manual Loops](references/iter-prefer-iterators-over-loops.md) — LOW-MEDIUM
    - 10.2 [Use Turbofish for Explicit collect Type](references/iter-use-collect-turbofish.md) — LOW-MEDIUM
    - 10.3 [Use filter_map for Combined Filter and Transform](references/iter-filter-map-combined.md) — LOW-MEDIUM
    - 10.4 [Avoid Collecting Then Iterating](references/iter-avoid-collect-then-iterate.md) — LOW-MEDIUM
    - 10.5 [Use enumerate Instead of Manual Index Tracking](references/iter-enumerate-for-indices.md) — LOW-MEDIUM

## References

1. [https://rust-lang.github.io/api-guidelines/](https://rust-lang.github.io/api-guidelines/)
2. [https://rust-unofficial.github.io/patterns/](https://rust-unofficial.github.io/patterns/)
3. [https://doc.rust-lang.org/book/](https://doc.rust-lang.org/book/)
4. [https://www.lurklurk.org/effective-rust/](https://www.lurklurk.org/effective-rust/)
5. [https://rust-lang.github.io/rust-clippy/](https://rust-lang.github.io/rust-clippy/)

## Related Skills

- For performance optimization, see `rust-optimise` skill
