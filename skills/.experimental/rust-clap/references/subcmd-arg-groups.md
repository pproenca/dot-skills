---
title: Use ArgGroup for One-of-Many Requirements
impact: MEDIUM
impactDescription: enforces exactly-one-required constraints declaratively
tags: subcmd, arg-group, constraints, one-of, validation
---

## Use ArgGroup for One-of-Many Requirements

Use `ArgGroup` when exactly one argument from a set must be provided. This is cleaner than multiple conflicts_with declarations.

**Incorrect (complex conflicts):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long, conflicts_with_all = ["stdin", "url"])]
    file: Option<PathBuf>,

    #[arg(long, conflicts_with_all = ["file", "url"])]
    stdin: bool,

    #[arg(long, conflicts_with_all = ["file", "stdin"])]
    url: Option<String>,
}
// Must manually ensure at least one is provided
```

**Correct (ArgGroup for one-of):**

```rust
use clap::Args;

#[derive(Args)]
#[group(required = true, multiple = false)]
struct Input {
    #[arg(long)]
    file: Option<PathBuf>,

    #[arg(long)]
    stdin: bool,

    #[arg(long)]
    url: Option<String>,
}

#[derive(Parser)]
struct Cli {
    #[command(flatten)]
    input: Input,
}
// Exactly one of --file, --stdin, or --url required
```

**Benefits:**
- Clear "one of" semantics
- Automatic error messages
- Help text shows grouped options

Reference: [Clap ArgGroup](https://docs.rs/clap/latest/clap/struct.ArgGroup.html)
