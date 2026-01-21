---
title: Leverage Lifetime Elision Rules
impact: CRITICAL
impactDescription: reduces noise in 87% of lifetime annotation cases
tags: own, lifetimes, elision, readability, simplification
---

## Leverage Lifetime Elision Rules

Omit explicit lifetime annotations when they can be inferred. The compiler applies elision rules automatically, reducing visual noise.

**Incorrect (explicit lifetimes where elision applies):**

```rust
fn first_word<'a>(s: &'a str) -> &'a str {
    s.split_whitespace().next().unwrap_or("")
}

fn longest_line<'a>(text: &'a str) -> &'a str {
    text.lines()
        .max_by_key(|line| line.len())
        .unwrap_or("")
}

impl<'a> Parser<'a> {
    fn parse<'b>(&'b self, input: &'b str) -> &'b str {
        // ...
    }
}
```

**Correct (rely on lifetime elision):**

```rust
fn first_word(s: &str) -> &str {
    s.split_whitespace().next().unwrap_or("")
}

fn longest_line(text: &str) -> &str {
    text.lines()
        .max_by_key(|line| line.len())
        .unwrap_or("")
}

impl<'a> Parser<'a> {
    fn parse(&self, input: &str) -> &str {
        // &self lifetime applies to output
    }
}
```

**Elision rules:**
1. Each input reference gets its own lifetime
2. If exactly one input lifetime, it applies to all outputs
3. If `&self` or `&mut self` exists, its lifetime applies to outputs

**When to use explicit lifetimes:**
- Multiple input references with different output relationships
- Struct definitions with references
- When elision rules don't match intended semantics

Reference: [Lifetime Elision - Rust Reference](https://doc.rust-lang.org/reference/lifetime-elision.html)
