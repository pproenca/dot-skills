---
title: Use cargo_bin for Binary Resolution in Tests
impact: CRITICAL
impactDescription: 100% binary resolution success under both Cargo and Bazel
tags: arch, cargo-bin, bazel, binary-resolution
---

## Use cargo_bin for Binary Resolution in Tests

Use `codex_utils_cargo_bin::cargo_bin("binary_name")` instead of `assert_cmd::Command::cargo_bin` or `escargot` when tests need to spawn first-party binaries. Under Bazel, binaries live under runfiles and standard Cargo resolution fails. The `cargo_bin` utility resolves absolute paths that remain stable after `chdir`.

**Incorrect (Cargo-only binary resolution):**

```rust
#[test]
fn test_cli_help_output() {
    let output = assert_cmd::Command::cargo_bin("codex-exec")
        .unwrap()
        .arg("--help")
        .output()
        .unwrap();
    assert!(output.status.success());
}
```

**Correct (dual Cargo/Bazel binary resolution):**

```rust
#[test]
fn test_cli_help_output() {
    let bin_path = codex_utils_cargo_bin::cargo_bin("codex-exec")
        .expect("resolve codex-exec binary");
    let output = std::process::Command::new(bin_path)
        .arg("--help")
        .output()
        .unwrap();
    assert!(output.status.success());
}
```
