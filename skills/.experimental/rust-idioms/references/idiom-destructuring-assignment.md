---
title: Use Destructuring for Multiple Returns and Field Access
impact: MEDIUM
impactDescription: reduces temporary variables, makes intent clear
tags: idiom, destructuring, pattern-matching, tuple, struct
---

## Use Destructuring for Multiple Returns and Field Access

Use pattern matching to destructure tuples, structs, and enums directly. This eliminates intermediate variables and makes code more readable.

**Incorrect (manual field access):**

```rust
fn process_response(response: Response) {
    let status = response.status;
    let body = response.body;
    let headers = response.headers;

    if status == 200 {
        handle_success(body, headers);
    }
}

fn split_name(full_name: &str) -> (&str, &str) {
    let parts: Vec<&str> = full_name.splitn(2, ' ').collect();
    (parts[0], parts.get(1).unwrap_or(&""))
}

fn main() {
    let result = split_name("Alice Smith");
    let first = result.0;
    let last = result.1;
}
```

**Correct (destructuring patterns):**

```rust
fn process_response(response: Response) {
    let Response { status, body, headers } = response;

    if status == 200 {
        handle_success(body, headers);
    }
}

fn split_name(full_name: &str) -> (&str, &str) {
    full_name.split_once(' ').unwrap_or((full_name, ""))
}

fn main() {
    let (first, last) = split_name("Alice Smith");
    println!("{} {}", first, last);
}
```

**Destructuring in function parameters:**

```rust
// Destructure in signature
fn print_point(&(x, y): &(i32, i32)) {
    println!("({}, {})", x, y);
}

// Destructure struct
fn greet(User { name, age, .. }: &User) {
    println!("{} is {} years old", name, age);
}
```

Reference: [Patterns - Rust Book](https://doc.rust-lang.org/book/ch18-03-pattern-syntax.html)
