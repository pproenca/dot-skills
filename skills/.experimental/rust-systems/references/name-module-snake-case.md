---
title: Use snake_case for Module Names
impact: HIGH
impactDescription: Module naming must match Rust's module resolution rules
tags: name, modules, snake-case, files
---

## Use snake_case for Module Names

All module names use snake_case. This is required for Rust's module resolution to work correctly.

**Incorrect (problematic pattern):**

```rust
mod ExitStat;           // PascalCase - won't compile
mod collectorPlugin;    // camelCase - won't compile
mod OpenSource;         // PascalCase - won't compile
mod GPU-Stats;          // kebab-case - won't compile
```text

```
src/
├── ExitStat.rs         // Wrong
├── collectorPlugin.rs  // Wrong
└── GPU-Stats.rs        // Wrong (invalid identifier)
```text

**Correct (recommended pattern):**

```rust
mod exitstat;
mod collector_plugin;
mod open_source;
mod gpu_stats;
```

```
src/
├── exitstat.rs
├── collector_plugin.rs
├── open_source.rs
└── gpu_stats.rs
```

```rust
// Module declarations match file names exactly
// lib.rs
mod exitstat;           // -> src/exitstat.rs
mod collector_plugin;   // -> src/collector_plugin.rs
mod network;            // -> src/network.rs or src/network/mod.rs
```

**When NOT to use:**
- External crate names in Cargo.toml can use kebab-case (Cargo normalizes)
- But the crate name in Rust code must use snake_case
