---
title: Define Custom Error Types for Domain Boundaries
impact: CRITICAL
impactDescription: enables exhaustive error matching and typed recovery logic
tags: errprop, custom-errors, thiserror, domain-boundary, enum
---

## Define Custom Error Types for Domain Boundaries

Define domain-specific error enums at module boundaries so callers can match on specific failure modes. Use `#[error(...)]` messages that describe the failure from the user's perspective, and `#[from]` for automatic conversion from upstream errors.

**Incorrect (returns generic string errors, no structured matching):**

```rust
fn compile_policy(input: &str) -> Result<Policy, String> {
    let parsed = parse_rules(input)
        .map_err(|e| format!("parse failed: {e}"))?;
    let validated = validate(parsed)
        .map_err(|e| format!("validation failed: {e}"))?;
    Ok(validated)
}
```

**Correct (typed enum with From conversions):**

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum PolicyError {
    #[error("failed to parse policy rules")]
    Parse(#[from] ParseError),
    #[error("policy validation failed: {0}")]
    Validation(String),
    #[error(transparent)]
    Io(#[from] std::io::Error),
}

fn compile_policy(input: &str) -> Result<Policy, PolicyError> {
    let parsed = parse_rules(input)?;
    let validated = validate(parsed)?;
    Ok(validated)
}
```
