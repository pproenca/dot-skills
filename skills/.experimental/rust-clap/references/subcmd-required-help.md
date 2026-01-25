---
title: Require Subcommand or Show Help
impact: MEDIUM
impactDescription: provides guidance when user runs bare command
tags: subcmd, required, help, usability, guidance
---

## Require Subcommand or Show Help

Use `subcommand_required` and `arg_required_else_help` to guide users when they run the bare command without a subcommand.

**Incorrect (silent no-op on bare command):**

```rust
#[derive(Parser)]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,  // Optional subcommand
}

fn main() {
    let cli = Cli::parse();
    match cli.command {
        Some(cmd) => handle(cmd),
        None => {}  // User runs 'myapp' and nothing happens
    }
}
```

**Correct (show help on bare command):**

```rust
#[derive(Parser)]
#[command(subcommand_required = true, arg_required_else_help = true)]
struct Cli {
    #[command(subcommand)]
    command: Commands,  // Required subcommand
}

fn main() {
    let cli = Cli::parse();
    handle(cli.command);
}
// Running 'myapp' shows help automatically
```

**Alternative (default subcommand):**

```rust
#[derive(Subcommand)]
enum Commands {
    #[command(name = "run")]
    Run(RunArgs),

    #[command(name = "help")]
    Help,
}

// If bare command should do something specific, make it a default
```

Reference: [Clap Command Documentation](https://docs.rs/clap/latest/clap/struct.Command.html)
