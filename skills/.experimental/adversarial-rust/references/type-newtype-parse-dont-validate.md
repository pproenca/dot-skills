---
title: Parse once into a newtype; signatures carry the proof
tags: type, newtype, parse-dont-validate, validation
---

## Parse once into a newtype; signatures carry the proof

Passing domain values as raw `String`/`PathBuf` forces every function to choose between re-validating (scattered, drifting checks) and trusting (unchecked assumptions) — the classic validate-everywhere failure. codex-rs parses untrusted input **once** at the boundary into a newtype whose existence is the proof: `ThreadId` wraps a `Uuid` and its deserializer goes through `Uuid::parse_str`; `AgentPath(String)` uses `#[serde(try_from = "String")]` so even serde cannot construct an unvalidated value; `ProfileV2Name` charset-checks in `FromStr`, so the `--profile` CLI arg is validated before any code builds a file path from it. Interior functions take `&AgentPath` and validate nothing.

**Incorrect (raw primitive; every consumer re-validates or trusts):**

```rust
fn load_agent(path: &str) -> Result<String, String> {
    // Am I the one who must check this? Did my caller already?
    if !path.starts_with('/') {
        return Err(format!("not absolute: {path}"));
    }
    Ok(format!("loaded {path}"))
}
```

**Correct (parse at the boundary; the type is the proof — how codex-rs ships `AgentPath`):**

```rust
struct AgentPath(String);

impl AgentPath {
    fn from_string(path: String) -> Result<Self, String> {
        if !path.starts_with('/') {
            return Err(format!("not absolute: {path}"));
        }
        Ok(Self(path))
    }
}

impl std::str::FromStr for AgentPath {
    type Err = String;
    fn from_str(s: &str) -> Result<Self, String> {
        Self::from_string(s.to_string())
    }
}

// Interior code cannot receive an unvalidated path.
fn load_agent(path: &AgentPath) -> String {
    format!("loaded {}", path.0)
}
```

**When NOT to newtype:** where no invariant exists. codex-rs deliberately leaves model names and provider ids as raw `String` (`Config.model: Option<String>`, `model_provider_id: String`) — they are opaque tokens handed to a backend, with nothing to validate. A newtype earns its ceremony by carrying a parse; wrapping every string is cargo cult in the other direction.

Reference: [codex-rs protocol/src/agent_path.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/protocol/src/agent_path.rs#L9), [codex-rs protocol/src/thread_id.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/protocol/src/thread_id.rs#L11), [codex-rs protocol/src/config_types.rs `ProfileV2Name`](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/protocol/src/config_types.rs#L98)
