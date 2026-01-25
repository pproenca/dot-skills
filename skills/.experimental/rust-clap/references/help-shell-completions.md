---
title: Generate Shell Completions with clap_complete
impact: MEDIUM
impactDescription: enables tab completion in bash, zsh, fish, and PowerShell
tags: help, completions, shell, usability, discoverability
---

## Generate Shell Completions with clap_complete

Use `clap_complete` to generate shell completion scripts for improved CLI usability.

**Incorrect (no completion support):**

```rust
#[derive(Parser)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}
// Users must type full command names
```

**Correct (completion generation subcommand):**

```rust
use clap::{CommandFactory, Parser, Subcommand};
use clap_complete::{generate, Shell};
use std::io;

#[derive(Parser)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    Build,
    Test,
    /// Generate shell completions
    Completions {
        #[arg(value_enum)]
        shell: Shell,
    },
}

fn main() {
    let cli = Cli::parse();
    match cli.command {
        Commands::Completions { shell } => {
            generate(shell, &mut Cli::command(), "myapp", &mut io::stdout());
        }
        Commands::Build => { /* ... */ }
        Commands::Test => { /* ... */ }
    }
}
```

**Usage:**

```bash
# Generate and install completions
myapp completions bash > ~/.local/share/bash-completion/completions/myapp
myapp completions zsh > ~/.zfunc/_myapp
myapp completions fish > ~/.config/fish/completions/myapp.fish
```

Reference: [clap_complete Documentation](https://docs.rs/clap_complete/)
