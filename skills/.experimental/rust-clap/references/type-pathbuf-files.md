---
title: Use PathBuf for File System Arguments
impact: CRITICAL
impactDescription: enables cross-platform paths and proper file handling
tags: type, pathbuf, filesystem, cross-platform, paths
---

## Use PathBuf for File System Arguments

Use `PathBuf` instead of `String` for file and directory arguments. This enables proper cross-platform path handling and integrates with Rust's file system APIs.

**Incorrect (String for paths):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(short, long)]
    input: String,  // Must convert to Path for every operation

    #[arg(short, long)]
    output: String,
}

fn main() {
    let cli = Cli::parse();
    let path = std::path::Path::new(&cli.input);  // Manual conversion
    std::fs::read_to_string(path)?;
}
```

**Correct (PathBuf for paths):**

```rust
use std::path::PathBuf;

#[derive(Parser)]
struct Cli {
    #[arg(short, long)]
    input: PathBuf,  // Clap parses directly into PathBuf

    #[arg(short, long)]
    output: PathBuf,
}

fn main() {
    let cli = Cli::parse();
    std::fs::read_to_string(&cli.input)?;  // Works directly
}
```

**Benefits:**
- Automatic handling of platform-specific path separators
- Direct use with `std::fs` functions
- Proper Unicode handling on Windows

Reference: [Clap Arg Documentation](https://docs.rs/clap/latest/clap/struct.Arg.html)
