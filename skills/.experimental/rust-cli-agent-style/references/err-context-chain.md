---
title: Add context to errors with .context()
impact: HIGH
impactDescription: Error context chains make debugging production issues much easier
tags: err, context, anyhow, debugging
---

# Add context to errors with .context()

Use `.context()` or `.with_context()` from anyhow to add contextual information to errors. This creates a chain of context that aids debugging.

## Why This Matters

- Raw errors like "file not found" don't tell you WHICH file
- Context chains show the full path of what went wrong
- Invaluable for debugging production issues
- Creates human-readable error messages

**Incorrect (avoid this pattern):**

```rust
// No context - hard to debug
let data = fs::read_to_string(path)?;
let config: Config = toml::from_str(&data)?;
let response = client.get(url).send().await?;
```

**Correct (recommended):**

```rust
use anyhow::Context;

// Add context describing what operation failed
let data = fs::read_to_string(path)
    .context("failed to read config file")?;

let config: Config = toml::from_str(&data)
    .context("failed to parse config as TOML")?;

// Use with_context for dynamic messages (avoids allocation when no error)
let response = client.get(&url).send().await
    .with_context(|| format!("failed to fetch {url}"))?;

// Include relevant variables in context
let user = find_user(user_id)
    .with_context(|| format!("failed to find user {user_id}"))?;
```

## Error Output Example

With proper context:
```
Error: failed to initialize server

Caused by:
    0: failed to load configuration
    1: failed to read config file
    2: No such file or directory (os error 2)
```

Without context:
```
Error: No such file or directory (os error 2)
```
