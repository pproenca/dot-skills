---
title: Deref is for newtypes and smart pointers, never inheritance
tags: arch, deref, inheritance, newtype
---

## Deref is for newtypes and smart pointers, never inheritance

Coders arriving from class hierarchies implement `Deref<Target = Base>` on a "derived" struct so method calls fall through to a "base" — fake inheritance that breaks trait resolution, confuses rustdoc, and silently forwards methods the wrapper should have shadowed or forbidden. codex-rs has 18 `Deref` impls across ~2,500 files and not one simulates a hierarchy: every one is a validated newtype exposing its inner primitive (`AgentPath` → `str`, `AbsolutePathBuf` → `Path`) or a smart-pointer-style wrapper (`ConstrainedWithSource<T>` → `Constrained<T>`). If two types genuinely share behavior, share it with a trait or delegate explicitly.

**Incorrect (Deref as a class hierarchy):**

```rust
use std::ops::Deref;

struct BaseWidget {
    id: u64,
}

struct TextWidget {
    base: BaseWidget,
    text: String,
}

// "TextWidget extends BaseWidget"
impl Deref for TextWidget {
    type Target = BaseWidget;
    fn deref(&self) -> &BaseWidget {
        &self.base
    }
}
```

**Correct (Deref on a validated newtype — how codex-rs ships `AgentPath`):**

```rust
use std::ops::Deref;

/// Invariant: always a validated absolute agent path.
struct AgentPath(String);

impl AgentPath {
    fn from_string(path: String) -> Result<Self, String> {
        if !path.starts_with('/') {
            return Err(format!("not absolute: {path}"));
        }
        Ok(Self(path))
    }

    fn as_str(&self) -> &str {
        self.0.as_str()
    }
}

impl Deref for AgentPath {
    type Target = str;
    fn deref(&self) -> &str {
        self.as_str()
    }
}
```

**When NOT to use this pattern:** flattening one owned options struct onto a thin wrapper — codex-rs's CLI types `Deref` to a shared `SharedCliOptions` so flags read transparently. That is composition of a single owned field for field access, not a behavior hierarchy; the moment you want method dispatch to "fall through", write the delegation by hand.

Reference: [codex-rs protocol/src/agent_path.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/protocol/src/agent_path.rs#L111), [codex-rs utils/absolute-path/src/lib.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/utils/absolute-path/src/lib.rs#L229), [codex-rs tui/src/cli.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/tui/src/cli.rs#L78)
