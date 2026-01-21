---
title: Co-locate Tests as test.rs Files
impact: HIGH
impactDescription: Co-located tests are easier to maintain and update alongside the code they test
tags: mod, testing, test-organization, colocated
---

## Co-locate Tests as test.rs Files

Place unit tests in a `test.rs` file within the same directory as the code being tested. Use `#[cfg(test)]` to conditionally compile.

**Incorrect (problematic pattern):**

```text
crate/
├── src/
│   ├── lib.rs
│   └── reader.rs
└── tests/                 # Separate directory
    ├── reader_tests.rs    # Far from source
    └── types_tests.rs     # Hard to keep in sync
```text

**Correct (recommended pattern):**

```
crate/src/
├── lib.rs
├── reader.rs
├── types.rs
└── test.rs           # Co-located with source
```

```rust
// lib.rs
mod types;
mod reader;

pub use types::*;
pub use reader::*;

#[cfg(test)]
mod test;  // Only compiled during tests
```

```rust
// test.rs
use super::*;

#[test]
fn test_reader_parses_stat() {
    let reader = ProcReader::new();
    let stat = reader.read_stat().unwrap();
    assert!(stat.cpu_count > 0);
}

#[test]
fn test_types_default_values() {
    let info = MemInfo::default();
    assert_eq!(info.total, None);
}
```

**When NOT to use:**
- Integration tests that need separate binaries (use `tests/` directory)
- Tests requiring complex fixtures (consider `tests/` with shared fixtures)
