---
title: Use bool for Simple Flags
impact: HIGH
impactDescription: enables natural flag syntax without value specification
tags: type, bool, flags, toggle, switch
---

## Use bool for Simple Flags

Use `bool` fields for simple on/off flags. Clap automatically treats boolean fields as flags that don't require a value.

**Incorrect (String for boolean concept):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long)]
    verbose: Option<String>,  // Requires --verbose=true or --verbose=false
}

fn main() {
    let cli = Cli::parse();
    let is_verbose = cli.verbose.as_deref() == Some("true");  // Manual parsing
}
```

**Correct (bool for flags):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(short, long)]
    verbose: bool,  // --verbose or -v enables, absence disables
}

fn main() {
    let cli = Cli::parse();
    if cli.verbose {  // Direct boolean usage
        println!("Verbose mode enabled");
    }
}
```

**Alternative (counting occurrences):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(short, long, action = clap::ArgAction::Count)]
    verbose: u8,  // -v = 1, -vv = 2, -vvv = 3
}
```

Reference: [Clap Arg Actions](https://docs.rs/clap/latest/clap/enum.ArgAction.html)
