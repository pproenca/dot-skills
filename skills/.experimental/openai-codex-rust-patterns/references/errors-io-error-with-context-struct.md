---
title: Wrap io::Error in a struct with a context field
impact: MEDIUM-HIGH
impactDescription: enables PartialEq tests against IoError without dragging anyhow into a library crate
tags: errors, io, thiserror, library
---

## Wrap io::Error in a struct with a context field

`anyhow::Context` gives you the "operation context plus underlying cause" shape, but it forces `anyhow` on every downstream consumer and makes `PartialEq` test assertions impossible — which matters when you are testing the shape of an error enum, not just the message. Codex defines a named struct with a `context: String` field and a `#[source] source: std::io::Error` field, derives `thiserror::Error` with `#[error("{context}: {source}")]`, and adds a blanket `From<io::Error>` that supplies a default context for bare `?` propagation.

**Incorrect (anyhow leaks into a library crate):**

```rust
// apply-patch/src/lib.rs
pub fn parse_patch(path: &Path) -> anyhow::Result<Patch> {
    let data = std::fs::read_to_string(path)
        .with_context(|| format!("Failed to read {}", path.display()))?;
    /* ... */
}
// Consumers must take an anyhow dependency; no PartialEq on anyhow::Error.
```

**Correct (named struct with context, no anyhow):**

```rust
// apply-patch/src/lib.rs
#[derive(Debug, thiserror::Error)]
#[error("{context}: {source}")]
pub struct IoError {
    context: String,
    #[source]
    source: std::io::Error,
}

impl PartialEq for IoError {
    fn eq(&self, other: &Self) -> bool {
        self.context == other.context
            && self.source.to_string() == other.source.to_string()
    }
}

impl From<std::io::Error> for ApplyPatchError {
    fn from(err: std::io::Error) -> Self {
        ApplyPatchError::IoError(IoError {
            context: "I/O error".to_string(),
            source: err,
        })
    }
}

// Callers upgrade the context where they know better:
return Err(ApplyPatchError::IoError(IoError {
    context: format!("Failed to read {}", path.display()),
    source: e,
}));
```

`#[source]` (not `#[from]`) on the field is deliberate — the derivation intentionally does not auto-wrap raw `io::Error` into `IoError`; that is what the hand-written `From` is for, so the default context is visible at the boundary. The custom `PartialEq` uses `source.to_string()` because `io::Error` does not implement `PartialEq`.

Reference: `codex-rs/apply-patch/src/lib.rs:58`, `codex-rs/apply-patch/src/invocation.rs:177`.
