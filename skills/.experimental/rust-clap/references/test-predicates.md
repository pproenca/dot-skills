---
title: Use Predicates for Flexible Assertions
impact: LOW-MEDIUM
impactDescription: enables powerful output matching without brittle exact matches
tags: test, predicates, assertions, matching, flexible
---

## Use Predicates for Flexible Assertions

Use the `predicates` crate for flexible assertions that don't break on minor output changes.

**Incorrect (exact string matching):**

```rust
#[test]
fn test_error_output() {
    let mut cmd = Command::cargo_bin("myapp").unwrap();
    cmd.arg("--invalid")
        .assert()
        .failure()
        .stderr("error: unexpected argument '--invalid' found\n");  // Breaks on any format change
}
```

**Correct (predicate matching):**

```rust
use predicates::prelude::*;

#[test]
fn test_error_output() {
    let mut cmd = Command::cargo_bin("myapp").unwrap();
    cmd.arg("--invalid")
        .assert()
        .failure()
        .stderr(predicate::str::contains("unexpected argument"))
        .stderr(predicate::str::contains("--invalid"));
}

#[test]
fn test_json_output() {
    let mut cmd = Command::cargo_bin("myapp").unwrap();
    cmd.args(["--format", "json", "--input", "test.json"])
        .assert()
        .success()
        .stdout(predicate::str::starts_with("{"))
        .stdout(predicate::str::ends_with("}\n"));
}

#[test]
fn test_no_error_output() {
    let mut cmd = Command::cargo_bin("myapp").unwrap();
    cmd.args(["--input", "valid.txt"])
        .assert()
        .success()
        .stderr(predicate::str::is_empty());
}
```

**Common predicates:**
- `contains("text")` - substring match
- `starts_with("text")` - prefix match
- `is_match(regex)` - regex match
- `is_empty()` - empty output

Reference: [predicates Documentation](https://docs.rs/predicates/)
