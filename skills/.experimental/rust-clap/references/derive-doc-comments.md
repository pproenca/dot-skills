---
title: Use Doc Comments for Help Text
impact: HIGH
impactDescription: provides automatic help text without duplication
tags: derive, doc-comments, help, documentation, usability
---

## Use Doc Comments for Help Text

Use `///` doc comments on struct fields to automatically generate help text. This keeps documentation close to the code and avoids duplication.

**Incorrect (separate help attribute):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(short, long, help = "Path to the configuration file")]
    config: PathBuf,

    #[arg(short, long, help = "Enable verbose output")]
    verbose: bool,
}
```

**Correct (doc comments become help text):**

```rust
#[derive(Parser)]
struct Cli {
    /// Path to the configuration file
    #[arg(short, long)]
    config: PathBuf,

    /// Enable verbose output
    #[arg(short, long)]
    verbose: bool,
}
```

**Extended help with long_about:**

```rust
#[derive(Parser)]
/// A CLI tool for processing data
///
/// This tool reads input files, processes them according to the
/// specified rules, and outputs the results.
#[command(version, about, long_about)]
struct Cli {
    /// Path to the input file
    ///
    /// Supports JSON, YAML, and TOML formats. The format is
    /// auto-detected from the file extension.
    #[arg(short, long)]
    input: PathBuf,
}
```

**Benefits:**
- Help text appears in `rustdoc` and `--help`
- Single source of truth for documentation
- Supports multi-paragraph long help

Reference: [Clap Derive Tutorial](https://docs.rs/clap/latest/clap/_derive/_tutorial/index.html)
