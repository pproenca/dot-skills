---
title: Use value_name for Descriptive Placeholders
impact: MEDIUM
impactDescription: improves help text clarity and user understanding
tags: arg, value-name, help, placeholder, documentation
---

## Use value_name for Descriptive Placeholders

Use `value_name` to provide meaningful placeholders in help text. This helps users understand what value is expected.

**Incorrect (generic placeholder):**

```rust
#[derive(Parser)]
struct Cli {
    /// API endpoint URL
    #[arg(long)]
    url: String,
}
// Help shows: --url <URL>  (generic, not descriptive)
```

**Correct (descriptive placeholder):**

```rust
#[derive(Parser)]
struct Cli {
    /// API endpoint URL
    #[arg(long, value_name = "ENDPOINT")]
    url: String,
}
// Help shows: --url <ENDPOINT>  (descriptive)
```

**Examples of good value names:**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long, value_name = "FILE")]
    config: PathBuf,

    #[arg(long, value_name = "SECONDS")]
    timeout: u64,

    #[arg(long, value_name = "HOST:PORT")]
    bind: String,

    #[arg(long, value_name = "LEVEL")]
    log: String,
}
// --config <FILE>
// --timeout <SECONDS>
// --bind <HOST:PORT>
// --log <LEVEL>
```

**Benefits:**
- Users understand expected format at a glance
- Hints at valid values without reading full help text

Reference: [Clap Arg Documentation](https://docs.rs/clap/latest/clap/struct.Arg.html#method.value_name)
