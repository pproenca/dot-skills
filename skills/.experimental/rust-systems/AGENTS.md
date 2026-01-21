# Rust

**Version 1.0.0**  
dot-skills  
January 2025

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Rust systems programming patterns and style conventions for building reliable systems software. Contains 52 rules across 5 categories covering project organization, module structure, naming conventions, type/trait patterns, and error handling. Each rule demonstrates idiomatic Rust patterns with proper error handling, type safety, and maintainable architecture.

---

## Table of Contents

1. [Project Organization](references/_sections.md#1-project-organization) — **HIGH**
   - 1.1 [Group Crates by Feature Domain](references/org-feature-domain-grouping.md) — MEDIUM (Domain-based organization creates natural boundaries and improves code discoverability)
   - 1.2 [Keep Crate Structure Flat](references/org-flat-crate-structure.md) — MEDIUM (Flat structures reduce cognitive overhead and make files easy to locate)
   - 1.3 [Separate Binary and Library Crates](references/org-binary-library-separation.md) — HIGH (Enables code reuse, cleaner dependencies, and testable library code)
   - 1.4 [Use Cargo Workspace for Multi-Crate Projects](references/org-cargo-workspace.md) — HIGH (Enables independent compilation, clear crate boundaries, and faster incremental builds)
   - 1.5 [Use Dedicated Common Crate for Shared Utilities](references/org-common-crate.md) — MEDIUM (Centralizes shared code, prevents duplication, and avoids scattered utils directories)
   - 1.6 [Use snake_case for All Directory Names](references/org-directory-naming.md) — HIGH (Consistent naming prevents module resolution issues and follows Rust ecosystem conventions)
2. [Module Structure](references/_sections.md#2-module-structure) — **HIGH**
   - 2.1 [Co-locate Tests as test.rs Files](references/mod-colocated-tests.md) — HIGH (Co-located tests are easier to maintain and update alongside the code they test)
   - 2.2 [Separate Types and Errors into Dedicated Files](references/mod-types-errors-files.md) — MEDIUM (Dedicated files for types and errors improve discoverability and enable focused reviews)
   - 2.3 [Use cfg Attributes for Conditional Modules](references/mod-conditional-compilation.md) — MEDIUM (Conditional compilation enables platform-specific code and optional features cleanly)
   - 2.4 [Use Explicit Module Declarations in lib.rs](references/mod-explicit-declarations.md) — HIGH (Explicit declarations make module structure visible and prevent accidental public exposure)
   - 2.5 [Use mod.rs for Multi-File Modules](references/mod-submodule-organization.md) — MEDIUM (Subdirectories with mod.rs organize complex modules while maintaining clear boundaries)
   - 2.6 [Use pub use for Clean API Re-exports](references/mod-reexport-pattern.md) — MEDIUM (Re-exports create clean public APIs while hiding internal module structure)
3. [Naming Conventions](references/_sections.md#3-naming-conventions) — **HIGH**
   - 3.1 [Include Unit Suffixes in Field Names](references/name-field-unit-suffixes.md) — LOW (Unit suffixes prevent unit confusion bugs and make code self-documenting)
   - 3.2 [Name Test Files as test.rs](references/name-test-files.md) — LOW (Consistent test file naming makes test location predictable)
   - 3.3 [Prefix Getter Functions with get_](references/name-getter-prefix.md) — MEDIUM (Consistent prefixes make API predictable and self-documenting)
   - 3.4 [Use Descriptive or Single-Letter Generic Parameters](references/name-generic-parameters.md) — LOW (Appropriate generic naming balances readability with convention)
   - 3.5 [Use Descriptive Suffixes for Type Specialization](references/name-type-suffixes.md) — MEDIUM (Semantic suffixes communicate type purpose without reading implementation)
   - 3.6 [Use is_, has_, should_ for Boolean Predicates](references/name-boolean-predicates.md) — MEDIUM (Question-like prefixes make boolean return types self-evident)
   - 3.7 [Use new for Constructors](references/name-constructor-new.md) — HIGH (Consistent constructor naming follows Rust conventions and IDE expectations)
   - 3.8 [Use PascalCase for Types](references/name-type-pascal-case.md) — HIGH (Consistent with Rust RFC 430 and visually distinguishes types from values)
   - 3.9 [Use SCREAMING_SNAKE_CASE for Constants](references/name-constant-screaming.md) — MEDIUM (Visual distinction for immutable values helps identify compile-time constants)
   - 3.10 [Use Single Lowercase Letters for Lifetimes](references/name-lifetime-parameters.md) — LOW (Consistent lifetime naming follows Rust conventions)
   - 3.11 [Use snake_case for Functions and Methods](references/name-function-snake-case.md) — HIGH (Consistent with Rust RFC 430 and enables automatic lint warnings for violations)
   - 3.12 [Use snake_case for Module Names](references/name-module-snake-case.md) — HIGH (Module naming must match Rust's module resolution rules)
   - 3.13 [Use to_ and from_ for Conversions](references/name-conversion-to-from.md) — MEDIUM (Conversion prefixes indicate data flow direction and transformation semantics)
4. [Type & Trait Patterns](references/_sections.md#4-type-&-trait-patterns) — **HIGH**
   - 4.1 [Derive Copy for Simple Enums](references/type-enum-copy-simple.md) — MEDIUM (Copy-able enums avoid unnecessary cloning and enable value semantics)
   - 4.2 [Group Related Trait Implementations Together](references/type-trait-impl-grouping.md) — LOW (Grouped impls improve code navigation and review)
   - 4.3 [Implement Operator Traits for Domain Types](references/type-operator-overload.md) — MEDIUM (Operator overloading enables natural syntax for domain-specific arithmetic)
   - 4.4 [Use Associated Types for Related Type Relationships](references/type-associated-types.md) — HIGH (Associated types simplify trait bounds and make APIs more ergonomic)
   - 4.5 [Use async_trait for Async Trait Methods](references/type-async-trait.md) — MEDIUM (async_trait enables async methods in traits until native support stabilizes)
   - 4.6 [Use bitflags! for Type-Safe Bit Flags](references/type-bitflags.md) — MEDIUM (bitflags! prevents integer flag mixing and enables set operations)
   - 4.7 [Use Box<dyn Trait> for Runtime Polymorphism](references/type-boxed-trait-objects.md) — MEDIUM (Trait objects enable runtime polymorphism when types aren't known at compile time)
   - 4.8 [Use Builder Pattern with Method Chaining](references/type-builder-pattern.md) — MEDIUM (Builders enable flexible construction while keeping structs immutable)
   - 4.9 [Use Consistent Derive Order for Data Structs](references/type-standard-derives.md) — MEDIUM (Consistent derive ordering improves code review and grep-ability)
   - 4.10 [Use Enums for Type-Safe Variants](references/type-enum-variants.md) — HIGH (Enum variants with data enable exhaustive matching and prevent invalid states)
   - 4.11 [Use Newtype Pattern for Type Safety](references/type-newtype-pattern.md) — MEDIUM (Newtypes prevent mixing semantically different values of the same underlying type)
   - 4.12 [Use Option<T> for Nullable Fields](references/type-option-nullable-fields.md) — HIGH (Option<T> enforces null-safety at compile time and prevents null pointer panics)
   - 4.13 [Use PhantomData for Unused Generic Parameters](references/type-phantom-data.md) — MEDIUM (PhantomData maintains type relationships without runtime overhead)
   - 4.14 [Use Public Fields for Data Structs](references/type-public-fields.md) — MEDIUM (Public fields reduce boilerplate for pure data containers)
   - 4.15 [Use Type Aliases for Complex Generics](references/type-type-aliases.md) — LOW (Type aliases simplify signatures and improve readability)
5. [Error Handling](references/_sections.md#5-error-handling) — **HIGH**
   - 5.1 [Define Module-Local Result Type Alias](references/err-result-alias.md) — LOW (Result aliases reduce verbosity and make error types consistent)
   - 5.2 [Include Path Context in IO Errors](references/err-path-context.md) — HIGH (Path context in errors enables debugging without access to the running system)
   - 5.3 [Reserve panic! for Unrecoverable Situations](references/err-panic-unrecoverable.md) — HIGH (Panics terminate the program - use only when continuation is impossible)
   - 5.4 [Use #[source] for Error Chaining](references/err-source-attribute.md) — MEDIUM (Source attributes enable error chain traversal for debugging)
   - 5.5 [Use bail! for Validation Failures](references/err-bail-validation.md) — MEDIUM (bail! provides clean early exit for validation checks)
   - 5.6 [Use context() and with_context() for Error Messages](references/err-anyhow-context.md) — MEDIUM (Context methods add information without losing the original error chain)
   - 5.7 [Use expect() with Descriptive Messages](references/err-expect-message.md) — LOW (expect() documents why the unwrap should never fail)
   - 5.8 [Use Graceful Degradation for Non-Critical Operations](references/err-graceful-degradation.md) — MEDIUM (Logging errors instead of propagating keeps systems running when subsystems fail)
   - 5.9 [Use ok_or_else for Expensive Error Construction](references/err-ok-or-else.md) — LOW (Lazy evaluation prevents allocation when the Option is Some)
   - 5.10 [Use thiserror for Custom Error Types](references/err-thiserror-enum.md) — HIGH (thiserror provides automatic Error trait implementation with minimal boilerplate)
   - 5.11 [Use Two-Tier Error Strategy](references/err-two-tier-strategy.md) — HIGH (Separating library and application errors enables both precision and convenience)

---

## References

1. [https://doc.rust-lang.org/book/](https://doc.rust-lang.org/book/)
2. [https://rust-lang.github.io/api-guidelines/](https://rust-lang.github.io/api-guidelines/)
3. [https://doc.rust-lang.org/nomicon/](https://doc.rust-lang.org/nomicon/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |