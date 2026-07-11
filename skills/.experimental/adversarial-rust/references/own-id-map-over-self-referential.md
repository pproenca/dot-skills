---
title: Graphs live in one owning map with ID handles, not references
tags: own, id-handles, self-referential, registry
---

## Graphs live in one owning map with ID handles, not references

When entities genuinely relate many-to-many, the imported instinct stores references (or `Rc`s) in both directions — which in Rust becomes a self-referential lifetime fight or an `Rc` cycle. codex-rs's answer, used at every registry in the workspace: one map owns the entities, keyed by a `Copy` ID newtype, and every cross-reference is stored as the ID. The thread registry is `HashMap<ThreadId, Arc<CodexThread>>`; the app server tracks which connections watch which threads as `HashMap<ConnectionId, HashSet<ThreadId>>` — IDs on both axes, never references. Self-referential machinery is entirely absent: no `ouroboros`, no `self_cell`, and all 48 `Pin<Box<...>>` hits are ordinary boxed futures.

```rust
use std::collections::{HashMap, HashSet};
use std::sync::Arc;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
struct ThreadId(u128);

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
struct ConnectionId(u64);

struct CodexThread {
    id: ThreadId,
}

#[derive(Debug)]
enum RegistryError {
    ThreadNotFound(ThreadId),
}

// One owner for the entities…
struct ThreadRegistry {
    threads: HashMap<ThreadId, Arc<CodexThread>>,
    // …and relations stored as IDs, not references into the map.
    thread_ids_by_connection: HashMap<ConnectionId, HashSet<ThreadId>>,
}

impl ThreadRegistry {
    fn get_thread(&self, thread_id: ThreadId) -> Result<Arc<CodexThread>, RegistryError> {
        self.threads
            .get(&thread_id)
            .cloned()
            .ok_or(RegistryError::ThreadNotFound(thread_id))
    }
}
```

Lookups return `Arc` clones (a pointer bump) and a typed error for the dangling case — the ID system makes "referent no longer exists" an explicit, handleable outcome instead of a dangling reference the compiler must prevent at all costs.

Reference: [codex-rs core/src/thread_manager.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/thread_manager.rs#L239), [codex-rs app-server/src/thread_state.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/app-server/src/thread_state.rs#L278), [codex-rs protocol/src/thread_id.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/protocol/src/thread_id.rs#L11)
