---
name: rust-idiomatic
description: Decision frameworks for writing idiomatic, production-grade Rust. Teaches ownership thinking, error design philosophy, type-driven development, and async architecture — the judgment calls that distinguish expert Rust from working Rust. Use this skill when writing Rust code, designing Rust APIs, handling errors, managing ownership/borrowing, or working with async/tokio. Triggers on Rust development, ownership patterns, error handling, async Rust, type safety, or API design.
---

# Idiomatic Rust Decision Frameworks

Writing idiomatic Rust is not about memorizing patterns -- it is about internalizing the ownership model so deeply that the right design feels obvious. This skill teaches the decision frameworks that production Rust experts use.

## Framework 1: Ownership as Architecture

The ownership system is not a constraint to work around -- it is a design tool. Every ownership decision shapes your architecture.

### The Shared Access Decision Tree

When you need shared access to data, walk this tree in order:

1. **Can you pass a reference?** Use `&T`. Zero cost, zero complexity.
2. **Might it be owned or borrowed?** Use `Cow<'_, str>`. Zero-cost when borrowed, clones only when mutation is needed.
3. **Multiple owners across sync boundaries?** Use `Arc<T>`. Prefer `Arc::clone(&x)` over `x.clone()` to signal intent.
4. **Multiple owners AND mutability?** Use `Arc<Mutex<T>>` or `Arc<RwLock<T>>`. Choose `RwLock` when reads vastly outnumber writes.
5. **Fire-and-forget spawn?** Use `move` closure with owned data. The spawned task must own everything it touches.

### The Clone Audit

Every `.clone()` is a decision point. Ask: "Is this clone necessary, or can I restructure to borrow?" Use `Arc::clone(&x)` over `x.clone()` to signal shared-ownership intent vs. deep copy.

### Forwarded Parameters Are a Smell

If a parameter exists only to be forwarded through a call chain, replace it with ambient access. A real refactor removed `otel: Option<&SessionTelemetry>` from 6+ function signatures across 28 files in 5 crates, replacing it with `codex_otel::metrics::global()`. The decision: if a parameter adds noise to every signature without providing caller-level control, it belongs in ambient state.

## Framework 2: Error Design Philosophy

Errors are debugging tools for humans, not type ceremony for the compiler.

### The Two Error Systems

This is the fundamental split. Get it wrong and you fight it everywhere:

| Context | Tool | Why |
|---------|------|-----|
| Application code (main, CLI, tests) | `anyhow::Result` + `.context()` | Rich error chains, no boilerplate |
| Library code (crates consumed by others) | `thiserror` enums | Typed, matchable, callers can branch on variants |

### The .context() Discipline

Every `?` should get a `.context()` that answers: "What was I trying to do when this failed?"

The pattern is `"failed to [verb] [noun]"` -- it describes the operation, not the error:

```rust
// Good: describes the operation that failed
.context("failed to resolve CODEX_HOME")
.context("failed to load Codex config")
.context("failed to deserialize network tables from config")
.context("failed to serialize MCP elicitation metadata")

// Bad: restates the error or says nothing
.context("error")
.context("TOML parse error")
.context("something went wrong")
```

### Error Enum Design: The CodexErr Gold Standard

Study this real error enum. Every design choice is intentional:

```rust
#[derive(Error, Debug)]
pub enum CodexErr {
    // User-facing messages include ACTIONABLE instructions
    #[error("Codex ran out of room in the model's context window. \
             Start a new thread or clear earlier history before retrying.")]
    ContextWindowExceeded,

    // Platform-specific variants keep the enum clean elsewhere
    #[cfg(target_os = "linux")]
    #[error(transparent)]
    LandlockRuleset(#[from] landlock::RulesetError),

    // Box large payloads to avoid bloating the enum size
    #[error("sandbox denied exec error...")]
    Denied { output: Box<ExecToolCallOutput> },

    // #[error(transparent)] for well-typed upstream errors
    #[error(transparent)]
    Io(#[from] io::Error),
}
```

Design principles at work:
- **User-facing messages tell the user what to do**, not what went wrong internally.
- **`#[cfg(target_os)]`** on variants keeps the enum lean per platform.
- **`Box<T>`** on large payloads prevents one variant from bloating all variants.
- **`#[error(transparent)]`** delegates display to upstream types that already format well.

### The Exhaustive is_retryable() Pattern

Classify every error variant explicitly. No wildcards. When a new variant is added, the compiler forces a decision:

```rust
impl CodexErr {
    pub fn is_retryable(&self) -> bool {
        match self {
            // Permanent failures -- no point retrying
            CodexErr::TurnAborted
            | CodexErr::ContextWindowExceeded
            | CodexErr::QuotaExceeded
            | CodexErr::Sandbox(_) => false,

            // Transient failures -- retry makes sense
            CodexErr::Stream(..)
            | CodexErr::Timeout
            | CodexErr::ConnectionFailed(_)
            | CodexErr::InternalServerError
            | CodexErr::Io(_) => true,

            #[cfg(target_os = "linux")]
            CodexErr::LandlockRuleset(_) => false,
        }
    }
}
```

The wildcard `_ => false` would silently swallow new variants. Exhaustive matching is a compile-time safety net.

## Framework 3: Type-Driven Development

Make illegal states unrepresentable. Let the compiler enforce your invariants.

### Enums Over Booleans

If a function takes `bool`, the callsite reads `foo(true, false)` -- meaningless. Replace with enums so callsites self-document: `execute("ls", SandboxMode::Restricted, NetworkPolicy::Denied)`.

### Newtypes for Identity

`fn get_thread(thread_id: String, user_id: String)` -- easy to swap arguments silently. `fn get_thread(thread_id: ThreadId, user_id: UserId)` -- compiler catches the swap. Wrap identity types.

### State Machines as Enums

Each variant holds only the data valid for that state. Invalid combinations become unrepresentable:

```rust
pub enum Stage {
    UnderDevelopment,
    Experimental {
        name: &'static str,
        menu_description: &'static str,
        announcement: &'static str,
    },
    Stable,
    Deprecated,
    Removed,
}
```

`UnderDevelopment` has no metadata -- it does not need any. `Experimental` carries exactly the metadata a menu UI requires. You cannot have a `Stable` feature with an `announcement` field because the type does not allow it.

### Named Config Types Over Loose Arguments

Replace "N loose arguments that always travel together" with a named struct:

```rust
pub enum UnifiedExecShellMode {
    Direct,
    ZshFork(ZshForkConfig),
}
pub struct ZshForkConfig {
    pub shell_zsh_path: AbsolutePathBuf,
    pub main_execve_wrapper_exe: AbsolutePathBuf,
}
```

### Incremental Migration with From Bridges

When splitting a type, do not replace it -- bridge it. Implement `From<&OldType> for NewType` so existing code keeps working while new code opts into richer types. Each PR in a stacked series converts one consumer. Every intermediate commit compiles and deploys.

## Framework 4: Async Architecture

### When to Box::pin (and When Not To)

Not "always" and not "never." Specifically: when thin async wrapper functions inline large callee futures into their state machine, causing stack pressure.

The mechanism: `async fn wrapper() { inner().await; }` stores the full `inner()` future inline as part of `wrapper()`'s state machine. In a chain of wrappers, this compounds.

```rust
// Before: wrapper inlines the full spawn path into its state machine
pub async fn start_thread(&self, config: Config) -> Result<NewThread> {
    self.start_thread_with_tools(config, Vec::new(), false).await
}

// After: child future lives on the heap, outer future stores a pointer
pub async fn start_thread(&self, config: Config) -> Result<NewThread> {
    Box::pin(self.start_thread_with_tools(config, Vec::new(), false)).await
}
```

**Debugging technique:** Build the test binary, then run it directly with progressively smaller `RUST_MIN_STACK` values. Running the binary directly (not through `cargo test`) keeps the reduced stack focused on the test process. The heuristic for where to look: thin `async fn` wrappers that mostly forward into a much larger async implementation.

### Channel Selection Guide

| Need | Channel | Why |
|------|---------|-----|
| One response back | `oneshot` | Exactly one value, then done |
| Stream of events | `mpsc` | Multiple producers, single consumer |
| Latest value only | `watch` | Receivers always see the most recent value |
| Broadcast to all | `broadcast` | Every receiver gets every message |

### Shutdown Patterns

**Use `CancellationToken` for hierarchical shutdown.** A parent token cancels all children. This models the "exit the app" -> "stop all threads" -> "stop all watchers" hierarchy naturally.

**Never rely on `Drop` for ordered async cleanup.** Use explicit shutdown methods called in the correct sequence. A real circular-Drop bug: the app-server's `Drop` waited for background tasks, but those tasks held listener references back to the app-server, creating a 5-second timeout on every exit.

```rust
// Break circular references BEFORE waiting for tasks that hold them
processor.clear_runtime_references();
processor.clear_all_thread_listeners().await;  // break the cycle
processor.drain_background_tasks().await;       // now safe to wait
processor.shutdown_threads().await;
```

**Use `let _ = tx.send()` in cleanup paths.** The receiver may already be dropped. The `let _ =` explicitly discards the `Result`, documenting that a failed send is expected and non-fatal:

```rust
let _ = self.thread_created_tx.send(thread_id);
let _ = tx.send(ReviewDecision::Denied);
```

**Do not abort watcher tasks during cleanup** if they need to emit final events. Let them finish naturally so `ExecCommandEnd` (or equivalent) is still emitted after forced termination.

### Drop Guards and Await

Never hold a `MutexGuard` across an `.await` point. The guard is not `Send`, so the compiler will reject it in most contexts. Even when it compiles, it blocks other tasks from acquiring the lock for the entire duration of the await.

## Framework 5: API Surface Design

### Accept Generics, Return Concrete

Parameters: `impl AsRef<Path>`, `impl Into<String>` -- flexible for callers. Returns: concrete types like `Config`, not `impl Trait` -- predictable for consumers.

### The Display Contract

If a type appears in user-facing output, implement `Display`. Use strum derives for config-facing enums: `EnumIter` (iterate variants in pickers), `EnumString` (parse from config), `Display` (serialize to storage), `Ord` (deterministic `BTreeMap` ordering).

### Default for Configuration

Derive `Default` on config structs. Callers use struct update syntax: `Config { timeout: 30, ..Default::default() }`.

### Feature Flags Are Temporary

Flags have a lifecycle: `UnderDevelopment` -> `Experimental` -> `Stable` -> `Deprecated` -> `Removed`. When stable and on for all users, remove the flag. Rename gated functions to match their unconditional nature (`init_if_enabled` -> `init`).

## Framework 6: Collections and Iteration

### BTreeMap for Serialized Data

`HashMap` is faster for pure lookups. `BTreeMap` gives deterministic iteration -- essential for serialization, snapshot testing, and reproducible output. Use `BTreeMap` when ordering affects correctness or debuggability.

### Iterator Chains Over Loops

`.filter_map()` instead of `.filter().map()` -- one pass, no intermediate `Option`. Method references over closures when types align: `.map(String::as_str)` not `.map(|s| s.as_str())`, `.filter_map(Result::ok)` not `.filter_map(|r| r.ok())`.

## Framework 7: Module Organization

### The 500-Line Heuristic

When a file grows beyond ~500 lines, split by domain. Each file becomes an `impl` block extension of the same struct. A real 4363-line `runtime.rs` was split into `agent_jobs.rs`, `backfill.rs`, `logs.rs`, `memories.rs`, `threads.rs` -- the parent file reduced to ~110 lines (struct definition + init only).

### Test Sibling Files

Extract tests into sibling files: `foo.rs` gets `foo_tests.rs` (linked via `#[cfg(test)] #[path = "foo_tests.rs"] mod tests;`). For `mod.rs` modules, use `mod_tests.rs`. The refactor is "structural rather than behavioral" -- no test logic changes.

### Test Naming

Pattern: `[subject]_[specific_behavior_or_edge_case]`. No `test_` prefix. Examples: `sandbox_detection_requires_keywords`, `permissions_profiles_reject_writes_outside_workspace_root`, `legacy_sandbox_mode_config_builds_split_policies_without_drift`.

## Quick Reference: Serde Patterns

```rust
#[serde(rename_all = "camelCase")]    // wire format consistency
#[serde(flatten)]                      // struct composition without nesting
#[serde(default)]                      // backward compatibility
#[serde(deny_unknown_fields)]          // strict parsing, catch typos
```

## Quick Reference: The Simplification Sequence

When shipping a feature through to production, follow this order:

1. **Ship** behind a feature flag (`Stage::UnderDevelopment`)
2. **Stabilize** by promoting to `Stage::Stable`
3. **Optimize** hot paths (e.g., lightweight `touch_updated_at` instead of full upsert)
4. **Remove scaffolding** -- drop the feature flag, remove comparison metrics, remove parameter threading
5. **Rename** gated APIs to match their unconditional nature
