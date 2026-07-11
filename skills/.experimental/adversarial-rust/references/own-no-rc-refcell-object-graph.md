---
title: No Rc RefCell object graphs — pick owners, share by Arc field or channel
tags: own, rc-refcell, object-graph, shared-state
---

## No Rc RefCell object graphs — pick owners, share by Arc field or channel

Engineers from garbage-collected languages rebuild their object graph in Rust as `Rc<RefCell<T>>` webs: everything points at everything, mutation is checked at runtime, `borrow()` panics replace data races, and cycles leak. The strongest evidence that this is never necessary: codex-rs — a multi-crate async agent with sessions, turns, tools, and UIs — contains **zero** `Rc<RefCell<...>>` across ~2,500 files. Shared mutable state is instead (1) a single owner with narrow `Mutex` fields per concern, (2) messages over channels (`watch`/`oneshot`/`broadcast` dominate `core`), or (3) an ID-keyed owning map. `RefCell` survives only leaf-local, inside single widgets.

**Incorrect (the GC object graph, runtime-checked and cycle-prone):**

```rust
use std::cell::RefCell;
use std::rc::Rc;

struct Turn {
    session: Rc<RefCell<Session>>, // child points back at parent
    output: Vec<String>,
}

struct Session {
    turns: Vec<Rc<RefCell<Turn>>>, // parent points at children: a cycle
}
```

**Correct (one owner; shared pieces are narrow, named fields — how codex-rs shapes `Session`):**

```rust
use std::sync::Mutex;
use tokio::sync::watch;

struct Session {
    // Each concern gets its own lock; no turn ever points back up.
    state: Mutex<SessionState>,
    active_turn: Mutex<Option<Turn>>,
    agent_status: watch::Sender<AgentStatus>,
}

struct SessionState {
    approved_commands: Vec<String>,
}

struct Turn {
    output: Vec<String>,
}

#[derive(Clone)]
enum AgentStatus {
    Idle,
    Running,
}
```

The back-pointer disappears because ownership flows one way: code that has the `Session` reaches down into `active_turn`; a turn that needs to notify upward sends on a channel instead of holding a parent reference.

Reference: [codex-rs core/src/session/session.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/session/session.rs#L28), [codex-rs core/src/state/service.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/state/service.rs#L50)
