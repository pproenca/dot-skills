---
title: Use AsRef<T> for Generic Borrows
impact: CRITICAL
impactDescription: eliminates allocation for borrowed callers
tags: own, asref, generic, borrow, flexibility
---

## Use AsRef<T> for Generic Borrows

`AsRef<T>` allows functions to accept both owned and borrowed types without allocation. It's more flexible than accepting a specific reference type.

**Incorrect (separate functions for each type):**

```rust
fn read_file_from_str(path: &str) -> std::io::Result<Vec<u8>> {
    std::fs::read(path)
}

fn read_file_from_path(path: &Path) -> std::io::Result<Vec<u8>> {
    std::fs::read(path)
}

fn read_file_from_pathbuf(path: &PathBuf) -> std::io::Result<Vec<u8>> {
    std::fs::read(path)
}
```

**Correct (single generic function):**

```rust
use std::path::Path;

fn read_file(path: impl AsRef<Path>) -> std::io::Result<Vec<u8>> {
    std::fs::read(path.as_ref())
}

fn main() {
    read_file("config.toml");           // &str
    read_file(Path::new("config.toml")); // &Path
    read_file(PathBuf::from("config.toml")); // PathBuf

    let path = String::from("config.toml");
    read_file(&path);  // &String via AsRef<Path>
}
```

**Common AsRef bounds:**
- `AsRef<Path>` for filesystem operations
- `AsRef<str>` for string operations
- `AsRef<[u8]>` for byte operations

Reference: [Rust API Guidelines - C-CALLER-CONTROL](https://rust-lang.github.io/api-guidelines/flexibility.html)
