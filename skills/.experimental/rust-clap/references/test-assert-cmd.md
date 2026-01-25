---
title: Use assert_cmd for Integration Testing
impact: LOW-MEDIUM
impactDescription: enables end-to-end CLI testing with proper assertions
tags: test, assert-cmd, integration, e2e, testing
---

## Use assert_cmd for Integration Testing

Use `assert_cmd` to test your CLI binary as users would invoke it, verifying outputs and exit codes.

**Incorrect (no integration tests):**

```rust
// Only unit tests that don't test the actual CLI interface
#[test]
fn test_parse() {
    let cli = Cli::parse_from(["myapp", "--input", "test.txt"]);
    assert_eq!(cli.input, PathBuf::from("test.txt"));
}
```

**Correct (full integration tests):**

```rust
// tests/cli.rs
use assert_cmd::Command;
use predicates::prelude::*;

#[test]
fn test_missing_required_arg() {
    let mut cmd = Command::cargo_bin("myapp").unwrap();
    cmd.assert()
        .failure()
        .stderr(predicate::str::contains("--input <FILE>"));
}

#[test]
fn test_help_output() {
    let mut cmd = Command::cargo_bin("myapp").unwrap();
    cmd.arg("--help")
        .assert()
        .success()
        .stdout(predicate::str::contains("Process data files"));
}

#[test]
fn test_version() {
    let mut cmd = Command::cargo_bin("myapp").unwrap();
    cmd.arg("--version")
        .assert()
        .success()
        .stdout(predicate::str::contains(env!("CARGO_PKG_VERSION")));
}
```

**Setup in Cargo.toml:**

```toml
[dev-dependencies]
assert_cmd = "2"
predicates = "3"
```

Reference: [assert_cmd Documentation](https://docs.rs/assert_cmd/)
