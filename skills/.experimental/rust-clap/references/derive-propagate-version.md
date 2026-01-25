---
title: Propagate Version to Subcommands
impact: MEDIUM
impactDescription: ensures consistent versioning across CLI hierarchy
tags: derive, version, subcommands, propagation, consistency
---

## Propagate Version to Subcommands

Use `#[command(propagate_version = true)]` to automatically inherit the version flag in all subcommands.

**Incorrect (version only on root):**

```rust
#[derive(Parser)]
#[command(version)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    Build,
    Test,
}

// $ myapp --version        # Works: "myapp 1.0.0"
// $ myapp build --version  # Error: unrecognized option
```

**Correct (version propagated):**

```rust
#[derive(Parser)]
#[command(version, propagate_version = true)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    Build,
    Test,
}

// $ myapp --version        # Works: "myapp 1.0.0"
// $ myapp build --version  # Works: "myapp-build 1.0.0"
```

**Benefits:**
- Users can check version from any subcommand
- Consistent behavior with tools like `git` and `cargo`
- No manual version attribute needed on each subcommand

Reference: [Clap Command Documentation](https://docs.rs/clap/latest/clap/struct.Command.html#method.propagate_version)
