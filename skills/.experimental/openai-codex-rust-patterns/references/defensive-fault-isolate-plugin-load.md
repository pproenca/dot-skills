---
title: Load untrusted plugins fault-isolated and sanitize their model-facing text
impact: HIGH
impactDescription: one broken or hostile plugin can't fail startup or inject the model's prompt
tags: defensive, plugins, untrusted-input, prompt-injection
---

## Load untrusted plugins fault-isolated and sanitize their model-facing text

A plugin manifest is untrusted input, so the two reflexive choices are both wrong: `?`-propagating a load error lets one malformed plugin abort startup for everyone, and forwarding the manifest's `description` straight into the model's capability summary hands an attacker a prompt-injection channel. Codex treats each plugin as a fault domain — a failed load becomes an inert record, not a hard error — and runs every manifest string through a sanitizer before it can reach the model.

**Incorrect (one bad plugin kills startup; manifest text reaches the model raw):**

```rust
for cfg in configs {
    let plugin = load_plugin(cfg)?; // a single failure aborts the whole load
    summary.push(plugin.manifest_description.unwrap_or_default()); // unbounded, injectable
}
```

**Correct (error captured per plugin; description sanitized and capped):**

```rust
// plugin/src/load_outcome.rs
pub struct LoadedPlugin<M> {
    pub error: Option<String>, // a load failure is recorded, not propagated
    /* ... */
}
impl<M> LoadedPlugin<M> {
    pub fn is_active(&self) -> bool {
        self.enabled && self.error.is_none() // errored plugins are silently excluded
    }
}

pub fn prompt_safe_plugin_description(description: Option<&str>) -> Option<String> {
    let description = description?.split_whitespace().collect::<Vec<_>>().join(" ");
    (!description.is_empty())
        .then(|| description.chars().take(MAX_CAPABILITY_SUMMARY_DESCRIPTION_LEN).collect())
}
```

Whitespace is collapsed (defeating layout-based injection) and the result is hard-capped at 1024 chars before it ever enters a model-facing summary. Plugin id segments are separately validated to `[A-Za-z0-9_-]` so a manifest can't smuggle `../` into the on-disk cache path. The shape generalizes: untrusted extension input is isolated per-unit and sanitized at the boundary.

Reference: `codex-rs/plugin/src/load_outcome.rs:32`, `codex-rs/plugin/src/plugin_id.rs:51`.
