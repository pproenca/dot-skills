---
title: Implement Borrow, AsRef, and Deref on every public ID newtype
impact: MEDIUM-HIGH
impactDescription: enables HashMap<ProcessId, V>::get(&"pid-123") without allocation
tags: types, newtype, traits, ergonomics
---

## Implement Borrow, AsRef, and Deref on every public ID newtype

Most engineers implement `AsRef<str>` and stop. But `HashMap::get` takes `&Q where Key: Borrow<Q>`, not `Key: AsRef<Q>` — so `AsRef` alone does not let you look up with a bare `&str`. Codex's public ID newtypes implement `Deref<Target=str>`, `AsRef<str>`, **and** `Borrow<str>`, plus `Display`, `From<String>`, `From<&str>`, and `From<ProcessId> for String`. The `Borrow<str>` impl is the load-bearing one: it unlocks allocation-free map lookups.

**Incorrect (missing Borrow, callers allocate on every lookup):**

```rust
#[derive(Hash, Eq, PartialEq)]
pub struct ProcessId(String);

impl AsRef<str> for ProcessId {
    fn as_ref(&self) -> &str { &self.0 }
}

// Caller: must allocate a ProcessId just to do a lookup
let found = map.get(&ProcessId(raw_string.clone()));
```

**Correct (full reference hierarchy including Borrow):**

```rust
// exec-server/src/process_id.rs
#[derive(
    Debug, Clone, PartialEq, Eq, Hash, PartialOrd, Ord,
    Serialize, Deserialize,
)]
#[serde(transparent)]
pub struct ProcessId(String);

impl Deref for ProcessId {
    type Target = str;
    fn deref(&self) -> &Self::Target { self.as_str() }
}

impl Borrow<str> for ProcessId {
    fn borrow(&self) -> &str { self.as_str() }
}

impl AsRef<str> for ProcessId {
    fn as_ref(&self) -> &str { self.as_str() }
}

// Caller: allocation-free lookup via &str
let found = map.get("pid-123"); // Works because Borrow<str> is impl'd
```

All three methods return `self.as_str()` — the implementations are trivial but the semantics are distinct, and each one unblocks a different ergonomic API. `Deref` gives you `.len()`, `.split()`, and every `&str` method transparently, so consumers almost never need `.as_str()`.

Reference: `codex-rs/exec-server/src/process_id.rs:8`.
