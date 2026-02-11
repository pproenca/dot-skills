---
title: Use SCREAMING_SNAKE_CASE for Constants
impact: MEDIUM
impactDescription: Visual distinction for immutable values helps identify compile-time constants
tags: name, constants, statics, screaming-snake-case
---

## Use SCREAMING_SNAKE_CASE for Constants

Module-level constants and statics use SCREAMING_SNAKE_CASE. This visually distinguishes compile-time constants from runtime values.

**Incorrect (problematic pattern):**

```rust
const ShardTime: u64 = 24 * 60 * 60;           // PascalCase - wrong
const maxChunkSize: u32 = 32768;               // camelCase - wrong
static defaultPath: &str = "/var/log/myapp";   // camelCase - wrong
```

**Correct (recommended pattern):**

```rust
const SHARD_TIME: u64 = 24 * 60 * 60;
const MAX_CHUNK_SIZE: u32 = 32768;
const INDEX_ENTRY_SIZE: usize = 24;
const DEFAULT_STORE_PATH: &str = "/var/log/myapp";

static GLOBAL_CONFIG: Lazy<Config> = Lazy::new(|| Config::load());

// In impl blocks for associated constants
impl RenderConfig {
    const DEFAULT_WIDTH: u32 = 80;
    const MAX_LINES: usize = 1000;
}
```

```rust
// Trait associated constants
pub trait QueriableContainer {
    const IDX_PLACEHOLDER: &'static str = "<idx>.";
}
```

**When NOT to use:**
- Local `let` bindings (use snake_case even if effectively constant)
- Enum variants (use PascalCase)
