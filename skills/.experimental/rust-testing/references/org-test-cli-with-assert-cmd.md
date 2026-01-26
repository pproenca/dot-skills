---
title: Use assert_cmd for CLI Binary Testing
impact: HIGH
impactDescription: enables end-to-end CLI testing without manual process spawning
tags: org, cli, assert-cmd, binary-testing, integration
---

## Use assert_cmd for CLI Binary Testing

Use `assert_cmd` to test CLI binaries end-to-end. It provides ergonomic assertions on exit codes, stdout, and stderr without manual `std::process::Command` handling.

**Incorrect (manual process spawning):**

```rust
// tests/cli_tests.rs
use std::process::Command;

#[test]
fn test_help_flag() {
    let output = Command::new("cargo")
        .args(["run", "--", "--help"])
        .output()
        .expect("Failed to execute command");

    assert!(output.status.success());
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert!(stdout.contains("Usage:"));  // Manual string parsing
}

#[test]
fn test_missing_file() {
    let output = Command::new("cargo")
        .args(["run", "--", "nonexistent.txt"])
        .output()
        .expect("Failed to execute command");

    assert!(!output.status.success());
    // Have to manually check exit code and stderr
}
```

**Correct (using assert_cmd):**

```rust
// tests/cli_tests.rs
use assert_cmd::Command;
use predicates::prelude::*;

#[test]
fn test_help_flag() {
    Command::cargo_bin("myapp")
        .unwrap()
        .arg("--help")
        .assert()
        .success()
        .stdout(predicate::str::contains("Usage:"));
}

#[test]
fn test_missing_file() {
    Command::cargo_bin("myapp")
        .unwrap()
        .arg("nonexistent.txt")
        .assert()
        .failure()
        .code(1)
        .stderr(predicate::str::contains("No such file"));
}

#[test]
fn test_version_format() {
    Command::cargo_bin("myapp")
        .unwrap()
        .arg("--version")
        .assert()
        .success()
        .stdout(predicate::str::is_match(r"^myapp \d+\.\d+\.\d+\n$").unwrap());
}
```

**Cargo.toml:**

```toml
[dev-dependencies]
assert_cmd = "2.0"
predicates = "3.1"
```

**Benefits:**
- `Command::cargo_bin()` finds your compiled binary automatically
- Fluent assertion API for exit codes, stdout, stderr
- `predicates` crate enables regex matching and complex assertions
- Tests run against the actual compiled binary

Reference: [assert_cmd crate documentation](https://docs.rs/assert_cmd)
