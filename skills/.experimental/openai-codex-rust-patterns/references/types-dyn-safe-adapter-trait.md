---
title: Pair ergonomic traits with private dyn-safe adapters
impact: HIGH
impactDescription: enables zero-cost async impls while still storing heterogeneous handlers in a map
tags: types, traits, dyn, async
---

## Pair ergonomic traits with private dyn-safe adapters

An async trait with `-> impl Future<Output = ...>` gives implementers static dispatch and zero heap allocation per call — but it is not object-safe, so you cannot store `Box<dyn ToolHandler>`. Forcing implementers to return `BoxFuture<'_, _>` solves object safety but imposes allocations on every tool call. Codex keeps both: a public `ToolHandler` trait with ergonomic RPITIT, plus a module-private `AnyToolHandler` trait that is dyn-safe. A blanket `impl<T: ToolHandler> AnyToolHandler for T` is the only bridge.

**Incorrect (forces BoxFuture on every implementer):**

```rust
pub trait ToolHandler: Send + Sync {
    fn handle<'a>(
        &'a self,
        invocation: ToolInvocation,
    ) -> BoxFuture<'a, Result<Value, FunctionCallError>>;
}
// Every impl boxes its future; allocation per call.
```

**Correct (ergonomic public trait + private dyn-safe adapter):**

```rust
// core/src/tools/registry.rs
pub trait ToolHandler: Send + Sync {
    type Output: ToolOutput + 'static;
    fn kind(&self) -> ToolKind;
    fn handle(
        &self,
        invocation: ToolInvocation,
    ) -> impl std::future::Future<
        Output = Result<Self::Output, FunctionCallError>,
    > + Send;
}

trait AnyToolHandler: Send + Sync {
    fn handle_any<'a>(
        &'a self,
        invocation: ToolInvocation,
    ) -> BoxFuture<'a, Result<AnyToolResult, FunctionCallError>>;
}

impl<T> AnyToolHandler for T
where T: ToolHandler
{
    fn handle_any<'a>(
        &'a self,
        invocation: ToolInvocation,
    ) -> BoxFuture<'a, Result<AnyToolResult, FunctionCallError>> {
        Box::pin(async move {
            /* erases Self::Output into Box<dyn ToolOutput> */
        })
    }
}

pub struct ToolRegistry {
    handlers: HashMap<ToolName, Arc<dyn AnyToolHandler>>,
}
```

`AnyToolHandler` is module-private — it is an implementation detail, not an API. The `Box::pin` allocation happens exactly once per call, at the exact boundary where type erasure is needed.

Reference: `codex-rs/core/src/tools/registry.rs:39`.
