---
title: Use Struct for Subcommand Arguments
impact: MEDIUM-HIGH
impactDescription: enables reusable and testable argument groups
tags: subcmd, struct, args, organization, testability
---

## Use Struct for Subcommand Arguments

Extract subcommand arguments into dedicated structs when they have multiple fields. This improves organization and testability.

**Incorrect (inline arguments in enum):**

```rust
#[derive(Subcommand)]
enum Commands {
    Deploy {
        #[arg(long)]
        environment: String,
        #[arg(long)]
        version: String,
        #[arg(long)]
        replicas: u32,
        #[arg(long)]
        dry_run: bool,
        #[arg(long)]
        force: bool,
    },
}

fn handle_deploy(env: &str, ver: &str, replicas: u32, dry: bool, force: bool) {
    // Many parameters to pass around
}
```

**Correct (struct for arguments):**

```rust
#[derive(Args)]
struct DeployArgs {
    #[arg(long)]
    environment: String,
    #[arg(long)]
    version: String,
    #[arg(long, default_value_t = 1)]
    replicas: u32,
    #[arg(long)]
    dry_run: bool,
    #[arg(long)]
    force: bool,
}

#[derive(Subcommand)]
enum Commands {
    Deploy(DeployArgs),
}

fn handle_deploy(args: DeployArgs) {
    // Single struct parameter
}

fn main() {
    let cli = Cli::parse();
    match cli.command {
        Commands::Deploy(args) => handle_deploy(args),
    }
}
```

**Benefits:**
- Single struct to pass around
- Easy to unit test handlers
- Can derive additional traits on args struct

Reference: [Clap Args Trait](https://docs.rs/clap/latest/clap/trait.Args.html)
