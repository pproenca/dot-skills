---
title: Use the Question Mark Operator for Error Propagation
impact: HIGH
impactDescription: reduces error handling boilerplate by 60%
tags: err, question-mark, propagation, result, option
---

## Use the Question Mark Operator for Error Propagation

Use `?` to propagate errors instead of explicit `match` or `unwrap`. It automatically converts and returns errors.

**Incorrect (verbose match-based propagation):**

```rust
use std::fs::File;
use std::io::{self, BufReader, BufRead};

fn read_username_from_file() -> Result<String, io::Error> {
    let file = match File::open("username.txt") {
        Ok(f) => f,
        Err(e) => return Err(e),
    };

    let mut reader = BufReader::new(file);
    let mut username = String::new();

    match reader.read_line(&mut username) {
        Ok(_) => Ok(username.trim().to_string()),
        Err(e) => Err(e),
    }
}
```

**Correct (question mark operator):**

```rust
use std::fs::File;
use std::io::{self, BufReader, BufRead};

fn read_username_from_file() -> Result<String, io::Error> {
    let file = File::open("username.txt")?;
    let mut reader = BufReader::new(file);
    let mut username = String::new();
    reader.read_line(&mut username)?;
    Ok(username.trim().to_string())
}
```

**Even more concise:**

```rust
fn read_username_from_file() -> Result<String, io::Error> {
    let mut username = String::new();
    File::open("username.txt")?.read_to_string(&mut username)?;
    Ok(username.trim().to_string())
}
```

**Note:** `?` also works on `Option<T>`, returning `None` early if the value is `None`.

Reference: [The ? Operator - Rust Book](https://doc.rust-lang.org/book/ch09-02-recoverable-errors-with-result.html)
