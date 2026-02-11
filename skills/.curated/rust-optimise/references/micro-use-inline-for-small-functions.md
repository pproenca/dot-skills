---
title: Apply inline Attribute to Small Hot Functions
impact: LOW
impactDescription: eliminates function call overhead
tags: micro, inline, hot-path, optimization, call-overhead
---

## Apply inline Attribute to Small Hot Functions

Small functions called frequently benefit from `#[inline]`. This eliminates call overhead and enables further optimizations.

**Incorrect (function call overhead on hot path):**

```rust
fn is_whitespace(c: char) -> bool {
    c == ' ' || c == '\t' || c == '\n'
}

fn count_words(text: &str) -> usize {
    text.split(|c| is_whitespace(c)).filter(|s| !s.is_empty()).count()
}
```

**Correct (inlined for hot paths):**

```rust
#[inline]
fn is_whitespace(c: char) -> bool {
    c == ' ' || c == '\t' || c == '\n'
}

fn count_words(text: &str) -> usize {
    text.split(|c| is_whitespace(c)).filter(|s| !s.is_empty()).count()
}
```

**Inline variants:**
- `#[inline]`: Hint to inline (cross-crate)
- `#[inline(always)]`: Force inline (use sparingly)
- `#[inline(never)]`: Prevent inlining (for debugging)

**When NOT to use:**
- Large functions (increases code size)
- Rarely called functions
- Functions already in the same compilation unit (LLVM decides)

Reference: [The Rust Performance Book - Inlining](https://nnethercote.github.io/perf-book/inlining.html)
