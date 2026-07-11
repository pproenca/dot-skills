---
title: Confine the Option god-struct to the wire; resolve it once into a rich type
tags: type, god-struct, wire-types, domain-types
---

## Confine the Option god-struct to the wire; resolve it once into a rich type

A struct where half the fields are `None` at any given time is several types flattened into one — but the naive fix ("split it!") misses where such structs legitimately come from: serde. codex-rs's `ConfigToml` makes 91 of its 97 fields `Option` because every key in a user's config file is optional-by-overridability; that shape is correct *for the file format*. The discipline is that it never travels: config loading resolves `ConfigToml` **once** into `Config`, where the Options collapse into required rich types (`Permissions`, `ModelProviderInfo`, a full layer stack). The same one-projection pattern appears in hand-written deserializers: `SessionConfiguredEvent` deserializes a private `Wire` struct accepting both legacy and current fields, projects it to the canonical field, and interior code never sees the ambiguity again.

```rust
/// Wire shape: everything optional, because the file may omit any key.
struct ConfigToml {
    model: Option<String>,
    approval_policy: Option<String>,
    cwd: Option<std::path::PathBuf>,
}

/// Domain shape: resolved once; interior code never unwraps.
struct Config {
    model: String,
    approval_policy: ApprovalPolicy,
    cwd: std::path::PathBuf,
}

enum ApprovalPolicy {
    OnRequest,
    Never,
}

#[derive(Debug)]
struct ConfigError(String);

fn resolve(wire: ConfigToml, defaults: &Config) -> Result<Config, ConfigError> {
    let approval_policy = match wire.approval_policy.as_deref() {
        None => ApprovalPolicy::OnRequest,
        Some("on-request") => ApprovalPolicy::OnRequest,
        Some("never") => ApprovalPolicy::Never,
        Some(other) => return Err(ConfigError(format!("unknown policy: {other}"))),
    };
    Ok(Config {
        model: wire.model.unwrap_or_else(|| defaults.model.clone()),
        approval_policy,
        cwd: wire.cwd.unwrap_or_else(|| defaults.cwd.clone()),
    })
}
```

The review smell is not the Option-heavy struct itself but its *reach*: if functions three layers from the parse boundary receive it and unwrap the same fields defensively, the resolve step is missing. Give the program one line where wire becomes domain, and keep the god-struct on the wire side of it.

Reference: [codex-rs config/src/config_toml.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/config/src/config_toml.rs#L154), [codex-rs core/src/config/mod.rs `Config`](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/config/mod.rs#L611), [codex-rs protocol/src/protocol.rs `Wire` deserializer](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/protocol/src/protocol.rs#L3851)
