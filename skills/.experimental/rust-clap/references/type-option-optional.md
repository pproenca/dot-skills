---
title: Use Option for Truly Optional Arguments
impact: CRITICAL
impactDescription: prevents None-checking bugs and unclear APIs
tags: type, option, optional, type-safety, api-design
---

## Use Option for Truly Optional Arguments

Use `Option<T>` for arguments that may or may not be provided. Never use sentinel values or empty strings to represent missing data.

**Incorrect (sentinel value for missing):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long, default_value = "")]
    config: String,  // Empty string means "not provided"
}

fn main() {
    let cli = Cli::parse();
    if !cli.config.is_empty() {  // Easy to forget this check
        load_config(&cli.config);
    }
}
```

**Correct (Option expresses optionality):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long)]
    config: Option<PathBuf>,  // None means "not provided"
}

fn main() {
    let cli = Cli::parse();
    if let Some(path) = cli.config {  // Compiler enforces handling
        load_config(&path);
    }
}
```

**When NOT to use this pattern:**
- When the argument has a sensible default value, use `default_value` instead
- When absence should trigger an error, make the field required

Reference: [Clap Derive Documentation](https://docs.rs/clap/latest/clap/_derive/index.html)
