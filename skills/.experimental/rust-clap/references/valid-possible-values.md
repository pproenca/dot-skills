---
title: Use PossibleValuesParser for String Constraints
impact: HIGH
impactDescription: restricts string inputs with automatic help text
tags: valid, possible-values, constraints, enum-like, validation
---

## Use PossibleValuesParser for String Constraints

When an argument accepts a limited set of string values but you don't want a full enum, use `PossibleValuesParser` for validation with helpful error messages.

**Incorrect (manual validation):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long)]
    log_level: String,
}

fn main() {
    let cli = Cli::parse();
    match cli.log_level.as_str() {
        "debug" | "info" | "warn" | "error" => {}
        other => {
            eprintln!("Invalid log level: {}", other);
            std::process::exit(1);
        }
    }
}
```

**Correct (constrained at parse time):**

```rust
use clap::builder::PossibleValuesParser;

#[derive(Parser)]
struct Cli {
    #[arg(long, value_parser = PossibleValuesParser::new(["debug", "info", "warn", "error"]))]
    log_level: String,
}

fn main() {
    let cli = Cli::parse();
    // log_level is guaranteed to be one of the valid options
}
```

**Help output includes valid values:**

```text
--log-level <LOG_LEVEL>  [possible values: debug, info, warn, error]
```

**When to use ValueEnum instead:**
- When you need to match on the value in code
- When the set of values is truly fixed and finite

Reference: [Clap PossibleValuesParser](https://docs.rs/clap/latest/clap/builder/struct.PossibleValuesParser.html)
