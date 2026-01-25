---
title: Add Context to Error Messages
impact: MEDIUM
impactDescription: helps users understand and fix problems quickly
tags: error, context, messages, debugging, usability
---

## Add Context to Error Messages

Provide actionable context in error messages that helps users understand what went wrong and how to fix it.

**Incorrect (generic error):**

```rust
fn parse_config(s: &str) -> Result<Config, String> {
    let config: Config = serde_json::from_str(s)
        .map_err(|e| e.to_string())?;  // "expected value at line 5 column 12"
    Ok(config)
}
```

**Correct (contextual error):**

```rust
fn parse_config(s: &str) -> Result<Config, String> {
    serde_json::from_str(s).map_err(|e| {
        format!(
            "Failed to parse config file: {}\n\
             Hint: Ensure the file is valid JSON and matches the expected schema.\n\
             Run 'myapp config --validate' to check your configuration.",
            e
        )
    })
}
```

**Pattern for file operations:**

```rust
fn read_input(path: &Path) -> Result<String, String> {
    std::fs::read_to_string(path).map_err(|e| {
        if e.kind() == std::io::ErrorKind::NotFound {
            format!("Input file not found: {}\nDid you mean to use --stdin?", path.display())
        } else if e.kind() == std::io::ErrorKind::PermissionDenied {
            format!("Permission denied reading: {}\nCheck file permissions.", path.display())
        } else {
            format!("Failed to read {}: {}", path.display(), e)
        }
    })
}
```

**Benefits:**
- Users can self-serve without reading docs
- Reduces support burden
- Clear next steps for recovery

Reference: [Clap Error Formatting](https://docs.rs/clap/latest/clap/error/struct.Error.html)
