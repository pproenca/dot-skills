---
title: Document error conditions with # Errors
impact: MEDIUM
impactDescription: Clear documentation helps users handle errors correctly
tags: err, documentation, api
---

# Document error conditions with # Errors

Public functions returning `Result` should document possible errors in a `# Errors` section.

## Why This Matters

- Users know what errors to expect
- Enables proper error handling by callers
- Part of the public API contract
- Helps during code review

**Incorrect (avoid this pattern):**

```rust
/// Loads configuration from the given path.
pub fn load_config(path: &Path) -> Result<Config, ConfigError> {
    // ...
}
// Missing error documentation!
```

**Correct (recommended):**

```rust
/// Loads configuration from the given path.
///
/// # Errors
///
/// Returns an error if:
/// - The file does not exist or cannot be read
/// - The file contents are not valid TOML
/// - Required configuration fields are missing
pub fn load_config(path: &Path) -> Result<Config, ConfigError> {
    // ...
}

/// Connects to the server at the given address.
///
/// # Errors
///
/// Returns [`ConnectionError::Timeout`] if the connection
/// cannot be established within 30 seconds.
///
/// Returns [`ConnectionError::AuthFailed`] if the provided
/// credentials are invalid.
pub async fn connect(addr: &str, creds: &Credentials) -> Result<Connection, ConnectionError> {
    // ...
}

/// Parses the command string into structured arguments.
///
/// # Errors
///
/// Returns an error if the command contains invalid syntax,
/// such as unmatched quotes or invalid escape sequences.
pub fn parse_command(cmd: &str) -> Result<ParsedCommand, ParseError> {
    // ...
}
```

## Additional Sections

Also consider documenting:
- `# Panics` - if the function can panic (should be rare with proper error handling)
- `# Safety` - for unsafe functions
