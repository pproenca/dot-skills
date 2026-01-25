---
title: Use assert_fs for Temporary Test Files
impact: LOW-MEDIUM
impactDescription: enables clean file-based testing without pollution
tags: test, assert-fs, temp-files, fixtures, isolation
---

## Use assert_fs for Temporary Test Files

Use `assert_fs` to create temporary files and directories for testing file-based CLI operations.

**Incorrect (hardcoded test files):**

```rust
#[test]
fn test_file_processing() {
    // Requires test file to exist in repo
    let mut cmd = Command::cargo_bin("myapp").unwrap();
    cmd.args(["--input", "tests/fixtures/test.json"])
        .assert()
        .success();
    // Output file left behind after test
}
```

**Correct (temporary files with assert_fs):**

```rust
use assert_fs::prelude::*;
use assert_fs::TempDir;

#[test]
fn test_file_processing() {
    let temp = TempDir::new().unwrap();

    let input = temp.child("input.json");
    input.write_str(r#"{"key": "value"}"#).unwrap();

    let output = temp.child("output.yaml");

    let mut cmd = Command::cargo_bin("myapp").unwrap();
    cmd.args([
        "--input", input.path().to_str().unwrap(),
        "--output", output.path().to_str().unwrap(),
    ])
    .assert()
    .success();

    output.assert(predicate::str::contains("key: value"));

    // temp directory automatically cleaned up
}

#[test]
fn test_output_directory_creation() {
    let temp = TempDir::new().unwrap();
    let output = temp.child("nested/dir/output.txt");

    let mut cmd = Command::cargo_bin("myapp").unwrap();
    cmd.args(["--output", output.path().to_str().unwrap()])
        .assert()
        .success();

    output.assert(predicate::path::exists());
}
```

Reference: [assert_fs Documentation](https://docs.rs/assert_fs/)
