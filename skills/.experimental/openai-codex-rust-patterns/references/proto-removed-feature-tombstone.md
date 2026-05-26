---
title: Keep removed feature flags as parseable no-op tombstones
impact: MEDIUM-HIGH
impactDescription: lets old and new configs round-trip across versions without parse failures
tags: proto, features, forward-compat, config
---

## Keep removed feature flags as parseable no-op tombstones

The instinct when retiring a feature is to delete its enum variant and config key. But now an older config file that still sets the key fails to parse on the new binary, and a config written by the new binary may surprise an older one — the flag becomes a hard compatibility break in both directions. Codex models a flag's whole lifecycle in a `Stage` enum and keeps removed flags as inert, still-parseable entries; the value is ignored but the key never errors.

**Incorrect (deleting the variant breaks existing configs):**

```rust
pub enum Feature {
    ShellTool,
    // WebSearch removed — now {"web_search": true} in any saved config fails to parse
}
```

**Correct (Stage::Removed tombstone, ignored not rejected):**

```rust
// features/src/lib.rs
pub enum Stage {
    UnderDevelopment,
    Experimental { name: &'static str, menu_description: &'static str, announcement: &'static str },
    Stable,
    Deprecated,
    /// The feature flag is useless but kept for backward compatibility.
    Removed,
}

// apply_map: a Removed key is consumed and skipped, never an error;
// a genuinely unknown key is warn!-logged, not fatal.
```

A `Removed` flag is excluded from the experimental menu and from metrics, but it still parses, so configs survive across versions in both directions. The same registry distinguishes `Removed` (kept for compat) from `Deprecated` (still works, discouraged) — two different promises to existing users. This is the config-evolution dual of [[types-unknown-variant-forward-compat]].

Reference: `codex-rs/features/src/lib.rs:44`, `codex-rs/features/src/lib.rs:413`.
