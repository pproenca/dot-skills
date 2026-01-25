---
title: Use default_value for Sensible Defaults
impact: HIGH
impactDescription: improves UX by reducing required arguments
tags: arg, default-value, defaults, usability, configuration
---

## Use default_value for Sensible Defaults

Provide default values for optional arguments to improve user experience. Use `default_value` for strings and `default_value_t` for other types.

**Incorrect (required argument that could have default):**

```rust
#[derive(Parser)]
struct Cli {
    /// Output format
    #[arg(long)]
    format: String,  // User must always specify
}
// $ myapp           # Error: --format is required
```

**Correct (sensible default provided):**

```rust
#[derive(Parser)]
struct Cli {
    /// Output format
    #[arg(long, default_value = "json")]
    format: String,
}
// $ myapp           # Uses json format
// $ myapp --format yaml  # Uses yaml format
```

**For non-String types, use default_value_t:**

```rust
#[derive(Parser)]
struct Cli {
    /// Connection timeout in seconds
    #[arg(long, default_value_t = 30)]
    timeout: u64,

    /// Server port
    #[arg(short, long, default_value_t = 8080)]
    port: u16,
}
```

**Benefits:**
- Reduces cognitive load on users
- Most common use case works without flags
- `--help` shows the default value automatically

Reference: [Clap Default Values](https://docs.rs/clap/latest/clap/struct.Arg.html#method.default_value)
