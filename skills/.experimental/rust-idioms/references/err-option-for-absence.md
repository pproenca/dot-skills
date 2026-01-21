---
title: Use Option for Absence, Not Sentinel Values
impact: HIGH
impactDescription: eliminates null-related bugs, makes absence explicit
tags: err, option, null, sentinel, absence
---

## Use Option for Absence, Not Sentinel Values

Return `Option<T>` when a value might not exist. Avoid sentinel values like `-1`, `null`, or empty strings to indicate absence.

**Incorrect (sentinel values hide absence):**

```rust
fn find_user_index(users: &[User], name: &str) -> i32 {
    for (i, user) in users.iter().enumerate() {
        if user.name == name {
            return i as i32;
        }
    }
    -1  // Sentinel value for "not found"
}

fn main() {
    let users = vec![User { name: "alice".to_string() }];
    let index = find_user_index(&users, "bob");
    // Easy to forget to check for -1
    let user = &users[index as usize];  // Panic or wrong user!
}
```

**Correct (Option makes absence explicit):**

```rust
fn find_user_index(users: &[User], name: &str) -> Option<usize> {
    users.iter().position(|u| u.name == name)
}

fn main() {
    let users = vec![User { name: "alice".to_string() }];
    let index = find_user_index(&users, "bob");
    // Compiler forces handling of None
    if let Some(i) = index {
        let user = &users[i];
        // Use user
    } else {
        println!("User not found");
    }
}
```

**Option combinators for cleaner code:**

```rust
fn find_user<'a>(users: &'a [User], name: &str) -> Option<&'a User> {
    users.iter().find(|u| u.name == name)
}

// Use with combinators
find_user(&users, "alice")
    .map(|u| u.email.clone())
    .unwrap_or_else(|| "unknown@example.com".to_string());
```

Reference: [Option - Rust Standard Library](https://doc.rust-lang.org/std/option/enum.Option.html)
