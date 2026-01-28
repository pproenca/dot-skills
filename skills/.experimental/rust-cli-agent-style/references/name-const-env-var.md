---
title: Name environment variable constants with _ENV_VAR suffix
impact: LOW
impactDescription: Clear distinction between config keys and their environment variable sources
tags: name, constants, environment
---

# Name environment variable constants with _ENV_VAR suffix

Constants holding environment variable names should end with `_ENV_VAR`.

## Why This Matters

- Distinguishes env var names from values
- Easy to find all env vars in codebase
- Self-documenting code
- Prevents confusion with config keys

**Incorrect (avoid this pattern):**

```rust
// Unclear if this is the env var name or something else
const CODEX_HOME: &str = "CODEX_HOME";
const API_KEY: &str = "API_KEY";
const LOG_LEVEL: &str = "LOG_LEVEL";
```

**Correct (recommended):**

```rust
/// Environment variable for the Codex home directory.
const CODEX_HOME_ENV_VAR: &str = "CODEX_HOME";

/// Environment variable for the API key.
const API_KEY_ENV_VAR: &str = "CODEX_API_KEY";

/// Environment variable for log level.
const LOG_LEVEL_ENV_VAR: &str = "CODEX_LOG_LEVEL";

// Usage
fn get_home_dir() -> Option<PathBuf> {
    std::env::var(CODEX_HOME_ENV_VAR)
        .ok()
        .map(PathBuf::from)
}
```

## Related Constants

```rust
// Default values for configs
const DEFAULT_PORT: u16 = 8080;
const DEFAULT_TIMEOUT_SECS: u64 = 30;

// Environment variable names
const PORT_ENV_VAR: &str = "CODEX_PORT";
const TIMEOUT_ENV_VAR: &str = "CODEX_TIMEOUT";

// Config file paths
const CONFIG_FILE_NAME: &str = "config.toml";
const CONFIG_DIR_NAME: &str = ".codex";
```
