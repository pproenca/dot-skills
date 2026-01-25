---
title: Use Nested Subcommands for Complex CLIs
impact: MEDIUM-HIGH
impactDescription: enables git-style deep command hierarchies
tags: subcmd, nested, hierarchy, organization, scaling
---

## Use Nested Subcommands for Complex CLIs

Use nested enums with `#[command(subcommand)]` to create multi-level command hierarchies for complex CLIs.

**Incorrect (flat structure for related commands):**

```rust
#[derive(Subcommand)]
enum Commands {
    ConfigGet { key: String },
    ConfigSet { key: String, value: String },
    ConfigList,
    CacheGet { key: String },
    CacheClear,
}
// myapp config-get key
// myapp cache-clear
```

**Correct (nested structure groups related commands):**

```rust
#[derive(Subcommand)]
enum Commands {
    #[command(subcommand)]
    Config(ConfigCommands),
    #[command(subcommand)]
    Cache(CacheCommands),
}

#[derive(Subcommand)]
enum ConfigCommands {
    Get { key: String },
    Set { key: String, value: String },
    List,
}

#[derive(Subcommand)]
enum CacheCommands {
    Get { key: String },
    Clear,
}

// myapp config get key
// myapp cache clear
```

**Benefits:**
- Logical grouping improves discoverability
- `myapp config --help` shows only config commands
- Scales to large CLIs like `kubectl` or `docker`

Reference: [Clap Subcommand Documentation](https://docs.rs/clap/latest/clap/trait.Subcommand.html)
