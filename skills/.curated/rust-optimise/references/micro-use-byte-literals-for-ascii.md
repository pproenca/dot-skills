---
title: Use Byte Literals for ASCII Operations
impact: LOW
impactDescription: avoids char-to-byte conversion
tags: micro, byte, ascii, char, string
---

## Use Byte Literals for ASCII Operations

When working with ASCII text, use byte strings (`b"..."`) and byte literals (`b'x'`) instead of char operations to avoid UTF-8 overhead.

**Incorrect (char comparison with UTF-8 overhead):**

```rust
fn count_newlines(text: &str) -> usize {
    text.chars().filter(|&c| c == '\n').count()
}

fn is_csv_header(line: &str) -> bool {
    line.starts_with("id,")
}
```

**Correct (byte operations for ASCII):**

```rust
fn count_newlines(text: &str) -> usize {
    text.as_bytes().iter().filter(|&&b| b == b'\n').count()
}

fn is_csv_header(line: &str) -> bool {
    line.as_bytes().starts_with(b"id,")
}
```

**For mutable ASCII processing:**

```rust
fn to_uppercase_ascii(text: &mut [u8]) {
    for byte in text {
        if *byte >= b'a' && *byte <= b'z' {
            *byte -= 32;  // ASCII lowercase to uppercase
        }
    }
}
```

**When char IS needed:**
- Non-ASCII Unicode text
- When you need grapheme boundaries
- When using char-specific methods

Reference: [Rust Book - Strings](https://doc.rust-lang.org/book/ch08-02-strings.html)
