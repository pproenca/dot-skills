---
title: Use Inner Function Pattern to Reduce Monomorphization
impact: MEDIUM
impactDescription: reduces code bloat from generic functions
tags: conv, generics, monomorphization, code-size, inner-function
---

## Use Inner Function Pattern to Reduce Monomorphization

When using generic parameters only for conversion, extract the core logic into a non-generic inner function. This prevents code duplication from monomorphization.

**Incorrect (entire function monomorphized per type):**

```rust
pub fn process_path<P: AsRef<Path>>(path: P) -> Result<Data, Error> {
    let path = path.as_ref();
    // 100+ lines of complex logic
    let file = File::open(path)?;
    let mut content = String::new();
    file.read_to_string(&mut content)?;
    // More complex processing...
    parse_data(&content)
}

// Called with String, &str, PathBuf generates 3 copies of entire function
```

**Correct (only thin wrapper is generic):**

```rust
pub fn process_path<P: AsRef<Path>>(path: P) -> Result<Data, Error> {
    process_path_inner(path.as_ref())
}

fn process_path_inner(path: &Path) -> Result<Data, Error> {
    // 100+ lines of complex logic - only one copy in binary
    let file = File::open(path)?;
    let mut content = String::new();
    file.read_to_string(&mut content)?;
    // More complex processing...
    parse_data(&content)
}
```

**Benefits:**
- Caller still gets ergonomic generic API
- Complex logic compiled once, not per input type
- Reduces binary size significantly for large functions

**When to use:**
- Functions with generic bounds used only for conversion
- Complex logic where code bloat matters
- Hot paths where instruction cache matters

Reference: [Monomorphization - Rust Performance Book](https://nnethercote.github.io/perf-book/compile-times.html)
