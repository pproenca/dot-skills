---
title: Use Sorted Collections for Reproducible Serialization
impact: MEDIUM
impactDescription: eliminates HashMap-ordering-dependent test failures across platforms
tags: det, ordering, collections, serialization
---

## Use Sorted Collections for Reproducible Serialization

When test assertions involve serialized collection output (JSON, Debug, Display), use `BTreeMap`/`BTreeSet` instead of `HashMap`/`HashSet`. Sorted collections produce identical output across platforms, Rust versions, and runs. This is essential for snapshot tests and string-based assertions.

**Incorrect (HashSet ordering varies between runs):**

```rust
#[test]
fn test_feature_flags_display() {
    let mut flags = HashSet::new();
    flags.insert("streaming");
    flags.insert("apply_patch");
    flags.insert("shell");
    let display = format!("{flags:?}");
    assert_eq!(display, r#"{"apply_patch", "shell", "streaming"}"#);
    // HashSet order is nondeterministic — flaky on different platforms
}
```

**Correct (BTreeSet guarantees sorted output):**

```rust
#[test]
fn test_feature_flags_display() {
    let mut flags = BTreeSet::new();
    flags.insert("apply_patch");
    flags.insert("shell");
    flags.insert("streaming");
    let display = format!("{flags:?}");
    assert_eq!(display, r#"{"apply_patch", "shell", "streaming"}"#);
    // BTreeSet always iterates in sorted order — deterministic
}
```
