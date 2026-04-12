---
title: Attach tests as sibling files via a path attribute
impact: MEDIUM-HIGH
impactDescription: prevents 5000-line modules where implementation hides inside a mile-long test body
tags: testing, organization, modules, path-attribute
---

## Attach tests as sibling files via a path attribute

The default Rust convention — `#[cfg(test)] mod tests { ... }` at the bottom of every module — stops scaling around 400 lines. Scrolling past a 2000-line test body to find the implementation is painful, and `git blame` attributes test changes to whoever last touched the module. Codex ends every module file with a three-line stub and keeps the tests in a sibling `foo_tests.rs` at the same path depth. `use super::*;` still gives access to `pub(crate)` items without a public test API.

**Incorrect (inline mod tests — implementation drowns in tests):**

```rust
// core/src/arc_monitor.rs — 500 lines of implementation ...

#[cfg(test)]
mod tests {
    use super::*;
    // ... 2000 lines of tests inside this file
    #[test]
    fn exercises_arc_monitor() { /* ... */ }
}
```

**Correct (sibling tests file via #[path]):**

```rust
// core/src/arc_monitor.rs — ends with this 3-line stub
#[cfg(test)]
#[path = "arc_monitor_tests.rs"]
mod tests;

// core/src/arc_monitor_tests.rs — lives next to arc_monitor.rs
use super::*;

#[test]
fn exercises_arc_monitor() {
    /* ... */
}

// core/src/codex_tests.rs — nested when even the sibling is huge
#[path = "codex_tests_guardian.rs"]
mod guardian_tests;
```

`ls core/src` shows over 60 `foo.rs` / `foo_tests.rs` pairs — this is house style, not a one-off. The nested `#[path]` inside `codex_tests.rs` is the escape hatch when even the sibling file hits 5000 lines. Tests still see `pub(crate)` items because they compile as a child module of the parent, same as inline tests.

Reference: `codex-rs/core/src/arc_monitor.rs:428`, `codex-rs/core/src/codex_tests.rs:125`.
