---
title: Use Global for Cross-Subcommand Options
impact: HIGH
impactDescription: enables consistent options across all subcommands
tags: derive, global, options, subcommands, consistency
---

## Use Global for Cross-Subcommand Options

Mark options with `global = true` to make them available in all subcommands. This allows users to place global options anywhere on the command line.

**Incorrect (options only work before subcommand):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long)]
    verbose: bool,  // Must come before subcommand

    #[command(subcommand)]
    command: Commands,
}

// $ myapp --verbose build  # Works
// $ myapp build --verbose  # Error: --verbose not recognized
```

**Correct (global options work anywhere):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long, global = true)]
    verbose: bool,  // Works anywhere on command line

    #[command(subcommand)]
    command: Commands,
}

// $ myapp --verbose build  # Works
// $ myapp build --verbose  # Also works!
```

**Pattern with flattened global options:**

```rust
#[derive(Args)]
struct GlobalOpts {
    #[arg(long, global = true)]
    verbose: bool,

    #[arg(long, global = true, default_value = "auto")]
    color: String,
}

#[derive(Parser)]
struct Cli {
    #[command(flatten)]
    global: GlobalOpts,

    #[command(subcommand)]
    command: Commands,
}
```

Reference: [Clap Global Arguments](https://docs.rs/clap/latest/clap/struct.Arg.html#method.global)
