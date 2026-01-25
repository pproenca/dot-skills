---
title: Derive Parser for CLI Entry Point
impact: CRITICAL
impactDescription: enables declarative CLI definition with minimal boilerplate
tags: derive, parser, entry-point, struct, macro
---

## Derive Parser for CLI Entry Point

Use `#[derive(Parser)]` on your main CLI struct. This is the entry point for argument parsing and provides the `parse()` method.

**Incorrect (builder API for simple CLI):**

```rust
use clap::{Command, Arg};

fn main() {
    let matches = Command::new("myapp")
        .version("1.0")
        .author("Me")
        .about("Does things")
        .arg(Arg::new("input")
            .short('i')
            .long("input")
            .required(true))
        .arg(Arg::new("output")
            .short('o')
            .long("output"))
        .get_matches();

    let input = matches.get_one::<String>("input").unwrap();
    let output = matches.get_one::<String>("output");
}
```

**Correct (derive API for simple CLI):**

```rust
use clap::Parser;

#[derive(Parser)]
#[command(version, about, author)]
struct Cli {
    #[arg(short, long)]
    input: String,

    #[arg(short, long)]
    output: Option<String>,
}

fn main() {
    let cli = Cli::parse();
    // cli.input and cli.output are typed and ready to use
}
```

**When to use Builder API instead:**
- Runtime-generated arguments
- Plugin systems with dynamic commands
- Compile-time performance is critical

Reference: [Clap Derive vs Builder](https://docs.rs/clap/latest/clap/_faq/index.html)
