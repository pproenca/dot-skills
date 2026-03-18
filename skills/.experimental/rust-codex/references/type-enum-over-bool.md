---
title: Use Enums Over Bool Parameters
impact: CRITICAL
impactDescription: prevents wrong-argument bugs, makes callsites self-documenting
tags: type, enums, api-design, readability
---

## Use Enums Over Bool Parameters

Avoid bool or ambiguous `Option` parameters that force callers to write hard-to-read code such as `foo(false)` or `bar(None)`. Prefer enums, named methods, newtypes, or other idiomatic Rust API shapes that keep the callsite self-documenting.

**Incorrect (callsite is opaque):**

```rust
fn create_sandbox(
    network: bool,
    writable: bool,
    elevated: bool,
) -> SandboxResult {
    // Caller writes: create_sandbox(true, false, true)
    // Which bool is which?
}
```

**Correct (callsite reads like documentation):**

```rust
enum NetworkAccess { Allowed, Blocked }
enum FileSystemMode { ReadOnly, Writable }
enum SandboxLevel { Standard, Elevated }

fn create_sandbox(
    network: NetworkAccess,
    fs_mode: FileSystemMode,
    level: SandboxLevel,
) -> SandboxResult {
    // Caller writes:
    // create_sandbox(NetworkAccess::Allowed, FileSystemMode::ReadOnly, SandboxLevel::Elevated)
}
```
