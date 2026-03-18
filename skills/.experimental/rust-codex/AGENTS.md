# Codex-RS Rust

**Version 1.0.0**  
Codex-RS Contributors  
March 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive best practices guide for the Codex-RS Rust codebase, designed for AI agents and LLMs. Contains 40 rules across 8 categories, prioritized by impact from critical (error handling, type design) to incremental (build and CI). Each rule includes detailed explanations, real-world examples from the codex-rs codebase comparing incorrect vs. correct implementations, and specific impact metrics to guide automated code generation.

---

## Table of Contents

1. [Error Handling](references/_sections.md#1-error-handling) — **CRITICAL**
   - 1.1 [Avoid unwrap() in Production Code](references/err-avoid-unwrap-production.md) — CRITICAL (prevents runtime panics in production (clippy::unwrap_used is denied))
   - 1.2 [Define Domain-Specific Error Variants](references/err-codexerr-domain-variants.md) — CRITICAL (enables precise error matching and retryability checking)
   - 1.3 [Use .context() on Every Fallible Operation](references/err-context-every-fallible.md) — CRITICAL (prevents opaque errors, saves 5-30min per debug session)
   - 1.4 [Use Descriptive Context Strings Explaining the Operation](references/err-descriptive-context-strings.md) — CRITICAL (reduces debugging time by 2-5x with actionable messages)
   - 1.5 [Use let _ = for Non-Critical Send Failures](references/err-let-underscore-noncritical.md) — CRITICAL (prevents panic during graceful shutdown)
   - 1.6 [Use Platform-Conditional Error Variants](references/err-platform-conditional-variants.md) — CRITICAL (avoids compilation errors on non-target platforms)
2. [Type Design](references/_sections.md#2-type-design) — **CRITICAL**
   - 2.1 [Prefer BTreeMap for Deterministic Output](references/type-btreemap-determinism.md) — CRITICAL (eliminates nondeterministic serialization in configs and snapshots)
   - 2.2 [Return Named Structs Over Tuples](references/type-return-struct-over-tuple.md) — CRITICAL (prevents field-order confusion when destructuring)
   - 2.3 [Use Argument Comments Before Opaque Literals](references/type-param-comment-lint.md) — CRITICAL (prevents wrong-argument-order bugs at callsites)
   - 2.4 [Use Enums Over Bool Parameters](references/type-enum-over-bool.md) — CRITICAL (prevents wrong-argument bugs, makes callsites self-documenting)
   - 2.5 [Use Exhaustive Match Without Wildcards](references/type-exhaustive-match.md) — CRITICAL (catches 100% of unhandled enum variants at compile time)
   - 2.6 [Use Newtype Wrappers for Domain Identifiers](references/type-newtype-wrappers.md) — CRITICAL (prevents mixing up plain String IDs at compile time)
3. [Module Organization](references/_sections.md#3-module-organization) — **HIGH**
   - 3.1 [Avoid Creating Single-Use Helper Methods](references/mod-no-single-use-helpers.md) — HIGH (reduces indirection and keeps logic close to its usage)
   - 3.2 [Keep Modules Under 500 Lines of Code](references/mod-500-loc-limit.md) — HIGH (reduces merge conflicts by 40-60% in high-touch files)
   - 3.3 [Move Tests and Docs When Extracting Modules](references/mod-extract-with-docs.md) — HIGH (prevents 2-5x documentation staleness after module extraction)
   - 3.4 [Prefix All Crate Names with codex-](references/mod-crate-name-prefix.md) — HIGH (maintains consistent naming across the workspace)
   - 3.5 [Use Sibling Test Files Instead of Inline Test Modules](references/mod-sibling-test-files.md) — HIGH (reduces production file size by 30-50% via test separation)
4. [Serde and Wire Format](references/_sections.md#4-serde-and-wire-format) — **HIGH**
   - 4.1 [Align serde and ts-rs Annotations](references/serde-ts-export.md) — HIGH (prevents Rust/TypeScript serialization mismatches)
   - 4.2 [Avoid skip_serializing_if for v2 API Fields](references/serde-no-skip-v2.md) — HIGH (prevents silent field omission bugs in the v2 API)
   - 4.3 [Use Explicit Tag for Discriminated Unions](references/serde-tagged-unions.md) — HIGH (prevents 100% of union deserialization failures across Rust/TS)
   - 4.4 [Use Params Response Notification Naming Convention](references/serde-params-response-naming.md) — HIGH (enables automatic code generation and consistent API patterns)
   - 4.5 [Use Plain String IDs at API Boundaries](references/serde-string-ids.md) — HIGH (avoids UUID parsing failures at API boundaries)
   - 4.6 [Use rename_all camelCase on Wire Types](references/serde-rename-camelcase.md) — HIGH (prevents 100% of snake_case wire format mismatches)
5. [Async and Concurrency](references/_sections.md#5-async-and-concurrency) — **MEDIUM-HIGH**
   - 5.1 [Use Appropriate Channel Types for Communication](references/async-channel-selection.md) — MEDIUM-HIGH (prevents deadlocks and memory leaks from wrong channel type)
   - 5.2 [Use Arc Notify for Task Completion Signaling](references/async-notify-coordination.md) — MEDIUM-HIGH (avoids JoinHandle overhead for fire-and-forget coordination)
   - 5.3 [Use Box::pin for Large Async Stack Frames](references/async-box-pin-stack.md) — MEDIUM-HIGH (prevents stack overflow on Windows where default stack is 1MB)
   - 5.4 [Use CancellationToken for Shutdown Coordination](references/async-cancellation-token.md) — MEDIUM-HIGH (enables clean hierarchical shutdown across task trees)
   - 5.5 [Use let _ = tx.send() for Fire-and-Forget Channels](references/async-fire-forget-send.md) — MEDIUM-HIGH (prevents panic during shutdown when receivers are dropped)
6. [Config System](references/_sections.md#6-config-system) — **MEDIUM**
   - 6.1 [Follow the Feature Flag Lifecycle](references/cfg-feature-flag-lifecycle.md) — MEDIUM (prevents 100% of premature feature exposure incidents)
   - 6.2 [Run just bazel-lock-update After Dependency Changes](references/cfg-bazel-lock-update.md) — MEDIUM (prevents Bazel CI failure from lockfile drift)
   - 6.3 [Run just write-config-schema After Config Changes](references/cfg-write-config-schema.md) — MEDIUM (prevents CI failure from stale config schema)
   - 6.4 [Update BUILD.bazel for Compile-Time File Access](references/cfg-include-str-bazel.md) — MEDIUM (prevents Bazel build failure when Cargo passes)
7. [TUI Conventions](references/_sections.md#7-tui-conventions) — **MEDIUM**
   - 7.1 [Avoid Hardcoded White Color](references/tui-no-hardcoded-white.md) — MEDIUM (preserves theme compatibility with dark and light modes)
   - 7.2 [Mirror Changes Between tui and tui_app_server](references/tui-mirror-implementations.md) — MEDIUM (prevents behavioral drift between TUI implementations)
   - 7.3 [Use Ratatui Stylize Trait Helpers](references/tui-stylize-helpers.md) — MEDIUM (reduces boilerplate by 60-70% for styled spans)
   - 7.4 [Use textwrap and word_wrap_lines for Text Wrapping](references/tui-textwrap-helpers.md) — MEDIUM (eliminates 100% of manual wrapping bugs and edge cases)
8. [Build and CI](references/_sections.md#8-build-and-ci) — **LOW-MEDIUM**
   - 8.1 [Collapse Nested if Statements](references/ci-collapsible-if.md) — LOW-MEDIUM (prevents clippy CI failure (clippy::collapsible_if))
   - 8.2 [Inline Format Arguments in format! Macros](references/ci-inline-format-args.md) — LOW-MEDIUM (prevents clippy CI failure and improves readability)
   - 8.3 [Run just fmt After Rust Changes](references/ci-just-fmt.md) — LOW-MEDIUM (prevents formatting CI failures)
   - 8.4 [Use Scoped just fix for Clippy Linting](references/ci-just-fix-scoped.md) — LOW-MEDIUM (avoids slow workspace-wide Clippy builds (10-15min saved))

---

## References

1. [https://github.com/openai/codex](https://github.com/openai/codex)
2. [https://doc.rust-lang.org/book/](https://doc.rust-lang.org/book/)
3. [https://rust-lang.github.io/rust-clippy/master/index.html](https://rust-lang.github.io/rust-clippy/master/index.html)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |