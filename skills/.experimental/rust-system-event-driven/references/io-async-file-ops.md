---
title: Use Async File Operations in Async Context
impact: MEDIUM
impactDescription: prevents blocking the event loop on disk I/O
tags: io, async, file, tokio, blocking
---

## Use Async File Operations in Async Context

Standard library file operations block the calling thread. In async context, use tokio's async file APIs or spawn_blocking to avoid blocking the runtime.

**Incorrect (blocks async runtime):**

```rust
async fn read_config() -> Result<Config, Error> {
    let contents = std::fs::read_to_string("config.toml")?;  // Blocks!
    toml::from_str(&contents)
}
```

**Correct (async file I/O):**

```rust
use tokio::fs;

async fn read_config() -> Result<Config, Error> {
    let contents = fs::read_to_string("config.toml").await?;
    toml::from_str(&contents)
}
```

**For operations not in tokio::fs, use spawn_blocking:**

```rust
async fn read_dir_entries(path: PathBuf) -> Result<Vec<DirEntry>, Error> {
    tokio::task::spawn_blocking(move || {
        std::fs::read_dir(path)?
            .collect::<Result<Vec<_>, _>>()
    }).await?
}
```

**When sync file I/O is acceptable:**
- Application startup before runtime starts
- One-time operations during initialization
- Single-threaded runtime with `current_thread`

Reference: [tokio::fs](https://docs.rs/tokio/latest/tokio/fs/)
