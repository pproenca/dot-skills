---
name: rust-implement
description: Write production-grade Rust with expert-level error handling, type design, ownership, async patterns, and migration discipline. Use this skill whenever writing new Rust functions, structs, modules, or refactoring existing Rust code. Triggers on Rust implementation tasks, new features, error handling, type design, async architecture, or any Rust code generation.
---

# Rust Implementation Discipline

Apply these transformations, frameworks, and the final checklist to every piece of Rust you write. The transformations are the specific behavioral deltas that distinguish expert output. The frameworks are the decision trees for harder judgment calls. The checklist is the enforcement mechanism.

## The 7 Transformations

Each transformation shows the exact delta between first-draft and production-grade. Apply all seven to every module you write.

### 1. `.context()` on Every `?` Operator

BEFORE:
```rust
let content = std::fs::read_to_string(path)?;
let config: Config = toml::from_str(&content)?;
let conn = db.connect(url).await?;
```

AFTER:
```rust
let content = std::fs::read_to_string(path)
    .context("failed to read config file")?;
let config: Config = toml::from_str(&content)
    .context("failed to parse TOML config")?;
let conn = db.connect(url).await
    .context("failed to connect to database")?;
```

The context string answers: "What was I trying to do when this failed?" Pattern: `"failed to [verb] [noun]"`. The upstream error already describes itself -- your job is to name the operation that broke.

Bad context strings restate the error or say nothing:
```rust
.context("error")              // says nothing
.context("TOML parse error")   // restates the error
.context("something went wrong") // useless in a log
```

### 2. Enums Over Booleans

BEFORE:
```rust
fn create_sandbox(network: bool, writable: bool) -> Sandbox {
    open_connection(path, true, None, 0)
```

AFTER:
```rust
fn create_sandbox(network: NetworkMode, access: AccessLevel) -> Sandbox {
    open_connection(path, /*writable*/ true, /*encoding*/ None, /*retries*/ 0)
```

`foo(true, false)` at a callsite is meaningless. Replace with enums so the callsite reads `create_sandbox(NetworkMode::Restricted, AccessLevel::ReadOnly)`. When you cannot change the API, add `/*param_name*/` comments before opaque literals.

### 3. BTreeMap for Serialized or Compared Data

BEFORE:
```rust
use std::collections::HashMap;
pub struct PolicyConfig {
    pub rules: HashMap<String, Rule>,
}
```

AFTER:
```rust
use std::collections::BTreeMap;
pub struct PolicyConfig {
    pub rules: BTreeMap<String, Rule>,
}
```

HashMap iteration order is random. Diffs become noisy, snapshot tests flake, serialized output changes between runs. Use BTreeMap whenever the data is serialized, compared in tests, or shown to users. HashMap is only correct when ordering never affects output.

### 4. Exhaustive Match Without Wildcards

BEFORE:
```rust
match decision {
    PolicyDecision::Allow => true,
    _ => false,
}
```

AFTER:
```rust
match decision {
    PolicyDecision::Allow => true,
    PolicyDecision::Block { .. } => false,
    PolicyDecision::Rewrite { .. } => false,
    PolicyDecision::Ask { .. } => false,
}
```

When someone adds `PolicyDecision::RateLimit` next month, the compiler flags every match that needs updating. Wildcards hide this. Apply the same discipline to `is_retryable()`, `Display`, and any classification logic.

### 5. Return Structs Over Tuples

BEFORE:
```rust
fn build_command() -> (Vec<String>, Vec<OwnedFd>) {
    // caller writes result.0, result.1
```

AFTER:
```rust
struct CommandOutput {
    args: Vec<String>,
    preserved_fds: Vec<OwnedFd>,
}
fn build_command() -> CommandOutput {
    // caller writes output.args, output.preserved_fds
```

`result.0` and `result.1` are meaningless at the callsite. Named fields are self-documenting. Apply this the moment a function returns more than one value.

### 6. `Default` Derive on Config Structs

BEFORE:
```rust
pub struct ServerConfig {
    pub timeout_secs: u64,
    pub max_retries: u32,
    pub bind_addr: String,
}
// caller must specify every field
```

AFTER:
```rust
#[derive(Default)]
pub struct ServerConfig {
    pub timeout_secs: u64,
    pub max_retries: u32,
    pub bind_addr: String,
}
// caller uses struct update syntax
let config = ServerConfig { timeout_secs: 30, ..Default::default() };
```

Config structs without `Default` force callers to specify every field, even the ones they do not care about. Derive `Default` and let callers override only what matters. For non-zero defaults, implement `Default` manually.

### 7. `Cow<str>` for Conditional Ownership

BEFORE:
```rust
fn normalize_path(input: &str) -> String {
    if needs_normalization(input) {
        input.replace('\\', "/")   // allocates always
    } else {
        input.to_string()          // allocates even when unchanged
    }
}
```

AFTER:
```rust
fn normalize_path(input: &str) -> Cow<'_, str> {
    if needs_normalization(input) {
        Cow::Owned(input.replace('\\', "/"))
    } else {
        Cow::Borrowed(input)       // zero-cost when unchanged
    }
}
```

When a function sometimes needs to allocate and sometimes can return a borrow, `Cow<str>` avoids the unconditional allocation. Walk the shared access tree: can you borrow? Use `&T`. Might it be owned or borrowed? Use `Cow<'_, str>`.

---

## Decision Frameworks

### Ownership Decision Tree

Walk this tree in order when you need shared access to data:

1. **Can you pass a reference?** Use `&T`. Zero cost, zero complexity.
2. **Might it be owned or borrowed?** Use `Cow<'_, str>`. Zero-cost when borrowed, clones only when mutation is needed.
3. **Multiple owners across sync boundaries?** Use `Arc<T>`. Prefer `Arc::clone(&x)` over `x.clone()` to signal shared-ownership intent.
4. **Multiple owners AND mutability?** Use `Arc<Mutex<T>>` or `Arc<RwLock<T>>`. Choose `RwLock` when reads vastly outnumber writes.
5. **Fire-and-forget spawn?** Use `move` closure with owned data. The spawned task must own everything it touches.

**Clone audit:** Every `.clone()` is a decision point. Ask: "Is this clone necessary, or can I restructure to borrow?"

**Forwarded parameters are a smell:** If a parameter exists only to be forwarded through a call chain, replace it with ambient access. If a parameter adds noise to every signature without providing caller-level control, it belongs in ambient state.

### Error Philosophy

| Context | Tool | Why |
|---------|------|-----|
| Application code (main, CLI, tests) | `anyhow::Result` + `.context()` | Rich error chains, no boilerplate |
| Library code (crates consumed by others) | `thiserror` enums | Typed, matchable, callers can branch on variants |

**Error enum design principles:**
- User-facing messages tell the user what to do, not what went wrong internally
- `#[cfg(target_os)]` on variants keeps the enum lean per platform
- `Box<T>` on large payloads prevents one variant from bloating all variants
- `#[error(transparent)]` delegates display to upstream types that already format well
- Classify every variant explicitly in `is_retryable()` -- no wildcards, no defaults

**The `.context()` discipline is non-negotiable.** Every `?` gets a `.context()`. No exceptions outside `#[cfg(test)]`.

### Async Decisions

**When to `Box::pin`:** When thin async wrapper functions inline large callee futures into their state machine, causing stack pressure. `async fn wrapper() { inner().await; }` stores the full `inner()` future inline. In a chain of wrappers, this compounds. Wrap the inner call: `Box::pin(self.inner_method(args)).await`.

**Channel selection:**

| Need | Channel | Why |
|------|---------|-----|
| One response back | `oneshot` | Exactly one value, then done |
| Stream of events | `mpsc` | Multiple producers, single consumer |
| Latest value only | `watch` | Receivers always see the most recent value |
| Broadcast to all | `broadcast` | Every receiver gets every message |

**Shutdown patterns:**
- Use `CancellationToken` for hierarchical shutdown. A parent token cancels all children.
- Never rely on `Drop` for ordered async cleanup. Use explicit shutdown methods in the correct sequence.
- Use `let _ = tx.send()` in cleanup paths. The receiver may already be dropped. The `let _ =` documents that failure is expected.
- Never hold a `MutexGuard` across an `.await` point.

### Incremental Migration

Large refactors fail when they change everything at once. The correct approach:

1. **Create new types alongside old types.** Do not delete the old type.
2. **Write `From<&OldType> for NewType` bridges** so existing code keeps working.
3. **Migrate consumers one PR at a time.** Every intermediate commit compiles and passes tests.
4. **Delete the old type only after every consumer has migrated.**

**Stacked changes:** Each PR in the series is independently reviewable and deployable. Refactors are "structural, not behavioral" -- move code, tests, and docs together. No logic changes in the same commit as a structural move.

**The simplification sequence after shipping:**
1. Ship behind a feature flag
2. Stabilize by promoting to stable
3. Optimize hot paths
4. Remove scaffolding -- drop the flag, remove comparison metrics, remove parameter threading
5. Rename gated APIs to match their unconditional nature (`init_if_enabled` -> `init`)

---

## Self-Review Checklist

After writing code, verify line by line. Fix every violation before presenting the code.

```
[ ] Every ? has .context("failed to [verb] [noun]")
[ ] No unwrap() outside #[cfg(test)]
[ ] BTreeMap where output is serialized or compared
[ ] No bool parameters -- use enums
[ ] Match arms exhaustive -- no _ => wildcards
[ ] Config structs derive Default
[ ] No single-use helper functions -- inline if called once
[ ] Module under 500 lines (excluding tests)
[ ] No .clone() without justification -- prefer borrowing
[ ] Return structs, not tuples, for multi-value returns
[ ] Cow<str> where allocation is conditional
[ ] Serde attrs present: rename_all, default, deny_unknown_fields as needed
```

This checklist is the enforcement mechanism. Passive context alone does not change behavior. Active verification does. Run it on every module, every time.
