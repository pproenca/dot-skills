---
title: Enable Suggestions for Typos
impact: MEDIUM
impactDescription: reduces user frustration by 50%+ on typos
tags: error, suggestions, typos, usability, recovery
---

## Enable Suggestions for Typos

Clap automatically suggests corrections for misspelled arguments and subcommands. Ensure this feature is enabled.

**Incorrect (no typo recovery):**

```rust
fn parse_format(s: &str) -> Result<Format, String> {
    match s.to_lowercase().as_str() {
        "json" => Ok(Format::Json),
        "yaml" => Ok(Format::Yaml),
        _ => Err(format!("Unknown format: {}", s)),  // No suggestion
    }
}
// User types "jsno" and gets no help
```

**Correct (helpful suggestions):**

```rust
fn parse_format(s: &str) -> Result<Format, String> {
    match s.to_lowercase().as_str() {
        "json" => Ok(Format::Json),
        "yaml" | "yml" => Ok(Format::Yaml),
        "toml" => Ok(Format::Toml),
        other => Err(format!(
            "Unknown format '{}'. Did you mean 'json', 'yaml', or 'toml'?",
            other
        )),
    }
}
// User types "jsno" and sees: Did you mean 'json'?
```

**Clap's built-in suggestions:**

```bash
$ myapp delpoy
error: unrecognized subcommand 'delpoy'

  tip: a similar subcommand exists: 'deploy'

Usage: myapp <COMMAND>
```

This works automatically when using `#[derive(Subcommand)]`.

Reference: [Clap Error Suggestions](https://docs.rs/clap/latest/clap/struct.Command.html)
