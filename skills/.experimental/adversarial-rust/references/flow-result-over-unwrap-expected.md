---
title: Expected failures travel as Result; unwrap only with a written proof
tags: flow, unwrap, result, lints
---

## Expected failures travel as Result; unwrap only with a written proof

Exception-trained code calls `.unwrap()`/`.expect()` on anything that "should work" — file reads, lookups, parses — turning recoverable outcomes into process aborts. codex-rs makes this mechanically impossible: the workspace denies `clippy::unwrap_used` and `clippy::expect_used` in production code (tests are exempt via `clippy.toml`), so an expected failure has exactly one path — a typed `Result`, with lookups converting absence via `ok_or(CodexErr::ThreadNotFound(thread_id))`. Where a failure genuinely cannot happen, the escape hatch is deliberate ceremony: a scoped `#[expect(clippy::expect_used)]` plus an `.expect("...")` message that states the invariant, so the proof is written where the panic would be.

```toml
# codex-rs workspace Cargo.toml — enforced, not aspirational
[workspace.lints.clippy]
expect_used = "deny"
unwrap_used = "deny"
```

**Incorrect (unwrap on an outcome the caller must handle):**

```rust
use std::collections::HashMap;

fn resume(threads: &HashMap<u64, String>, thread_id: u64) -> String {
    threads.get(&thread_id).unwrap().clone() // absence is expected: aborts the agent
}
```

**Correct (absence is a typed outcome — how codex-rs resolves thread lookups):**

```rust
use std::collections::HashMap;

#[derive(Debug)]
enum CodexErr {
    ThreadNotFound(u64),
}

fn resume(threads: &HashMap<u64, String>, thread_id: u64) -> Result<String, CodexErr> {
    threads
        .get(&thread_id)
        .cloned()
        .ok_or(CodexErr::ThreadNotFound(thread_id))
}
```

**The sanctioned escape hatch (invariant written at the site):**

```rust
#[derive(serde::Serialize)]
struct Event {
    id: u32,
}

fn event_json(event: &Event) -> serde_json::Value {
    #[expect(clippy::expect_used)]
    let value = serde_json::to_value(event).expect("Event must serialize");
    value
}
```

`#[expect]` beats `#[allow]` because it errors if the escape becomes unnecessary — codex-rs's blunter file-level `#![allow(clippy::unwrap_used)]` modules are its own acknowledged weak spots, not the pattern.

Reference: [codex-rs Cargo.toml workspace lints](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/Cargo.toml#L473), [codex-rs core/src/agent/control.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/agent/control.rs#L301), [codex-rs mcp-server/src/outgoing_message.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/mcp-server/src/outgoing_message.rs#L107)
