---
title: Avoid format! for Simple Concatenation
impact: CRITICAL
impactDescription: eliminates allocation for string literals
tags: mem, format, string, concat, allocation
---

## Avoid format! for Simple Concatenation

The `format!` macro always allocates a new `String`. For simple concatenation or when a reference suffices, avoid it entirely.

**Incorrect (allocates new String):**

```rust
fn get_error_message(code: u32) -> String {
    format!("Error: {}", code)  // Allocates every call
}

fn log_with_prefix(msg: &str) {
    let prefixed = format!("[INFO] {}", msg);  // Allocates
    println!("{}", prefixed);
}
```

**Correct (no intermediate allocation):**

```rust
fn get_error_message(code: u32) -> String {
    let mut msg = String::from("Error: ");
    msg.push_str(&code.to_string());  // Reuses msg's buffer
    msg
}

fn log_with_prefix(msg: &str) {
    println!("[INFO] {}", msg);  // Direct to stdout, no intermediate
}
```

**Alternative (preallocate with capacity):**

```rust
fn get_error_message(code: u32) -> String {
    let code_str = code.to_string();
    let mut msg = String::with_capacity(7 + code_str.len());
    msg.push_str("Error: ");
    msg.push_str(&code_str);
    msg
}
```

Reference: [Heap Allocations - The Rust Performance Book](https://nnethercote.github.io/perf-book/heap-allocations.html)
