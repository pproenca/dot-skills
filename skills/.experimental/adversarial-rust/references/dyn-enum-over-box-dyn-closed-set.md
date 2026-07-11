---
title: Use an enum for a closed set; reserve dyn for sets others extend
tags: dyn, trait-objects, enums, dispatch
---

## Use an enum for a closed set; reserve dyn for sets others extend

"Program to an interface" reflexively produces `trait Event` + `Box<dyn Event>` for what is actually a fixed set of shapes — trading exhaustive matching, `derive`d serde, and direct field access for vtable indirection and downcasting. codex-rs draws the line by one question: *can code you don't control add a variant?* Its wire shapes are all tagged enums matched exhaustively — `Op` (submissions), `EventMsg` (agent events), `TurnItem`, and the three-variant `ToolPayload` — while `dyn` appears exactly where the set is genuinely open: the tool registry is `HashMap<ToolName, Arc<dyn CoreToolRuntime>>` because MCP servers, extensions, and dynamic tools register handlers unknown at compile time. Both live in the same subsystem: the *payload* a tool receives is a closed enum; the *handler* it dispatches to is an open trait object.

**Incorrect (trait-object zoo for a fixed set of shapes):**

```rust
trait Event {
    fn kind(&self) -> &'static str;
}

struct ErrorEvent {
    message: String,
}
struct AgentMessageEvent {
    text: String,
}

impl Event for ErrorEvent {
    fn kind(&self) -> &'static str {
        "error"
    }
}
impl Event for AgentMessageEvent {
    fn kind(&self) -> &'static str {
        "agent_message"
    }
}

fn render(event: &dyn Event) -> String {
    event.kind().to_string() // fields unreachable without downcasting
}
```

**Correct (the closed set is an enum, matched exhaustively — how codex-rs ships `EventMsg`):**

```rust
enum EventMsg {
    Error(ErrorEvent),
    AgentMessage(AgentMessageEvent),
}

struct ErrorEvent {
    message: String,
}
struct AgentMessageEvent {
    text: String,
}

fn render(event: &EventMsg) -> String {
    // Adding a variant makes every match a compile error until handled.
    match event {
        EventMsg::Error(e) => format!("error: {}", e.message),
        EventMsg::AgentMessage(m) => m.text.clone(),
    }
}
```

**When dyn IS right:** the implementor set is open (codex-rs's tool registry, its heterogeneous TUI cells `Arc<dyn HistoryCell>`) or host-supplied (`HttpClient`, `ThreadStore`, `ExecBackend` — the embedding application picks the backend). For sets you control but expect to extend across a protocol boundary, codex-rs marks the enum `#[non_exhaustive]` (`Op`, `UserInput`) — still an enum, with the openness declared to downstream crates instead of erased.

Reference: [codex-rs protocol/src/protocol.rs `EventMsg`](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/protocol/src/protocol.rs#L1267), [codex-rs core/src/tools/registry.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/tools/registry.rs#L322), [codex-rs tools/src/tool_payload.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/tools/src/tool_payload.rs#L6)
