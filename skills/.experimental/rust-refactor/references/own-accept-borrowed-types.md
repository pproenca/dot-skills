---
title: Accept Borrowed Types Over Owned References
impact: CRITICAL
impactDescription: 2× input type flexibility with single function signature
tags: own, borrowing, str, slice, generics, ergonomics
---

## Accept Borrowed Types Over Owned References

Accept `&str` instead of `&String` and `&[T]` instead of `&Vec<T>`. Borrowed types accept more input types.

**Incorrect (accepts only &String):**

```rust
fn count_words(text: &String) -> usize {
    text.split_whitespace().count()
}

fn main() {
    let owned = String::from("hello world");
    let literal = "hello world";

    count_words(&owned);    // Works
    // count_words(literal);  // Error: expected &String, found &str
}
```

**Correct (accepts both &str and &String):**

```rust
fn count_words(text: &str) -> usize {
    text.split_whitespace().count()
}

fn main() {
    let owned = String::from("hello world");
    let literal = "hello world";

    count_words(&owned);   // Works - String derefs to &str
    count_words(literal);  // Works - &str directly
}
```

**Common pairs:**

| Instead of | Use |
|------------|-----|
| `&String` | `&str` |
| `&Vec<T>` | `&[T]` |
| `&Box<T>` | `&T` |
| `&PathBuf` | `&Path` |
| `&OsString` | `&OsStr` |

Reference: [Prefer Borrowed Types - Rust API Guidelines](https://rust-lang.github.io/api-guidelines/flexibility.html)
