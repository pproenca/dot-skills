---
title: Use External Subcommands for Plugin Systems
impact: LOW-MEDIUM
impactDescription: enables git-style plugin extensibility
tags: subcmd, external, plugins, extensibility, git-style
---

## Use External Subcommands for Plugin Systems

Use `allow_external_subcommands` to enable git-style plugin extensibility where unknown subcommands are passed to external executables.

**Incorrect (closed set of subcommands):**

```rust
#[derive(Subcommand)]
enum Commands {
    Build,
    Test,
    // No way to add third-party commands
}
// myapp some-plugin  # Error: unknown subcommand
```

**Correct (external subcommands enabled):**

```rust
use std::ffi::OsString;

#[derive(Parser)]
#[command(allow_external_subcommands = true)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    Build,
    Test,
    #[command(external_subcommand)]
    External(Vec<OsString>),
}

fn main() {
    let cli = Cli::parse();
    match cli.command {
        Commands::Build => { /* built-in */ }
        Commands::Test => { /* built-in */ }
        Commands::External(args) => {
            // args[0] is "some-plugin", rest are its args
            // Look for myapp-some-plugin executable
            let plugin = format!("myapp-{}", args[0].to_string_lossy());
            std::process::Command::new(&plugin)
                .args(&args[1..])
                .exec();
        }
    }
}
```

**Benefits:**
- Third-party extensions without recompiling
- Same pattern as git, cargo, kubectl
- Plugin authors don't need access to main codebase

Reference: [Clap External Subcommands](https://docs.rs/clap/latest/clap/struct.Command.html#method.allow_external_subcommands)
