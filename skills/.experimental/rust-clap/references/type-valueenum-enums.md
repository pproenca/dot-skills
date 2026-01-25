---
title: Use ValueEnum for Enumerated Arguments
impact: CRITICAL
impactDescription: eliminates string matching and invalid value bugs
tags: type, valueenum, enum, type-safety, validation
---

## Use ValueEnum for Enumerated Arguments

When an argument accepts a fixed set of values, derive `ValueEnum` to get compile-time safety and automatic validation with user-friendly error messages.

**Incorrect (stringly-typed, manual validation):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long)]
    format: String,  // Accepts any string, validation needed later
}

fn main() {
    let cli = Cli::parse();
    match cli.format.as_str() {
        "json" | "yaml" | "toml" => {}
        _ => eprintln!("Invalid format"),  // Easy to forget this check
    }
}
```

**Correct (type-safe, automatic validation):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long, value_enum)]
    format: Format,  // Only accepts valid variants
}

#[derive(Clone, ValueEnum)]
enum Format {
    Json,
    Yaml,
    Toml,
}

fn main() {
    let cli = Cli::parse();
    // No validation needed - format is guaranteed valid
}
```

**Benefits:**
- Clap rejects invalid values before your code runs
- Automatic help text shows valid options
- Exhaustive match ensures all cases handled

Reference: [Clap Derive Tutorial - Enumerated Values](https://docs.rs/clap/latest/clap/_derive/_tutorial/index.html)
