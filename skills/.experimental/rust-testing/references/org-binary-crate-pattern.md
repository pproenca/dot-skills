---
title: Extract Logic from main.rs into lib.rs for Testing
impact: CRITICAL
impactDescription: enables integration testing of CLI logic
tags: org, binary-crate, lib-crate, cli-testing
---

## Extract Logic from main.rs into lib.rs for Testing

Move business logic from `src/main.rs` into `src/lib.rs`. Binary crates cannot be imported by integration tests, but library crates can. Keep `main.rs` as a thin wrapper.

**Incorrect (logic in main.rs, untestable by integration tests):**

```rust
// src/main.rs
use std::fs;

fn count_words(content: &str) -> usize {
    content.split_whitespace().count()
}

fn process_file(path: &str) -> Result<usize, std::io::Error> {
    let content = fs::read_to_string(path)?;
    Ok(count_words(&content))
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    if args.len() != 2 {
        eprintln!("Usage: wordcount <file>");
        std::process::exit(1);
    }
    match process_file(&args[1]) {
        Ok(count) => println!("{} words", count),
        Err(e) => eprintln!("Error: {}", e),
    }
}

// tests/integration.rs
// Cannot import process_file or count_words - they're in a binary crate!
```

**Correct (logic in lib.rs, testable):**

```rust
// src/lib.rs
use std::fs;

pub fn count_words(content: &str) -> usize {
    content.split_whitespace().count()
}

pub fn process_file(path: &str) -> Result<usize, std::io::Error> {
    let content = fs::read_to_string(path)?;
    Ok(count_words(&content))
}

// src/main.rs
use wordcount::{process_file};

fn main() {
    let args: Vec<String> = std::env::args().collect();
    if args.len() != 2 {
        eprintln!("Usage: wordcount <file>");
        std::process::exit(1);
    }
    match process_file(&args[1]) {
        Ok(count) => println!("{} words", count),
        Err(e) => eprintln!("Error: {}", e),
    }
}

// tests/integration.rs
use wordcount::{count_words, process_file};

#[test]
fn test_count_words() {
    assert_eq!(count_words("hello world"), 2);
    assert_eq!(count_words(""), 0);
}

#[test]
fn test_process_file() {
    let count = process_file("tests/fixtures/sample.txt").unwrap();
    assert_eq!(count, 42);
}
```

**Benefits:**
- All business logic is testable through the library crate
- `main.rs` becomes trivial (argument parsing + calling lib functions)
- Integration tests can test the library without spawning a process

Reference: [The Rust Book - Binary Crates](https://doc.rust-lang.org/book/ch11-03-test-organization.html#integration-tests-for-binary-crates)
