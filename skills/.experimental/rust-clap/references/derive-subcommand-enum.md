---
title: Use Subcommand Derive for Command Hierarchies
impact: CRITICAL
impactDescription: enables git-style subcommand routing with type safety
tags: derive, subcommand, enum, hierarchy, routing
---

## Use Subcommand Derive for Command Hierarchies

Derive `Subcommand` on an enum to create git-style subcommands. Each variant becomes a subcommand with its own arguments.

**Incorrect (manual subcommand parsing):**

```rust
#[derive(Parser)]
struct Cli {
    #[arg(long)]
    command: String,  // "add", "remove", "list"

    #[arg(long)]
    name: Option<String>,  // Only used by some commands
}

fn main() {
    let cli = Cli::parse();
    match cli.command.as_str() {
        "add" => {
            let name = cli.name.expect("name required for add");
            // ...
        }
        "list" => { /* name ignored */ }
        _ => panic!("Unknown command"),
    }
}
```

**Correct (typed subcommand enum):**

```rust
use clap::{Parser, Subcommand};

#[derive(Parser)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    Add { name: String },
    Remove { name: String },
    List,
}

fn main() {
    let cli = Cli::parse();
    match cli.command {
        Commands::Add { name } => println!("Adding {}", name),
        Commands::Remove { name } => println!("Removing {}", name),
        Commands::List => println!("Listing all"),
    }
}
```

**Benefits:**
- Each subcommand has only its relevant arguments
- Exhaustive match ensures all commands handled
- Automatic help text per subcommand

Reference: [Clap Subcommand Documentation](https://docs.rs/clap/latest/clap/trait.Subcommand.html)
