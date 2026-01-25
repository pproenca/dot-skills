---
title: Use next_help_heading for Organized Help
impact: MEDIUM
impactDescription: groups related options visually in help output
tags: help, heading, organization, usability, documentation
---

## Use next_help_heading for Organized Help

Use `next_help_heading` to group related options under descriptive headings in help output.

**Incorrect (flat option list):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long)]
    host: String,
    #[arg(long)]
    port: u16,
    #[arg(long)]
    timeout: u64,
    #[arg(long)]
    verbose: bool,
    #[arg(long)]
    quiet: bool,
    #[arg(long)]
    format: String,
}
// All options in one flat list in --help
```

**Correct (grouped with headings):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long, help_heading = "Network Options")]
    host: String,

    #[arg(long, help_heading = "Network Options")]
    port: u16,

    #[arg(long, help_heading = "Network Options")]
    timeout: u64,

    #[arg(long, help_heading = "Output Options")]
    verbose: bool,

    #[arg(long, help_heading = "Output Options")]
    quiet: bool,

    #[arg(long, help_heading = "Output Options")]
    format: String,
}
```

**Alternative with flattened groups:**

```rust
#[derive(Args)]
#[command(next_help_heading = "Network Options")]
struct NetworkOpts {
    #[arg(long)]
    host: String,
    #[arg(long)]
    port: u16,
}

#[derive(Parser)]
struct Cli {
    #[command(flatten)]
    network: NetworkOpts,
}
```

Reference: [Clap Help Headings](https://docs.rs/clap/latest/clap/struct.Arg.html#method.help_heading)
