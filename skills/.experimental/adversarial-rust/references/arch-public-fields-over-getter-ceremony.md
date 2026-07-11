---
title: Plain data gets pub fields; accessors are for invariants
tags: arch, encapsulation, getters, pub-fields
---

## Plain data gets pub fields; accessors are for invariants

JavaBean reflexes generate a private field plus `get_x()`/`set_x()` pair for every member, doubling the API surface to protect invariants that don't exist. Rust's visibility answer is structural: codex-rs's central `Config` struct — the most-read type in the workspace — is all `pub` fields, and every serde protocol type (`PlanItemArg`, the event structs) exposes `pub` fields directly. Private fields appear exactly where an invariant lives: `AgentPath(String)` hides its field because every constructor runs absolute-path validation, and accessors like `allowed_domains()` exist because they return computed, normalized views rather than raw fields.

**Incorrect (getter ceremony on plain data):**

```rust
pub struct PlanItemArg {
    step: String,
    completed: bool,
}

impl PlanItemArg {
    pub fn step(&self) -> &str {
        &self.step
    }
    pub fn set_step(&mut self, step: String) {
        self.step = step;
    }
    pub fn completed(&self) -> bool {
        self.completed
    }
    pub fn set_completed(&mut self, completed: bool) {
        self.completed = completed;
    }
}
```

**Correct (data is data — how codex-rs ships its protocol types):**

```rust
pub struct PlanItemArg {
    pub step: String,
    pub completed: bool,
}
```

**When accessors ARE right:** the field's value carries a proof. codex-rs keeps `AbsolutePathBuf`'s inner `PathBuf` private because "guaranteed absolute and normalized" would be a lie the instant any caller could write the field — the private field plus validating constructors *is* the invariant. If you can't name the invariant a getter protects, the getter is ceremony.

Reference: [codex-rs core/src/config/mod.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/config/mod.rs#L611), [codex-rs protocol/src/plan_tool.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/protocol/src/plan_tool.rs#L15), [codex-rs utils/absolute-path/src/lib.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/utils/absolute-path/src/lib.rs#L23)
