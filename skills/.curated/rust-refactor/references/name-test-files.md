---
title: Name Test Files as test.rs
impact: LOW
impactDescription: Consistent test file naming makes test location predictable
tags: name, testing, files, convention
---

## Name Test Files as test.rs

Test modules use `test.rs` as the standard name. Use descriptive prefixes like `sudotest.rs` only for specialized test categories.

**Incorrect (problematic pattern):**

```text
src/
├── lib.rs
├── reader.rs
├── tests.rs           # Wrong: plural
├── testing.rs         # Wrong: gerund
├── reader_tests.rs    # Wrong: per-module test files
└── unit_tests.rs      # Wrong: category prefix
```text

**Correct (recommended pattern):**

```
src/
├── lib.rs
├── reader.rs
├── types.rs
└── test.rs            # Standard: singular 'test'
```text

```rust
// lib.rs
mod reader;
mod types;

#[cfg(test)]
mod test;
```

```
// For specialized test categories
src/
├── lib.rs
├── test.rs            # Regular unit tests
└── sudotest.rs        # Tests requiring sudo/root
```

```rust
// lib.rs
#[cfg(test)]
mod test;

#[cfg(test)]
#[cfg(feature = "sudo_tests")]
mod sudotest;
```

**When NOT to use:**
- Integration tests in `tests/` directory (use descriptive names there)
- Example tests (use `examples/` directory with descriptive names)
