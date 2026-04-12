---
title: Enable test-only behavior via AtomicBool, not a cargo feature
impact: MEDIUM-HIGH
impactDescription: avoids doubling the build matrix while keeping deterministic IDs for tests
tags: testing, test-apis, atomic, determinism
---

## Enable test-only behavior via AtomicBool, not a cargo feature

A `#[cfg(feature = "test")]` path doubles the build matrix and still breaks downstream integration test crates that compile against the production build. Codex exposes `pub(crate) fn with_..._for_tests(...)` constructors with explicit "not for production" doc comments, and for determinism reads a `static AtomicBool` that only tests set to `true`. A single cargo build produces a binary that behaves deterministically when asked and identically to production otherwise — no `#[cfg]` branches in the hot path.

**Incorrect (cargo feature fragments the build graph):**

```rust
#[cfg(feature = "test-helpers")]
pub fn deterministic_process_id() -> String { "pid-0".into() }

#[cfg(not(feature = "test-helpers"))]
pub fn deterministic_process_id() -> String {
    format!("pid-{}", Uuid::new_v4())
}
// Integration tests in core/tests/ compile against non-test feature set.
```

**Correct (AtomicBool opt-in, single build):**

```rust
// core/src/unified_exec/process_manager.rs
/// Test-only override for deterministic unified exec process IDs.
///
/// In production builds this value should remain at its default (`false`)
/// and must not be toggled.
static FORCE_DETERMINISTIC_PROCESS_IDS: AtomicBool = AtomicBool::new(false);

pub(super) fn set_deterministic_process_ids_for_tests(enabled: bool) {
    FORCE_DETERMINISTIC_PROCESS_IDS.store(enabled, Ordering::Relaxed);
}

fn should_use_deterministic_process_ids() -> bool {
    cfg!(test) || deterministic_process_ids_forced_for_tests()
}

// core/src/test_support.rs — public gate for integration tests
//! Test-only helpers exposed for cross-crate integration tests.
//! Production code should not depend on this module. We prefer this
//! to a crate feature to avoid building multiple permutations.
```

`cfg!(test)` alone isn't enough because integration tests in `core/tests/` compile against the non-test build — the AtomicBool bridges that gap. The `_for_tests` suffix is how reviewers audit the test-only surface via grep.

Reference: `codex-rs/core/src/unified_exec/process_manager.rs:71`, `codex-rs/core/src/test_support.rs:1`.
