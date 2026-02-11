---
title: Accept AsRef for Flexible String Parameters
impact: MEDIUM
impactDescription: accepts String, &str, PathBuf, &Path with single signature
tags: conv, asref, generics, flexibility, ergonomics
---

## Accept AsRef for Flexible String Parameters

Use `impl AsRef<T>` for parameters to accept any type that can be cheaply converted to a reference of `T`.

**Incorrect (requires specific type):**

```rust
fn read_config(path: &str) -> Result<Config, Error> {
    let content = std::fs::read_to_string(path)?;
    // ...
}

fn main() {
    let path = PathBuf::from("/etc/config.toml");
    // read_config(&path);  // Error: expected &str, found &PathBuf
    read_config(path.to_str().unwrap());  // Awkward conversion
}
```

**Correct (accepts anything that refs to Path):**

```rust
fn read_config(path: impl AsRef<Path>) -> Result<Config, Error> {
    let content = std::fs::read_to_string(path.as_ref())?;
    // ...
}

fn main() {
    read_config("/etc/config.toml");           // &str works
    read_config(String::from("/etc/config"));  // String works
    read_config(PathBuf::from("/etc/config")); // PathBuf works
}
```

**Common AsRef bounds:**

| Bound | Accepts |
|-------|---------|
| `AsRef<str>` | `String`, `&str`, `Cow<str>` |
| `AsRef<Path>` | `PathBuf`, `&Path`, `&str`, `String`, `OsString` |
| `AsRef<[u8]>` | `Vec<u8>`, `&[u8]`, `String`, `&str` |
| `AsRef<OsStr>` | `OsString`, `&OsStr`, `&str`, `String` |

**Note:** `AsRef` is for cheap reference conversions. Use `Into` for value conversions.

Reference: [AsRef - Rust Standard Library](https://doc.rust-lang.org/std/convert/trait.AsRef.html)
