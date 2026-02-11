---
title: Replace Stringly-Typed APIs with Strong Types
impact: CRITICAL
impactDescription: prevents argument confusion bugs at compile time
tags: type, string, strong-typing, validation, newtype
---

## Replace Stringly-Typed APIs with Strong Types

Replace string parameters that have specific formats with dedicated types. This moves validation from runtime to compile time.

**Incorrect (stringly-typed, runtime validation):**

```rust
fn send_email(from: &str, to: &str, subject: &str, body: &str) {
    // Must validate email format at runtime
    if !is_valid_email(from) || !is_valid_email(to) {
        panic!("Invalid email address");
    }
    // Send email
}

fn main() {
    // Accidentally swapped subject and to - compiles fine
    send_email("user@example.com", "Hello!", "recipient@example.com", "Body");
}
```

**Correct (strongly-typed, compile-time safety):**

```rust
pub struct EmailAddress(String);

impl EmailAddress {
    pub fn parse(email: &str) -> Result<Self, EmailParseError> {
        if is_valid_email(email) {
            Ok(EmailAddress(email.to_string()))
        } else {
            Err(EmailParseError::InvalidFormat)
        }
    }
}

pub struct Subject(String);
pub struct Body(String);

fn send_email(from: &EmailAddress, to: &EmailAddress, subject: &Subject, body: &Body) {
    // No validation needed - types guarantee validity
}

fn main() {
    let from = EmailAddress::parse("user@example.com").unwrap();
    let to = EmailAddress::parse("recipient@example.com").unwrap();
    // Swapped arguments won't compile - type mismatch
    send_email(&from, &to, &Subject("Hello!".into()), &Body("Body".into()));
}
```

**Benefits:**
- Arguments cannot be accidentally swapped
- Validation happens once at parse time
- Invalid data cannot propagate through the system

Reference: [Parse, Don't Validate](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/)
