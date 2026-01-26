---
title: Use TempDir for File System Tests
impact: MEDIUM
impactDescription: prevents test pollution and ensures cleanup
tags: fix, tempfile, filesystem, isolation, cleanup
---

## Use TempDir for File System Tests

Use `tempfile::TempDir` for tests that create files. The directory is automatically deleted when dropped, preventing test pollution.

**Incorrect (files persist after test):**

```rust
#[test]
fn test_write_config() {
    let path = "/tmp/test_config.toml";
    write_config(path, &config).unwrap();

    let loaded = read_config(path).unwrap();
    assert_eq!(loaded, config);
    // File persists after test - may interfere with other tests!
}

#[test]
fn test_backup_file() {
    std::fs::write("/tmp/original.txt", "content").unwrap();
    backup_file("/tmp/original.txt").unwrap();
    // Files left behind, may conflict with parallel tests
}
```

**Correct (tempdir auto-cleanup):**

```rust
use tempfile::TempDir;

#[test]
fn test_write_config() {
    let temp_dir = TempDir::new().unwrap();
    let config_path = temp_dir.path().join("config.toml");

    write_config(&config_path, &config).unwrap();
    let loaded = read_config(&config_path).unwrap();

    assert_eq!(loaded, config);
    // temp_dir dropped here - all files deleted automatically
}

#[test]
fn test_backup_file() {
    let temp_dir = TempDir::new().unwrap();
    let original = temp_dir.path().join("original.txt");

    std::fs::write(&original, "content").unwrap();
    backup_file(&original).unwrap();

    let backup = temp_dir.path().join("original.txt.bak");
    assert!(backup.exists());
    // Cleanup happens automatically
}
```

**Preserve temp dir on failure for debugging:**

```rust
#[test]
fn test_complex_file_operation() {
    let temp_dir = TempDir::new().unwrap();
    let temp_path = temp_dir.path().to_owned();

    // Do test work...
    let result = process_files(temp_dir.path());

    if result.is_err() {
        // Keep files for debugging
        let preserved = temp_dir.into_path();  // Prevents auto-delete
        eprintln!("Test failed, files preserved at: {:?}", preserved);
    }

    result.unwrap();
}
```

**With assert_fs for richer assertions:**

```rust
use assert_fs::prelude::*;

#[test]
fn test_creates_output_files() {
    let temp = assert_fs::TempDir::new().unwrap();
    let input = temp.child("input.txt");
    input.write_str("line1\nline2\nline3").unwrap();

    process_file(input.path(), temp.path()).unwrap();

    temp.child("output.txt").assert(predicate::path::exists());
    temp.child("output.txt").assert(predicate::str::contains("processed"));
}
```

**Cargo.toml:**

```toml
[dev-dependencies]
tempfile = "3.10"
assert_fs = "1.1"
```

Reference: [tempfile crate documentation](https://docs.rs/tempfile)
