---
title: Generic Fn parameters at the API; box only for storage; channels over listeners
tags: dyn, callbacks, generics, channels
---

## Generic Fn parameters at the API; box only for storage; channels over listeners

The JavaScript/Java habit types every callback parameter as `Box<dyn Fn(...)>`, forcing an allocation and dynamic dispatch on callers who were passing a plain closure. codex-rs's boundary is precise (171 generic `F: Fn`/`impl Fn` parameters against ~30 boxed-Fn occurrences): public functions take a generic `F`, and the erasure to `Box<dyn Fn>` happens *inside*, only when the closure must be **stored** in a homogeneous collection — its RPC router registers handlers via `fn request<P, R, F, Fut>(&mut self, method, handler: F)` and boxes internally into the route map. For event notification, codex-rs skips callbacks entirely: `core` never registers listeners — it sends protocol events down a channel (`tx_event.send(event).await`) and whoever cares consumes the receiver.

**Incorrect (boxed parameter taxes every caller for no reason):**

```rust
struct Router {
    routes: Vec<(String, Box<dyn Fn(String) -> String + Send + Sync>)>,
}

impl Router {
    fn request(&mut self, method: &str, handler: Box<dyn Fn(String) -> String + Send + Sync>) {
        self.routes.push((method.to_string(), handler));
    }
}
```

**Correct (generic at the rim, boxed only in storage — how codex-rs ships its RPC router):**

```rust
struct Router {
    routes: Vec<(String, Box<dyn Fn(String) -> String + Send + Sync>)>,
}

impl Router {
    fn request<F>(&mut self, method: &str, handler: F)
    where
        F: Fn(String) -> String + Send + Sync + 'static,
    {
        // Callers pass a bare closure; the Box is an implementation detail.
        self.routes.push((method.to_string(), Box::new(handler)));
    }
}
```

**When the callback should be a channel:** the "callback" is really an event feed with subscription lifetime — on-event, on-progress, on-change registrations. codex-rs pushes `Event`s over an `async_channel`/`watch` instead, which buys backpressure, `select!`-ability, and freedom from the reentrancy and `Send + Sync + 'static` contagion a stored callback imposes. A blanket `impl<F: Fn(..)> Trait for F` (codex-rs's `NetworkPolicyDecider`) is the bridge form: the seam is a trait, yet any closure satisfies it without wrapping.

Reference: [codex-rs exec-server/src/rpc.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/exec-server/src/rpc.rs#L138), [codex-rs network-proxy/src/network_policy.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/network-proxy/src/network_policy.rs#L289), [codex-rs core/src/session/session.rs `tx_event`](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/session/session.rs#L31)
