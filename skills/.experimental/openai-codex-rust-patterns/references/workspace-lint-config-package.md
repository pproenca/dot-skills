---
title: Encode design policy in workspace.lints and clippy.toml
impact: MEDIUM
impactDescription: prevents policy drift from review-only conventions
tags: workspace, lints, clippy, policy
---

## Encode design policy in workspace.lints and clippy.toml

Treating design rules as review-only conventions fails across 75 crates — one missed review lets the bad pattern proliferate. Codex writes ~30 clippy lints as `deny` in `[workspace.lints.clippy]` and then opts each leaf crate in with `[lints] workspace = true`. `clippy.toml` at the workspace root relaxes the ban inside tests (`allow-expect-in-tests = true`) and encodes *design rules* like "don't hard-code Rgb colors — use ANSI themes" via `disallowed-methods`. The `core/src/lib.rs` header layers crate-local `#![deny(clippy::print_stdout, clippy::print_stderr)]` to force library output through tracing.

**Incorrect (each crate opts in ad-hoc, policy drifts):**

```rust
// core/src/lib.rs
#![deny(clippy::unwrap_used)]
// tui/src/lib.rs -- forgot this header, lints don't apply
```

**Correct (workspace-wide denies, leaves opt in):**

```toml
# Cargo.toml (root)
[workspace.lints]
rust = {}

[workspace.lints.clippy]
expect_used = "deny"
unwrap_used = "deny"
manual_clamp = "deny"
needless_collect = "deny"
redundant_clone = "deny"
```

```toml
# clippy.toml (root)
allow-expect-in-tests = true
allow-unwrap-in-tests = true
disallowed-methods = [
    {
        path = "ratatui::style::Color::Rgb",
        reason = "Use ANSI colors, which work better in various terminal themes.",
    },
    {
        path = "ratatui::style::Stylize::yellow",
        reason = "Avoid yellow; prefer other colors in `tui/styles.md`.",
    },
]
large-error-threshold = 256
```

```rust
// core/src/lib.rs — crate-local augmentation
//! Prevent accidental direct writes to stdout/stderr in library code.
//! All user-visible output must go through the TUI or tracing stack.
#![deny(clippy::print_stdout, clippy::print_stderr)]
```

`large-error-threshold = 256` is a subtle choice that gates `result_large_err` up from the default to allow rich `thiserror` enums. `disallowed-methods` is the architectural enforcement mechanism — banning direct `Color::Rgb` frees code review to focus on logic.

Reference: `codex-rs/Cargo.toml:363`, `codex-rs/clippy.toml:1`, `codex-rs/core/src/lib.rs:1`.
