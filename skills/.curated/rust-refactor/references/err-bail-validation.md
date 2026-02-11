---
title: Use bail! for Validation Failures
impact: MEDIUM
impactDescription: bail! provides clean early exit for validation checks
tags: err, bail, validation, anyhow
---

## Use bail! for Validation Failures

Use `anyhow::bail!` for early exit on validation failures in application code. It's cleaner than `return Err(anyhow!(...))`.

**Incorrect (problematic pattern):**

```rust
use anyhow::{anyhow, Result};

fn validate_chunk_size(x: u32) -> Result<()> {
    if x <= 1 {
        return Err(anyhow!("{} is less than minimum chunk size of 2", x));
    }
    if x.count_ones() != 1 {
        return Err(anyhow!("{} is not a power of two", x));
    }
    Ok(())
}
```

**Correct (recommended pattern):**

```rust
use anyhow::{bail, Result};

fn validate_chunk_size(x: u32) -> Result<()> {
    if x <= 1 {
        bail!("{} is less than the minimum chunk size of 2", x);
    }
    if x.count_ones() != 1 {
        bail!("{} is not a power of two", x);
    }
    Ok(())
}

// Works in any Result-returning function
fn process_args(args: &Args) -> Result<Config> {
    if args.input.is_empty() {
        bail!("Input path is required");
    }

    if !args.input.exists() {
        bail!("Input path does not exist: {}", args.input.display());
    }

    if args.threads == 0 {
        bail!("Thread count must be at least 1");
    }

    // Continue processing...
    Ok(Config::from(args))
}
```

```rust
// ensure! for condition + message (like assert but returns Error)
use anyhow::{ensure, Result};

fn validate(x: u32) -> Result<()> {
    ensure!(x > 0, "value must be positive, got {}", x);
    ensure!(x.is_power_of_two(), "{} is not a power of two", x);
    Ok(())
}
```

**When NOT to use:**
- Library code (use custom error types)
- When you need to return a specific error type
