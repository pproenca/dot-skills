---
title: Run cargo test -p for Scoped Test Execution
impact: LOW-MEDIUM
impactDescription: 5-10x faster feedback by running only affected crate tests
tags: integ, cargo-test, scoped, workflow
---

## Run cargo test -p for Scoped Test Execution

Run tests scoped to the specific crate that changed using `cargo test -p codex-<crate>`. Avoid running the full workspace test suite unless changes affect shared crates (core, common, protocol). Scoped execution provides 5-10x faster feedback during development.

**Incorrect (running all workspace tests for a single-crate change):**

```rust
// Changed only codex-rs/tui/src/diff_render.rs
// $ cargo test
// Runs tests for all 20+ crates — takes 5+ minutes
```

**Correct (scoped to the affected crate):**

```rust
// Changed only codex-rs/tui/src/diff_render.rs
// $ cargo test -p codex-tui
// Runs only TUI crate tests — takes 30 seconds

// If shared crates changed (core, common, protocol):
// $ cargo test
// Full suite justified when shared code changes
```
