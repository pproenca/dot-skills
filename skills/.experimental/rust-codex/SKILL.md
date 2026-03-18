---
name: rust-codex
description: Comprehensive best practices for the Codex-RS Rust codebase with 40 rules across 8 categories
---

# Codex-RS Contributors Codex-RS Rust Best Practices

A structured guide to writing Rust code that matches the conventions of the Codex-RS codebase. Each rule includes incorrect/correct examples drawn from real patterns in the repository.

## When to Apply

- Writing new Rust code in any `codex-rs/` crate
- Reviewing or modifying existing Codex-RS modules
- Adding new features to the app-server protocol or TUI
- Changing config types, feature flags, or dependencies
- Debugging error handling or async task coordination issues

## Rule Categories by Priority

| # | Category | Prefix | Impact | Rules |
|---|----------|--------|--------|-------|
| 1 | Error Handling | err- | CRITICAL | 6 |
| 2 | Type Design | type- | CRITICAL | 6 |
| 3 | Module Organization | mod- | HIGH | 5 |
| 4 | Serde and Wire Format | serde- | HIGH | 6 |
| 5 | Async and Concurrency | async- | MEDIUM-HIGH | 5 |
| 6 | Config System | cfg- | MEDIUM | 4 |
| 7 | TUI Conventions | tui- | MEDIUM | 4 |
| 8 | Build and CI | ci- | LOW-MEDIUM | 4 |
| | **Total** | | | **40** |

## Quick Reference

### Error Handling (CRITICAL)
- `err-context-every-fallible` - Use .context() on every fallible operation
- `err-descriptive-context-strings` - Write descriptive context strings naming the operation
- `err-let-underscore-noncritical` - Use let _ = for non-critical send failures
- `err-avoid-unwrap-production` - Avoid unwrap() in production code
- `err-codexerr-domain-variants` - Define domain-specific error variants in CodexErr
- `err-platform-conditional-variants` - Gate platform-specific error variants with #[cfg]

### Type Design (CRITICAL)
- `type-enum-over-bool` - Use enums over bool parameters
- `type-param-comment-lint` - Use /*param_name*/ comments before opaque literals
- `type-exhaustive-match` - Use exhaustive match without wildcards
- `type-btreemap-determinism` - Prefer BTreeMap for deterministic output
- `type-newtype-wrappers` - Use newtype wrappers for domain identifiers
- `type-return-struct-over-tuple` - Return named structs over tuples

### Module Organization (HIGH)
- `mod-500-loc-limit` - Keep modules under 500 lines of code
- `mod-sibling-test-files` - Use sibling test files via #[path = "..."]
- `mod-no-single-use-helpers` - Avoid single-use helper methods
- `mod-crate-name-prefix` - Prefix all crate names with codex-
- `mod-extract-with-docs` - Move tests and docs when extracting modules

### Serde and Wire Format (HIGH)
- `serde-rename-camelcase` - Use rename_all camelCase on wire types
- `serde-params-response-naming` - Use Params/Response/Notification naming
- `serde-no-skip-v2` - Avoid skip_serializing_if for v2 API fields
- `serde-ts-export` - Align serde and ts-rs annotations
- `serde-tagged-unions` - Use explicit tag for discriminated unions
- `serde-string-ids` - Use plain String IDs at API boundaries

### Async and Concurrency (MEDIUM-HIGH)
- `async-box-pin-stack` - Use Box::pin for large async stack frames
- `async-channel-selection` - Use appropriate channel types
- `async-cancellation-token` - Use CancellationToken for shutdown coordination
- `async-notify-coordination` - Use Arc Notify for task completion signaling
- `async-fire-forget-send` - Use let _ = tx.send() for fire-and-forget

### Config System (MEDIUM)
- `cfg-write-config-schema` - Run just write-config-schema after config changes
- `cfg-bazel-lock-update` - Run just bazel-lock-update after dependency changes
- `cfg-feature-flag-lifecycle` - Follow the feature flag lifecycle stages
- `cfg-include-str-bazel` - Update BUILD.bazel for compile-time file access

### TUI Conventions (MEDIUM)
- `tui-stylize-helpers` - Use ratatui Stylize trait helpers
- `tui-no-hardcoded-white` - Avoid hardcoded .white() color
- `tui-textwrap-helpers` - Use textwrap and word_wrap_lines
- `tui-mirror-implementations` - Mirror changes between tui and tui_app_server

### Build and CI (LOW-MEDIUM)
- `ci-just-fmt` - Run just fmt after Rust changes
- `ci-just-fix-scoped` - Use scoped just fix -p for Clippy
- `ci-collapsible-if` - Collapse nested if statements
- `ci-inline-format-args` - Inline format arguments in format! macros

## How to Use

1. **Before writing code**: Review the CRITICAL rules (Error Handling, Type Design) as they prevent the most impactful bugs.
2. **During implementation**: Follow Module Organization and Serde rules to maintain codebase consistency.
3. **Before committing**: Run `just fmt` and `just fix -p <crate>` per the Build and CI rules.
4. **When changing config/deps**: Follow Config System rules to avoid CI failures.

## Reference Files

| File | Description |
|------|-------------|
| `references/_sections.md` | Section definitions and ordering |
| `references/err-*.md` | Error handling rules (6 files) |
| `references/type-*.md` | Type design rules (6 files) |
| `references/mod-*.md` | Module organization rules (5 files) |
| `references/serde-*.md` | Serde and wire format rules (6 files) |
| `references/async-*.md` | Async and concurrency rules (5 files) |
| `references/cfg-*.md` | Config system rules (4 files) |
| `references/tui-*.md` | TUI convention rules (4 files) |
| `references/ci-*.md` | Build and CI rules (4 files) |
