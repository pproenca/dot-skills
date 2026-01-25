---
title: Use trycmd for Snapshot Testing
impact: LOW
impactDescription: enables bulk CLI testing with minimal boilerplate
tags: test, trycmd, snapshot, bulk, maintenance
---

## Use trycmd for Snapshot Testing

Use `trycmd` for snapshot-based testing of CLI outputs. This reduces test boilerplate and catches unexpected changes.

**Incorrect (many individual tests):**

```rust
#[test]
fn test_help() { /* ... */ }
#[test]
fn test_version() { /* ... */ }
#[test]
fn test_error_missing_arg() { /* ... */ }
#[test]
fn test_error_invalid_arg() { /* ... */ }
// Many similar tests with slight variations
```

**Correct (trycmd snapshot tests):**

Create test files in `tests/cmd/`:

```console
$ cat tests/cmd/help.toml
bin.name = "myapp"
args = ["--help"]
status.code = 0
```

```console
$ cat tests/cmd/help.stdout
myapp 1.0.0
Process data files

Usage: myapp [OPTIONS] --input <FILE>

Options:
  -i, --input <FILE>   Input file path
  -o, --output <FILE>  Output file path
  -h, --help           Print help
  -V, --version        Print version
```

```rust
// tests/cli.rs
#[test]
fn test_cli() {
    trycmd::TestCases::new()
        .case("tests/cmd/*.toml")
        .run();
}
```

**Benefits:**
- Automatic snapshot updates with `TRYCMD=overwrite`
- Readable test cases in TOML files
- Easy to add new test cases

Reference: [trycmd Documentation](https://docs.rs/trycmd/)
