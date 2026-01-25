---
title: Implement FromStr for Domain Types
impact: HIGH
impactDescription: enables automatic parsing with type safety
tags: valid, fromstr, domain, parsing, type-safety
---

## Implement FromStr for Domain Types

Implement `FromStr` on your domain types to enable direct parsing from command-line arguments with custom validation.

**Incorrect (parsing after clap):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long)]
    email: String,
}

struct Email(String);

impl Email {
    fn new(s: &str) -> Result<Self, &'static str> {
        if s.contains('@') && s.contains('.') {
            Ok(Email(s.to_string()))
        } else {
            Err("invalid email format")
        }
    }
}

fn main() {
    let cli = Cli::parse();
    let email = Email::new(&cli.email).expect("invalid email");  // Validation after parsing
}
```

**Correct (FromStr for direct parsing):**

```rust
use std::str::FromStr;

#[derive(Clone)]
struct Email(String);

impl FromStr for Email {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        if s.contains('@') && s.contains('.') {
            Ok(Email(s.to_string()))
        } else {
            Err(format!("'{}' is not a valid email address", s))
        }
    }
}

#[derive(Parser)]
struct Cli {
    #[arg(long)]
    email: Email,  // Clap calls Email::from_str automatically
}

fn main() {
    let cli = Cli::parse();
    // cli.email is already validated
}
```

**Benefits:**
- Clap shows your error message on invalid input
- Type system prevents invalid values
- Reusable across arguments

Reference: [Clap Custom Parsing](https://docs.rs/clap/latest/clap/_derive/_tutorial/index.html)
