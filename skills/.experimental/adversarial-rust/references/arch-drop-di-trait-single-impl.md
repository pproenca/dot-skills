---
title: Delete the dependency-injection trait with one implementation
tags: arch, traits, dependency-injection, concrete-types
---

## Delete the dependency-injection trait with one implementation

Ported from Java/C#, an `IUserService`-style trait defined so the "real" struct can be "injected" taxes the whole call graph — every caller grows a type parameter or pays a `Box<dyn>` allocation — and the swappability it pretends to buy never arrives. codex-rs runs a ~125-crate production agent with its load-bearing types fully concrete: `ModelClient` is a plain struct (no `trait ModelClient` or `dyn ModelClient` exists anywhere in the workspace), `AuthManager` is a concrete struct shared as `Arc<AuthManager>`, and `Session` is passed as bare `&Session` to 97 call sites in `core/src`. The concrete type is the seam; introduce a trait the day a second implementation actually exists.

**Incorrect (a trait whose only reason to exist is injection):**

```rust
trait ModelApi {
    fn stream(&self, prompt: &str) -> Vec<String>;
}

struct ModelClient {
    base_url: String,
}

impl ModelApi for ModelClient {
    fn stream(&self, prompt: &str) -> Vec<String> {
        vec![format!("{}: {prompt}", self.base_url)]
    }
}

// Every consumer now carries the parameter for exactly one impl.
struct Turn<M: ModelApi> {
    client: M,
}
```

**Correct (the concrete type is the seam — how codex-rs ships `ModelClient`):**

```rust
#[derive(Debug, Clone)]
struct ModelClient {
    base_url: String,
}

impl ModelClient {
    fn stream(&self, prompt: &str) -> Vec<String> {
        vec![format!("{}: {prompt}", self.base_url)]
    }
}

struct Turn {
    client: ModelClient,
}
```

**When a trait IS right:** codex-rs keeps trait seams exactly where the real implementation cannot run under test or where the host genuinely plugs in its own type — `EventSource` (live crossterm terminal events; one real impl + one channel-fed `FakeEventSource`), `KeyringStore` (the OS credential store; `DefaultKeyringStore` + an in-memory `MockKeyringStore`), `TimeProvider` (clock injection), `HttpTransport` (one real `ReqwestTransport`, ten test fakes), and the genuinely open host boundaries `ThreadStore`/`ExecBackend`. Every one of these is an I/O edge with a shipped second implementation — not an internal service wrapped "for testability".

Reference: [codex-rs core/src/client.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/client.rs#L252), [codex-rs keyring-store/src/lib.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/keyring-store/src/lib.rs#L42), [codex-rs tui/src/tui/event_stream.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/tui/src/tui/event_stream.rs#L43)
