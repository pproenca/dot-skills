---
title: Use set_deterministic_process_ids in Tests
impact: MEDIUM
impactDescription: ensures snapshot tests produce stable output across all test runs
tags: det, deterministic-ids, snapshots, reproducibility
---

## Use set_deterministic_process_ids in Tests

Call `set_deterministic_process_ids(true)` via a `#[ctor]` function to ensure process IDs in test output are stable across runs. Without this, snapshot tests that include process IDs will produce different output on each run, causing spurious snapshot failures.

**Incorrect (process IDs vary between runs, breaking snapshots):**

```rust
// No deterministic ID setup
#[test]
fn test_exec_event_snapshot() {
    let event = build_exec_event();
    insta::assert_snapshot!(format!("{event:?}"));
    // Snapshot includes pid=48291 on one run, pid=7834 on the next
}
```

**Correct (ctor sets deterministic IDs before any test runs):**

```rust
use ctor::ctor;

#[ctor]
fn enable_deterministic_ids() {
    codex_core::test_support::set_deterministic_process_ids(/*enabled*/ true);
    codex_core::test_support::set_thread_manager_test_mode(/*enabled*/ true);
}

#[test]
fn test_exec_event_snapshot() {
    let event = build_exec_event();
    insta::assert_snapshot!(format!("{event:?}"));
    // Process IDs are stable: always produces the same snapshot
}
```
