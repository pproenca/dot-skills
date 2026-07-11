---
title: One enum whose variants own their data, not bool and String flags
tags: type, enums, state-machine, illegal-states
---

## One enum whose variants own their data, not bool and String flags

State modeled as `mode: String` plus loose per-mode fields lets the flags contradict each other — `mode == "read-only"` with `writable_roots` populated is representable, so somewhere it happens. codex-rs models every mode as an enum whose variants *own* the fields valid for them: `SandboxPolicy::WorkspaceWrite` carries `writable_roots`, `ReadOnly` carries only `network_access`, and `DangerFullAccess` carries nothing — the invalid combinations don't typecheck. On its `ExternalSandbox` variant the discipline goes one step further: network access there is the two-variant enum `NetworkAccess { Restricted, Enabled }` rather than a `bool`, because a named variant survives refactors and reads unambiguously at call sites where a bare `true` does not.

**Incorrect (stringly mode + loose fields that can contradict it):**

```rust
struct SandboxConfig {
    mode: String, // "read-only" | "workspace-write" | "danger-full-access"
    writable_roots: Vec<std::path::PathBuf>,
    network_access: bool,
}
```

**Correct (each variant owns exactly the data valid for it — how codex-rs ships `SandboxPolicy`):**

```rust
use std::path::PathBuf;

enum SandboxPolicy {
    DangerFullAccess,
    ReadOnly {
        network_access: bool,
    },
    WorkspaceWrite {
        writable_roots: Vec<PathBuf>,
        network_access: bool,
    },
    ExternalSandbox {
        network_access: NetworkAccess,
    },
}

enum NetworkAccess {
    Restricted,
    Enabled,
}

impl NetworkAccess {
    fn is_enabled(&self) -> bool {
        matches!(self, NetworkAccess::Enabled)
    }
}
```

The same shape repeats wherever an outcome carries outcome-specific payload: codex-rs's `SafetyCheck` is `AutoApprove { sandbox_type, .. } | AskUser | Reject { reason }` — not `(bool, Option<String>, Option<SandboxType>)` — and `ReviewDecision` attaches policy-amendment payloads to exactly the decisions that can carry them. The bool projection, when needed, is a method (`is_enabled()`), derived from the enum at the last moment.

Reference: [codex-rs protocol/src/protocol.rs `SandboxPolicy`](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/protocol/src/protocol.rs#L988), [codex-rs core/src/safety.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/safety.rs#L20), [codex-rs protocol/src/protocol.rs `ReviewDecision`](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/protocol/src/protocol.rs#L3976)
