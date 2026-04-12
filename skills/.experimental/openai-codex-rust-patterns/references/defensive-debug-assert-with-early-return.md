---
title: Use debug_assert with safe fallback on unreachable branches
impact: CRITICAL
impactDescription: prevents release-mode panics while keeping bugs loud in tests
tags: defensive, debug-assert, panic-discipline, graceful-degradation
---

## Use debug_assert with safe fallback on unreachable branches

`unreachable!()` and `panic!()` fire in both debug and release, so a single wrong assumption crashes production. Codex reaches for `debug_assert!(false, "…")` followed by an early `return` with a conservative fallback: loud failure in tests, graceful degradation in release. This is strictly distinct from `unreachable!()`, which is reserved for cases the type system already ruled out.

**Incorrect (panics in production when a new git subcommand is added):**

```rust
match subcommand {
    "status" | "diff" | "log" => true,
    other => panic!("unexpected git subcommand: {other}"),
}
```

**Correct (loud in debug, safe in release):**

```rust
// shell-command/src/command_safety/is_safe_command.rs
match subcommand {
    "status" | "diff" | "log" => true,
    other => {
        debug_assert!(false, "unexpected git subcommand from matcher: {other}");
        false
    }
}
```

The fallback chooses the *safer* answer — `false` for "is this command safe?" — so a missed invariant never weakens security when it matters most. Tests observe the assertion and catch the regression during development; production users see a command fall through to the approval path instead of a crash.

Reference: `codex-rs/shell-command/src/command_safety/is_safe_command.rs:161`, `codex-rs/core/src/codex_thread.rs:149`.
