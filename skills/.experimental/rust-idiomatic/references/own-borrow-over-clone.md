---
title: Borrow References Instead of Cloning
impact: CRITICAL
impactDescription: 2-10x less memory pressure in data-heavy paths
tags: own, borrowing, clone, references, memory
---

## Borrow References Instead of Cloning

Pass data by reference (`&T` or `&str`) instead of cloning owned values. Every `.clone()` allocates new heap memory and copies bytes. Borrowing is zero-cost and lets the compiler verify lifetimes statically.

**Incorrect (clones string for read-only use):**

```rust
fn validate_config(config: ConfigToml) -> Result<(), ValidationError> {
    let name = config.model.clone();
    if name.is_empty() {
        return Err(ValidationError::EmptyModel);
    }
    check_model_availability(&name)?;
    Ok(())
}
```

**Correct (borrows reference, zero allocation):**

```rust
fn validate_config(config: &ConfigToml) -> Result<(), ValidationError> {
    if config.model.is_empty() {
        return Err(ValidationError::EmptyModel);
    }
    check_model_availability(&config.model)?;
    Ok(())
}
```
