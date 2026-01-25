---
title: Use requires for Dependent Arguments
impact: MEDIUM-HIGH
impactDescription: enforces argument dependencies at parse time
tags: arg, requires, dependencies, validation, constraints
---

## Use requires for Dependent Arguments

Use `requires` to declare that one argument depends on another. Clap enforces these dependencies automatically.

**Incorrect (runtime dependency checking):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long)]
    upload: bool,

    #[arg(long)]
    upload_url: Option<String>,
}

fn main() {
    let cli = Cli::parse();
    if cli.upload && cli.upload_url.is_none() {
        eprintln!("Error: --upload requires --upload-url");
        std::process::exit(1);  // Manual validation
    }
}
```

**Correct (declarative dependency):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long, requires = "upload_url")]
    upload: bool,

    #[arg(long)]
    upload_url: Option<String>,
}

fn main() {
    let cli = Cli::parse();
    // If --upload is set, --upload-url must also be set
    // Clap enforces this before main() runs
}
```

**Multiple dependencies:**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long, requires_all = ["username", "password"])]
    login: bool,

    #[arg(long)]
    username: Option<String>,

    #[arg(long)]
    password: Option<String>,
}
```

Reference: [Clap Arg Dependencies](https://docs.rs/clap/latest/clap/struct.Arg.html#method.requires)
