---
title: Use Vec for Multiple Value Arguments
impact: CRITICAL
impactDescription: enables natural multi-value handling without manual splitting
tags: type, vec, multiple, variadic, collection
---

## Use Vec for Multiple Value Arguments

When an argument can be specified multiple times or accepts multiple values, use `Vec<T>`. Clap automatically infers the multiplicity from the type.

**Incorrect (single String with manual splitting):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long)]
    tags: String,  // User must use comma separation: --tags "a,b,c"
}

fn main() {
    let cli = Cli::parse();
    let tags: Vec<&str> = cli.tags.split(',').collect();  // Manual parsing
}
```

**Correct (Vec with natural repetition):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long)]
    tags: Vec<String>,  // User can repeat: --tags a --tags b --tags c
}

fn main() {
    let cli = Cli::parse();
    for tag in &cli.tags {  // Direct iteration
        println!("Tag: {}", tag);
    }
}
```

**Alternative (space-separated values):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long, num_args = 1..)]
    files: Vec<PathBuf>,  // --files a.txt b.txt c.txt
}
```

Reference: [Clap Derive Tutorial](https://docs.rs/clap/latest/clap/_derive/_tutorial/index.html)
