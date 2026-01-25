---
title: Use Command Attribute for Metadata
impact: CRITICAL
impactDescription: auto-populates version, about, and author from Cargo.toml
tags: derive, command, metadata, cargo, version
---

## Use Command Attribute for Metadata

Use `#[command(version, about, author)]` to automatically populate CLI metadata from your Cargo.toml. This keeps your CLI and manifest in sync.

**Incorrect (hardcoded metadata):**

```rust
#[derive(Parser)]
#[command(
    name = "myapp",
    version = "1.2.3",  // Duplicates Cargo.toml
    about = "A CLI tool",  // Duplicates Cargo.toml
    author = "Jane Doe"  // Duplicates Cargo.toml
)]
struct Cli {
    #[arg(short, long)]
    input: String,
}
```

**Correct (auto-populated from Cargo.toml):**

```rust
#[derive(Parser)]
#[command(version, about, author)]  // Reads from Cargo.toml
struct Cli {
    #[arg(short, long)]
    input: String,
}
```

**Alternative (custom name with auto metadata):**

```rust
#[derive(Parser)]
#[command(name = "custom-name", version, about, author)]
struct Cli {
    #[arg(short, long)]
    input: String,
}
```

**Benefits:**
- Single source of truth for version
- `--version` and `--help` stay in sync with Cargo.toml
- Less maintenance burden on version bumps

Reference: [Clap Command Attributes](https://docs.rs/clap/latest/clap/_derive/index.html)
