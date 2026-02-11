---
title: Reserve panic! for Unrecoverable Situations
impact: HIGH
impactDescription: Panics terminate the program - use only when continuation is impossible
tags: err, panic, unrecoverable, invariants
---

## Reserve panic! for Unrecoverable Situations

Use `panic!` only for truly unrecoverable situations: system call failures that indicate fundamental problems, internal invariant violations, or programmer errors.

**Incorrect (problematic pattern):**

```rust
// Panicking on recoverable errors
fn read_config(path: &Path) -> Config {
    let content = std::fs::read_to_string(path)
        .expect("Failed to read config");  // Panics - user can't recover

    toml::from_str(&content)
        .expect("Invalid config")  // Panics - no chance to fix
}

// Panicking on missing data
fn get_user(id: u32) -> User {
    USER_MAP.get(&id).unwrap().clone()  // Panics if user doesn't exist
}
```

**Correct (recommended pattern):**

```rust
// Return Result for recoverable errors
fn read_config(path: &Path) -> Result<Config> {
    let content = std::fs::read_to_string(path)
        .with_context(|| format!("Failed to read {}", path.display()))?;

    toml::from_str(&content)
        .context("Failed to parse config")
}

fn get_user(id: u32) -> Option<User> {
    USER_MAP.get(&id).cloned()
}

// Panic only for truly unrecoverable system failures
fn get_page_size() -> u64 {
    match unsafe { libc::sysconf(libc::_SC_PAGESIZE) } {
        -1 => panic!("Failed to query page size - system is misconfigured"),
        x => x as u64,
    }
}

// Panic for internal invariant violations (programmer errors)
fn process_validated(data: &ValidatedData) {
    // This should be impossible if ValidatedData is constructed correctly
    assert!(!data.items.is_empty(), "ValidatedData invariant violated: items is empty");
}

// Use unreachable! for provably impossible code paths
match state {
    State::Running => process(),
    State::Stopped => cleanup(),
    // State enum is exhaustive, but compiler doesn't know
    #[allow(unreachable_patterns)]
    _ => unreachable!("Invalid state"),
}
```

**When NOT to use:**
- User input validation (return Error)
- File/network operations (return Error)
- Missing optional data (return Option/Error)
