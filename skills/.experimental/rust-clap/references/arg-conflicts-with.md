---
title: Use conflicts_with for Mutually Exclusive Options
impact: HIGH
impactDescription: prevents invalid argument combinations at parse time
tags: arg, conflicts, mutually-exclusive, validation, constraints
---

## Use conflicts_with for Mutually Exclusive Options

Use `conflicts_with` to declare options that cannot be used together. Clap will reject invalid combinations with clear error messages.

**Incorrect (runtime conflict checking):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long)]
    json: bool,

    #[arg(long)]
    yaml: bool,
}

fn main() {
    let cli = Cli::parse();
    if cli.json && cli.yaml {
        eprintln!("Error: cannot use --json and --yaml together");
        std::process::exit(1);  // Manual validation
    }
}
```

**Correct (declarative conflict):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long, conflicts_with = "yaml")]
    json: bool,

    #[arg(long)]
    yaml: bool,
}

fn main() {
    let cli = Cli::parse();
    // Clap already rejected --json --yaml with:
    // "error: the argument '--json' cannot be used with '--yaml'"
}
```

**Alternative (ValueEnum for mutual exclusion):**

```rust
#[derive(Clone, ValueEnum)]
enum Format {
    Json,
    Yaml,
    Toml,
}

#[derive(Parser)]
struct Cli {
    #[arg(long, value_enum, default_value_t = Format::Json)]
    format: Format,  // Only one format possible by type
}
```

Reference: [Clap Arg Conflicts](https://docs.rs/clap/latest/clap/struct.Arg.html#method.conflicts_with)
