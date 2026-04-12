---
title: Split tool errors into respond-to-model and fatal variants
impact: HIGH
impactDescription: eliminates downcasting every failure to decide whether the LLM can recover
tags: errors, agent, tool-dispatch, thiserror
---

## Split tool errors into respond-to-model and fatal variants

In an agent loop, some tool failures should be surfaced back to the LLM as function-call output so the model can react ("file not found — try another path"), while others should abort the whole turn (auth expired, disk full). Codex defines `FunctionCallError` with variant names that encode *where the error flows*, not what went wrong. Every tool handler in the crate returns `Result<T, FunctionCallError>`. The upper layer has one match that converts `RespondToModel` into a conversation item and `Fatal` into a terminal `CodexErr::Fatal`.

**Incorrect (anyhow::Error forces downstream downcasting):**

```rust
fn handle_apply_patch(argv: &[String]) -> anyhow::Result<String> {
    if /* missing file */ {
        anyhow::bail!("patch rejected: file not found");
    }
    /* ... */
}
// Upper layer: try to downcast or string-match to decide what to do.
```

**Correct (two variants encoded at the construction site):**

```rust
// core/src/function_tool.rs
#[derive(Debug, thiserror::Error, PartialEq)]
pub enum FunctionCallError {
    #[error("{0}")]
    RespondToModel(String),
    #[error("LocalShellCall without call_id or id")]
    MissingLocalShellCallId,
    #[error("Fatal error: {0}")]
    Fatal(String),
}

// core/src/stream_events_utils.rs — upper layer matches once
Err(FunctionCallError::RespondToModel(message)) => {
    let response = ResponseInputItem::FunctionCallOutput {
        call_id: String::new(),
        output: FunctionCallOutputPayload {
            body: FunctionCallOutputBody::Text(message),
            ..Default::default()
        },
    };
    output.needs_follow_up = true;
}
Err(FunctionCallError::Fatal(message)) => {
    return Err(CodexErr::Fatal(message));
}
```

Handlers convert every downstream error at the construction site — `apply_patch` turns a patch rejection into `RespondToModel(...)` while authentication failures become `Fatal`. There is no `#[from]` conversion: the crate author wants callers to consciously choose.

Reference: `codex-rs/core/src/function_tool.rs:4`, `codex-rs/core/src/stream_events_utils.rs:303`.
