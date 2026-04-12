---
title: Pass deserializer context via a thread-local RAII guard
impact: HIGH
impactDescription: enables serde to run path resolution without DeserializeSeed plumbing
tags: types, serde, raii, smart-constructor
---

## Pass deserializer context via a thread-local RAII guard

Serde's `Deserialize::deserialize` takes only a `Deserializer` — there is no room for extra parameters like "the base path for resolving relative values". The canonical workaround is `DeserializeSeed`, which means writing a parallel type for every context-aware struct. Codex instead stashes the context in a `thread_local! RefCell<Option<T>>` managed by an RAII guard scoped around the `from_str` call. Drop clears the slot; the `Deserialize` impl reads it and fails loudly if no guard is active and the wire value is not already self-sufficient.

**Incorrect (DeserializeSeed everywhere or post-pass mutation):**

```rust
#[derive(Deserialize)]
struct Config {
    log_path: PathBuf, // relative to what?
}
let mut cfg: Config = serde_json::from_str(src)?;
cfg.log_path = base.join(cfg.log_path); // forgot this one site → bug
```

**Correct (thread-local RAII guard, validated on deserialize):**

```rust
// utils/absolute-path/src/lib.rs
thread_local! {
    static ABSOLUTE_PATH_BASE: RefCell<Option<PathBuf>> =
        const { RefCell::new(None) };
}

pub struct AbsolutePathBufGuard;

impl AbsolutePathBufGuard {
    pub fn new(base_path: &Path) -> Self {
        ABSOLUTE_PATH_BASE.with(|cell| {
            *cell.borrow_mut() = Some(base_path.to_path_buf());
        });
        Self
    }
}

impl Drop for AbsolutePathBufGuard {
    fn drop(&mut self) {
        ABSOLUTE_PATH_BASE.with(|cell| *cell.borrow_mut() = None);
    }
}

impl<'de> Deserialize<'de> for AbsolutePathBuf {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where D: Deserializer<'de>
    {
        let path = PathBuf::deserialize(deserializer)?;
        ABSOLUTE_PATH_BASE.with(|cell| match cell.borrow().as_deref() {
            Some(base) => Ok(Self::resolve_path_against_base(path, base)),
            None if path.is_absolute() => {
                Self::from_absolute_path(path).map_err(SerdeError::custom)
            }
            None => Err(SerdeError::custom(
                "AbsolutePathBuf deserialized without a base path",
            )),
        })
    }
}
```

The guard is a zero-sized struct — it carries no data, only manages the TLS slot lifetime. Failing when no guard is active is deliberate: you cannot silently produce an invalid `AbsolutePathBuf`.

Reference: `codex-rs/utils/absolute-path/src/lib.rs:235`.
