---
title: Hide Advanced Options from Default Help
impact: LOW-MEDIUM
impactDescription: reduces cognitive load for common use cases
tags: help, hide, advanced, usability, simplicity
---

## Hide Advanced Options from Default Help

Use `hide = true` to hide rarely-used or advanced options from default help while keeping them functional.

**Incorrect (cluttered help with advanced options):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long)]
    input: PathBuf,

    #[arg(long)]
    output: PathBuf,

    #[arg(long)]
    internal_buffer_size: usize,  // Most users don't need this

    #[arg(long)]
    debug_parser: bool,  // Only for troubleshooting

    #[arg(long)]
    experimental_feature: bool,  // Unstable
}
// --help shows everything, overwhelming new users
```

**Correct (hide advanced options):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long)]
    input: PathBuf,

    #[arg(long)]
    output: PathBuf,

    #[arg(long, hide = true)]
    internal_buffer_size: usize,  // Hidden from --help

    #[arg(long, hide = true)]
    debug_parser: bool,  // Hidden from --help

    #[arg(long, hide = true)]
    experimental_feature: bool,  // Hidden from --help
}
// --help is clean; advanced users can still use hidden options
```

**Show hidden options on request:**

```rust
#[derive(Parser)]
#[command(hide_possible_values = true)]
struct Cli {
    #[arg(long, hide_long_help = true)]
    advanced: bool,  // Hidden from --help but visible in -h
}
```

Reference: [Clap Arg hide](https://docs.rs/clap/latest/clap/struct.Arg.html#method.hide)
