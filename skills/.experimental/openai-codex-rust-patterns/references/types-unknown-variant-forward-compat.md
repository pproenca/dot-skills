---
title: Preserve unrecognized wire values in an Unknown variant
impact: HIGH
impactDescription: prevents older readers from crashing on configs written by newer versions
tags: types, enums, serde, forward-compat
---

## Preserve unrecognized wire values in an Unknown variant

Forward compatibility is the dual of `#[non_exhaustive]`. `non_exhaustive` says "you can add variants in the next version"; forward compatibility says "a reader on an older version must not reject values it does not recognize". Codex's `FileSystemSpecialPath` has an explicit `Unknown { path: String, subpath: Option<PathBuf> }` variant that captures any tag not matched by the known ones. An older runtime loads the new config, passes the Unknown through unchanged on round-trips, and writes it back out — the config file is never corrupted by a downgrade.

**Incorrect (strict enum — old reader crashes on new config):**

```rust
#[derive(Deserialize)]
#[serde(tag = "kind", rename_all = "snake_case")]
pub enum FileSystemSpecialPath {
    Root,
    Tmpdir,
    SlashTmp,
}
// New version adds a Minimal variant. Old version:
// `serde: unknown variant `minimal`` — config file fails to load.
```

**Correct (Unknown variant captures the tail):**

```rust
// protocol/src/permissions.rs
#[derive(
    Debug, Clone, PartialEq, Eq, Serialize, Deserialize, JsonSchema, TS,
)]
#[serde(tag = "kind", rename_all = "snake_case")]
#[ts(tag = "kind")]
pub enum FileSystemSpecialPath {
    Root,
    Minimal,
    CurrentWorkingDirectory,
    ProjectRoots { subpath: Option<PathBuf> },
    Tmpdir,
    SlashTmp,
    /// WARNING: `:special_path` tokens are part of config compatibility.
    /// New parser support should be additive, while unknown values must stay
    /// representable so config from a newer Codex degrades to warn-and-ignore
    /// instead of failing to load. Codex 0.112.0 rejected unknown values
    /// here, which broke forward compatibility for newer config.
    Unknown {
        path: String,
        subpath: Option<PathBuf>,
    },
}
```

The `Unknown` variant carries the raw string, not a parsed form — you cannot lose the original value by round-tripping through this type. The warning doc comment is load-bearing; it names a real regression (`Codex 0.112.0`) that future editors must not reintroduce.

Reference: `codex-rs/protocol/src/permissions.rs:78`.
