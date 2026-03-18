---
title: Use the Question Mark Operator for Error Propagation
impact: CRITICAL
impactDescription: eliminates boilerplate match arms, 60-80% fewer error-handling lines
tags: errprop, question-mark, error-handling, propagation
---

## Use the Question Mark Operator for Error Propagation

Use `?` instead of explicit `match` or `unwrap()` to propagate errors. The `?` operator converts the error type via `From` and returns early, keeping the happy path readable and the error path automatic.

**Incorrect (verbose match blocks obscure logic):**

```rust
fn load_sandbox_policy(path: &Path) -> Result<SandboxPolicy, ConfigError> {
    let content = match std::fs::read_to_string(path) {
        Ok(c) => c,
        Err(e) => return Err(ConfigError::Io(e)),
    };
    let policy = match toml::from_str(&content) {
        Ok(p) => p,
        Err(e) => return Err(ConfigError::Parse(e)),
    };
    Ok(policy)
}
```

**Correct (concise propagation with ?):**

```rust
fn load_sandbox_policy(path: &Path) -> Result<SandboxPolicy, ConfigError> {
    let content = std::fs::read_to_string(path)?;
    let policy: SandboxPolicy = toml::from_str(&content)?;
    Ok(policy)
}
```
