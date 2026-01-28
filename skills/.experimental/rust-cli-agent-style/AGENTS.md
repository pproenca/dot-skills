# Rust CLI Agent

**Version 1.0.0**  
OpenAI Codex  
2026-01-28

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Coding patterns extracted from OpenAI Codex Rust codebase - a production CLI/agent system with 50 crates, 787 Rust files, strict error handling (deny unwrap/expect), tokio async runtime, and thiserror/anyhow error patterns.

---

## Table of Contents

1. [Error Handling](references/_sections.md#1-error-handling) — **CRITICAL**
   - 1.1 [Add context to errors with .context()](references/err-context-chain.md) — HIGH (Error context chains make debugging production issues much easier)
   - 1.2 [Avoid expect() in library code](references/err-no-expect.md) — CRITICAL (Library code should never panic - callers cannot recover from panics)
   - 1.3 [Document error conditions with # Errors](references/err-doc-errors.md) — MEDIUM (Clear documentation helps users handle errors correctly)
   - 1.4 [Never use unwrap() in non-test code](references/err-no-unwrap.md) — CRITICAL (Panics in production code cause crashes and poor user experience)
   - 1.5 [Use #[error(transparent)] for wrapped errors](references/err-transparent.md) — MEDIUM (Preserves original error messages when wrapping without additional context)
   - 1.6 [Use #[from] for automatic error conversion](references/err-from-derive.md) — MEDIUM (Reduces boilerplate for common error conversions)
   - 1.7 [Use anyhow::Result for application entry points](references/err-anyhow-application.md) — HIGH (Simplifies error handling in application code while preserving error context)
   - 1.8 [Use map_err for error type conversion](references/err-map-err-conversion.md) — MEDIUM (Explicit error conversion improves code clarity and control)
   - 1.9 [Use std::io::Result for I/O functions](references/err-io-result.md) — MEDIUM (Standard I/O result type for consistency with ecosystem)
   - 1.10 [Use structured error variants with fields](references/err-structured-variants.md) — HIGH (Structured errors enable better debugging and programmatic error handling)
   - 1.11 [Use thiserror for domain error types](references/err-thiserror-domain.md) — CRITICAL (Consistent error types enable proper error propagation and debugging across the codebase)
2. [Organization](references/_sections.md#2-organization) — **HIGH**
   - 2.1 [Create separate crate for shared test utilities](references/org-test-common-crate.md) — MEDIUM (Shared test utilities reduce duplication and enable consistent testing patterns)
   - 2.2 [Define error types in dedicated errors.rs file](references/org-errors-file.md) — MEDIUM (Centralized error definitions improve discoverability and consistency)
   - 2.3 [Organize by feature with mod.rs files](references/org-feature-modules.md) — MEDIUM (Feature-based organization improves code navigation and maintainability)
   - 2.4 [Organize integration tests in suite directory](references/org-integration-tests-suite.md) — MEDIUM (Structured test organization improves maintainability and test discovery)
   - 2.5 [Place handlers in dedicated subdirectory](references/org-handlers-subdir.md) — MEDIUM (Separating handlers from core logic improves code organization)
   - 2.6 [Use flat workspace structure with utils subdirectory](references/org-workspace-flat.md) — HIGH (Consistent workspace layout enables easy navigation and discovery)
   - 2.7 [Use kebab-case for crate directories with project prefix](references/org-crate-naming.md) — HIGH (Consistent naming enables easy identification of internal crates)
   - 2.8 [Use pub(crate) for internal APIs](references/org-module-visibility.md) — HIGH (Proper visibility prevents accidental external dependencies on internal APIs)
3. [Component Patterns](references/_sections.md#3-component-patterns) — **HIGH**
   - 3.1 [Create type aliases for complex generic types](references/mod-type-alias-complex.md) — MEDIUM (Type aliases improve readability of complex nested generics)
   - 3.2 [Default to private fields with public constructor](references/mod-struct-visibility.md) — MEDIUM (Encapsulation enables future changes without breaking API)
   - 3.3 [Derive JsonSchema for API types](references/mod-jsonschema-derive.md) — MEDIUM (Schema generation enables automatic API documentation and validation)
   - 3.4 [Include Send + Sync + 'static for concurrent traits](references/mod-trait-bounds.md) — HIGH (Proper bounds enable traits to work in async and multithreaded contexts)
   - 3.5 [Order derive macros consistently](references/mod-derive-order.md) — MEDIUM (Consistent derive ordering improves code readability and diff quality)
   - 3.6 [Order impl blocks consistently](references/mod-impl-block-order.md) — LOW (Consistent ordering makes code navigation predictable)
   - 3.7 [Use #[async_trait] for async trait methods](references/mod-async-trait-macro.md) — HIGH (Enables async methods in traits which Rust doesn't natively support yet)
   - 3.8 [Use builder pattern for complex configuration](references/mod-builder-pattern.md) — MEDIUM (Builders make construction of complex types readable and flexible)
   - 3.9 [Use Ext suffix for extension traits](references/mod-extension-trait-suffix.md) — MEDIUM (Clear naming distinguishes extension traits from core traits)
   - 3.10 [Use newtype pattern for type safety](references/mod-newtype-pattern.md) — HIGH (Newtypes prevent mixing up values with the same underlying type)
   - 3.11 [Use serde rename for wire format compatibility](references/mod-serde-rename.md) — HIGH (Proper serde configuration ensures API compatibility)
   - 3.12 [Use where clauses for complex bounds](references/mod-generic-constraints.md) — MEDIUM (Where clauses improve readability of complex generic constraints)
4. [Cross-Crate](references/_sections.md#4-cross-crate) — **HIGH**
   - 4.1 [Centralize dependency versions in workspace](references/cross-workspace-deps.md) — HIGH (Consistent dependency versions prevent version conflicts)
   - 4.2 [Define common lints in workspace Cargo.toml](references/cross-workspace-lints.md) — HIGH (Consistent lint configuration across all workspace crates)
5. [Naming Conventions](references/_sections.md#5-naming-conventions) — **MEDIUM**
   - 5.1 [Avoid _async suffix for async functions](references/name-async-no-suffix.md) — MEDIUM (Cleaner API - async is evident from the function signature)
   - 5.2 [Define crate-specific Result type alias](references/name-result-type-alias.md) — MEDIUM (Reduces boilerplate and makes error types explicit)
   - 5.3 [Name environment variable constants with _ENV_VAR suffix](references/name-const-env-var.md) — LOW (Clear distinction between config keys and their environment variable sources)
   - 5.4 [Pair Request/Response types](references/name-request-response.md) — MEDIUM (Consistent API type pairing improves code navigation and understanding)
   - 5.5 [Use Client suffix for API clients](references/name-client-suffix.md) — HIGH (Clear identification of types that make external API calls)
   - 5.6 [Use Error suffix for error types](references/name-error-suffix.md) — HIGH (Consistent error naming enables easy identification and handling)
   - 5.7 [Use Handler suffix for trait implementations](references/name-handler-suffix.md) — MEDIUM (Clear naming indicates the purpose of handler types)
   - 5.8 [Use Info suffix for read-only data structures](references/name-info-suffix.md) — LOW (Clear indication that a type is for information retrieval, not mutation)
   - 5.9 [Use is_/has_/should_ prefix for boolean functions](references/name-bool-is-prefix.md) — MEDIUM (Boolean function naming follows English grammar for readability)
   - 5.10 [Use Manager suffix for lifecycle management](references/name-manager-suffix.md) — MEDIUM (Clear identification of types that manage resource lifecycles)
   - 5.11 [Use Options suffix for configuration bundles](references/name-options-suffix.md) — MEDIUM (Clear naming for optional configuration structures)
   - 5.12 [Use plural names for collections](references/name-plural-collections.md) — LOW (Natural English naming for collection types)
   - 5.13 [Use Provider suffix for service implementations](references/name-provider-suffix.md) — MEDIUM (Clear identification of service provider types)
   - 5.14 [Use try_ prefix for fallible constructors](references/name-try-prefix-fallible.md) — HIGH (Clear indication that construction can fail)
   - 5.15 [Use with_ prefix for builder methods](references/name-with-prefix-builder.md) — MEDIUM (Consistent builder API across the codebase)
6. [Style](references/_sections.md#6-style) — **MEDIUM**
   - 6.1 [Add module-level documentation](references/style-module-docs.md) — MEDIUM (Module docs provide context and improve API discoverability)
   - 6.2 [Deny direct stdout/stderr in library code](references/style-deny-stdout.md) — HIGH (Library code should use structured logging, not direct output)
   - 6.3 [Place unit tests in #[cfg(test)] mod tests](references/style-cfg-test-module.md) — HIGH (Standard Rust test organization pattern)
   - 6.4 [Use #[expect] with reason for lint suppression](references/style-expect-reason.md) — MEDIUM (Documents why lints are suppressed and ensures suppressions are still needed)
   - 6.5 [Use inline format arguments](references/style-inline-format-args.md) — MEDIUM (Cleaner, more readable format strings)
   - 6.6 [Use one item per use statement](references/style-import-granularity.md) — MEDIUM (Cleaner diffs and easier import management)

---

## References

1. [https://github.com/openai/codex](https://github.com/openai/codex)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |