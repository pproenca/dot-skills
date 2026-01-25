---
title: Derive Args for Reusable Argument Groups
impact: CRITICAL
impactDescription: enables DRY argument definitions across subcommands
tags: derive, args, flatten, reusable, composition
---

## Derive Args for Reusable Argument Groups

Use `#[derive(Args)]` with `#[command(flatten)]` to create reusable argument groups that can be shared across multiple subcommands or composed together.

**Incorrect (duplicated arguments):**

```rust
#[derive(Subcommand)]
enum Commands {
    Build {
        #[arg(long)]
        verbose: bool,
        #[arg(long)]
        color: bool,
        #[arg(long)]
        target: String,
    },
    Test {
        #[arg(long)]
        verbose: bool,  // Duplicated
        #[arg(long)]
        color: bool,    // Duplicated
        #[arg(long)]
        filter: Option<String>,
    },
}
```

**Correct (flattened reusable args):**

```rust
use clap::Args;

#[derive(Args)]
struct OutputOpts {
    #[arg(long)]
    verbose: bool,
    #[arg(long)]
    color: bool,
}

#[derive(Subcommand)]
enum Commands {
    Build {
        #[command(flatten)]
        output: OutputOpts,
        #[arg(long)]
        target: String,
    },
    Test {
        #[command(flatten)]
        output: OutputOpts,  // Reused, not duplicated
        #[arg(long)]
        filter: Option<String>,
    },
}
```

**Benefits:**
- Single source of truth for shared arguments
- Consistent naming and behavior
- Easier to add new options to all commands at once

Reference: [Clap Flatten Documentation](https://docs.rs/clap/latest/clap/_derive/index.html)
