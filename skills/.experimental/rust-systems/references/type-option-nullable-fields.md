---
title: Use Option<T> for Nullable Fields
impact: HIGH
impactDescription: Option<T> enforces null-safety at compile time and prevents null pointer panics
tags: type, option, nullable, fields, safety
---

## Use Option<T> for Nullable Fields

All potentially missing data fields should use `Option<T>`. This handles partial data collection gracefully and makes nullability explicit.

**Incorrect (problematic pattern):**

```rust
pub struct CpuStat {
    pub usage_usec: u64,    // What if data unavailable?
    pub user_usec: u64,     // Will panic on missing data
    pub system_usec: u64,   // Or require sentinel values
}

// Usage - fragile
let stat = read_cpu_stat()?;
println!("CPU: {}", stat.usage_usec);  // Might be garbage/zero
```

**Correct (recommended pattern):**

```rust
#[derive(Default, Clone, Debug, Serialize, Deserialize)]
pub struct CpuStat {
    pub usage_usec: Option<u64>,    // Explicitly optional
    pub user_usec: Option<u64>,
    pub system_usec: Option<u64>,
    pub idle_usec: Option<u64>,
}

// Usage - safe
let stat = read_cpu_stat()?;
if let Some(usage) = stat.usage_usec {
    println!("CPU: {}", usage);
} else {
    println!("CPU: unavailable");
}

// Or with default
let usage = stat.usage_usec.unwrap_or(0);

// Chaining
let total = stat.user_usec
    .and_then(|u| stat.system_usec.map(|s| u + s));
```

**When NOT to use:**
- Fields that are truly required and should cause errors when missing
- Primitive fields where zero is a valid "missing" sentinel (rare)
