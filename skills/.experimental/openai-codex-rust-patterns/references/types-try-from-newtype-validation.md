---
title: Use serde try_from on newtypes to run validation on every parse
impact: HIGH
impactDescription: eliminates forgotten validation calls at construction sites via parse-don't-validate
tags: types, newtype, serde, smart-constructor
---

## Use serde try_from on newtypes to run validation on every parse

A plain `struct AgentPath { path: String }` with a `validate()` method fails any time a caller forgets to run it. `#[serde(try_from = "String", into = "String")]` plumbs validation through serde: every deserialization invokes your `TryFrom<String>` impl, so an invalid wire value cannot silently produce a valid type. Codex uses three newtype strategies depending on strictness — `#[serde(transparent)]` for opaque strings, `try_from/into` for validated ones, hand-rolled `Serialize`/`Deserialize` only when the in-memory representation diverges from the wire format.

**Incorrect (validation method callers must remember):**

```rust
#[derive(Deserialize)]
pub struct AgentPath { path: String }

impl AgentPath {
    pub fn validate(&self) -> Result<(), String> { /* ... */ }
}
// Bug waiting to happen: someone forgets to call validate() after deserialize.
```

**Correct (try_from runs validation on every parse):**

```rust
// protocol/src/agent_path.rs
#[derive(
    Clone, Debug, PartialEq, Eq, PartialOrd, Ord, Hash,
    Serialize, Deserialize, JsonSchema, TS,
)]
#[serde(try_from = "String", into = "String")]
#[schemars(with = "String")]
#[ts(type = "string")]
pub struct AgentPath(String);

impl AgentPath {
    pub fn from_string(path: String) -> Result<Self, String> {
        validate_absolute_path(path.as_str())?;
        Ok(Self(path))
    }
}

impl TryFrom<String> for AgentPath {
    type Error = String;
    fn try_from(value: String) -> Result<Self, Self::Error> {
        Self::from_string(value)
    }
}
```

The derived `Deserialize` automatically invokes `TryFrom<String>`, which calls `validate_absolute_path`. There is no constructor that bypasses validation — not even a private one. `#[ts(type = "string")]` and `#[schemars(with = "String")]` keep the type-export story consistent across TypeScript and JSON Schema, so consumers see a plain string, not an opaque newtype wrapper.

Reference: `codex-rs/protocol/src/agent_path.rs:9`.
