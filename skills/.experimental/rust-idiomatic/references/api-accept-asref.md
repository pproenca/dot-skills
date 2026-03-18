---
title: Accept impl AsRef for Flexible String Parameters
impact: MEDIUM
impactDescription: 3-5x fewer conversion calls at callsites
tags: api, asref, generics, string-parameters, ergonomics
---

## Accept impl AsRef for Flexible String Parameters

Accept `impl AsRef<str>` or `impl AsRef<Path>` for parameters that only need read access to the underlying data. This accepts `&str`, `String`, `&String`, `Cow<str>`, and other string-like types without requiring callers to convert.

**Incorrect (only accepts &str, callers must convert):**

```rust
fn resolve_config_path(filename: &str) -> PathBuf {
    let base = config_directory();
    base.join(filename)
}
// Callsite: resolve_config_path(&my_string)
// Callsite: resolve_config_path(my_cow.as_ref())
```

**Correct (accepts any string-like type):**

```rust
fn resolve_config_path(filename: impl AsRef<Path>) -> PathBuf {
    let base = config_directory();
    base.join(filename)
}
// Callsite: resolve_config_path("config.toml")
// Callsite: resolve_config_path(my_string)
// Callsite: resolve_config_path(my_pathbuf)
```
