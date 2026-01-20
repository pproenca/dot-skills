---
title: Use let-else for Early Returns on Pattern Match Failure
impact: MEDIUM
impactDescription: reduces nesting, makes happy path clear
tags: idiom, let-else, pattern-matching, early-return, readability
---

## Use let-else for Early Returns on Pattern Match Failure

Use `let-else` to destructure and return early on failure. This flattens nested code and keeps the happy path at the top level.

**Incorrect (deeply nested match):**

```rust
fn process_user(input: Option<UserInput>) -> Result<User, Error> {
    match input {
        Some(input) => {
            match input.validate() {
                Ok(validated) => {
                    match User::from_input(validated) {
                        Ok(user) => Ok(user),
                        Err(e) => Err(Error::Creation(e)),
                    }
                }
                Err(e) => Err(Error::Validation(e)),
            }
        }
        None => Err(Error::MissingInput),
    }
}
```

**Correct (let-else flattens the code):**

```rust
fn process_user(input: Option<UserInput>) -> Result<User, Error> {
    let Some(input) = input else {
        return Err(Error::MissingInput);
    };

    let Ok(validated) = input.validate() else {
        return Err(Error::Validation);
    };

    let Ok(user) = User::from_input(validated) else {
        return Err(Error::Creation);
    };

    Ok(user)
}
```

**Even more concise with ?:**

```rust
fn process_user(input: Option<UserInput>) -> Result<User, Error> {
    let input = input.ok_or(Error::MissingInput)?;
    let validated = input.validate().map_err(|_| Error::Validation)?;
    let user = User::from_input(validated).map_err(|_| Error::Creation)?;
    Ok(user)
}
```

**When to use let-else:**
- Destructuring with early return on failure
- Guard clauses at function start
- When you need the diverging path to have custom logic

Reference: [Let-else - Rust Reference](https://doc.rust-lang.org/reference/statements.html#let-else-statements)
