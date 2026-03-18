---
title: Use find_resource for Bazel-Compatible Fixture Paths
impact: LOW-MEDIUM
impactDescription: 100% fixture path resolution under both Cargo and Bazel
tags: integ, find-resource, bazel, fixtures
---

## Use find_resource for Bazel-Compatible Fixture Paths

Use `codex_utils_cargo_bin::find_resource!` instead of `env!("CARGO_MANIFEST_DIR")` when locating fixture files or test resources. Under Bazel, source files live under runfiles with different paths than Cargo's layout. The `find_resource!` macro resolves paths correctly under both build systems.

**Incorrect (CARGO_MANIFEST_DIR fails under Bazel):**

```rust
#[test]
fn test_parse_fixture() {
    let fixture_path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("tests/fixtures/sample.json");
    let content = std::fs::read_to_string(&fixture_path).unwrap();
    // Fails under Bazel: CARGO_MANIFEST_DIR points to wrong location
}
```

**Correct (find_resource resolves under both Cargo and Bazel):**

```rust
use codex_utils_cargo_bin::find_resource;

#[test]
fn test_parse_fixture() {
    let fixture_path = find_resource!("tests/fixtures/sample.json");
    let content = std::fs::read_to_string(&fixture_path).unwrap();
    // Works under both Cargo and Bazel runfiles
}
```
