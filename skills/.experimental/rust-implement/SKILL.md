---
name: rust-implement
description: Write production-grade Rust code using a multi-pass approach: design types first, then implement, then simplify, then verify with automated lint. Use this skill whenever writing new Rust functions, structs, modules, or features. Triggers on Rust implementation, new Rust code, Rust functions, Rust modules, error handling in Rust, async Rust, or type design in Rust.
---

# Rust Implementation Discipline

Write code in passes. Experts don't produce perfect code in one shot -- they design, implement, review, and simplify. Follow this process for every module you write.

---

## Pass 1: Design Types and Signatures

Before writing any implementation, write ONLY the type definitions and function signatures. No bodies. No logic.

Ask yourself these questions before moving on:

- Can any enum state represent an invalid combination? If yes, restructure so invalid states are unrepresentable.
- Are all parameters self-documenting? Replace `bool` params with enums (Transformation 2).
- Does every struct that will be serialized or compared use `BTreeMap`, not `HashMap` (Transformation 3)?
- Do config structs derive `Default` (Transformation 6)?
- Would a caller confuse the order of String parameters? Use newtypes.

**Do not proceed to Pass 2 until the types are right. Types are the architecture.**

---

## Pass 2: Implement

Fill in the function bodies. As you write each function, apply these rules:

- Every `?` gets `.context("failed to [verb] [noun]")` -- no exceptions (Transformation 1).
- For library code: use `thiserror` for error enums. For application code: use `anyhow`.
- Use `Cow<str>` when a function sometimes borrows and sometimes allocates (Transformation 7).
- Return named structs, not tuples, from any function with 2+ return values (Transformation 5).
- Exhaustive match arms -- no `_ =>` wildcards (Transformation 4).

### Ownership Decision Tree

Walk this tree in order when you need shared access to data:

1. **Can you pass a reference?** Use `&T`. Zero cost, zero complexity.
2. **Might it be owned or borrowed?** Use `Cow<'_, str>`. Zero-cost when borrowed.
3. **Multiple owners across sync boundaries?** Use `Arc<T>`. Prefer `Arc::clone(&x)` over `x.clone()`.
4. **Multiple owners AND mutability?** Use `Arc<Mutex<T>>` or `Arc<RwLock<T>>`. Choose `RwLock` when reads vastly outnumber writes.
5. **Fire-and-forget spawn?** Use `move` closure with owned data.

Every `.clone()` is a decision point. Ask: "Is this clone necessary, or can I restructure to borrow?"

### Error Philosophy

| Context | Tool | Why |
|---------|------|-----|
| Application code (main, CLI, tests) | `anyhow::Result` + `.context()` | Rich error chains, no boilerplate |
| Library code (crates consumed by others) | `thiserror` enums | Typed, matchable, callers can branch on variants |

Error enum design: user-facing messages tell the user what to do, not what went wrong internally. `Box<T>` on large payloads prevents one variant from bloating all variants. Classify every variant explicitly in `is_retryable()` -- no wildcards.

### Async Decisions

**When to `Box::pin`:** When thin async wrappers inline large callee futures into their state machine, causing stack pressure. Wrap the inner call: `Box::pin(self.inner_method(args)).await`.

| Need | Channel | Why |
|------|---------|-----|
| One response back | `oneshot` | Exactly one value, then done |
| Stream of events | `mpsc` | Multiple producers, single consumer |
| Latest value only | `watch` | Receivers always see the most recent value |
| Broadcast to all | `broadcast` | Every receiver gets every message |

Shutdown: use `CancellationToken` for hierarchical shutdown. Never rely on `Drop` for ordered async cleanup. Never hold a `MutexGuard` across an `.await` point.

---

## Pass 3: Simplify

Review your code as if you're trying to REMOVE things, not add them.

Three diagnostic questions:

1. **Is any parameter just forwarded through a call chain?** Remove it, use ambient access.
2. **Is any field or function unused?** Delete it.
3. **Is any abstraction unjustified?** (single-use helper, wrapper that adds nothing) Inline it.

If you added more code than the task strictly requires, something is wrong. Cut it.

---

## Pass 4: Verify

Run the bundled lint script on your code:

```bash
bash ${SKILL_DIR}/scripts/lint.sh <your-file.rs>
```

Fix every ERROR. Review every WARNING. Then do the manual checklist:

```
[ ] Every ? has .context("failed to [verb] [noun]")
[ ] No unwrap() outside #[cfg(test)]
[ ] BTreeMap where output is serialized or compared
[ ] No bool parameters -- use enums
[ ] Match arms exhaustive -- no _ => wildcards
[ ] Config structs derive Default
[ ] No single-use helper functions -- inline if called once
[ ] Module under 500 lines (excluding tests)
[ ] No unnecessary .clone() -- prefer borrowing
[ ] Return structs, not tuples, for multi-value returns
[ ] Cow<str> where allocation is conditional
[ ] serde attrs present: rename_all, default, deny_unknown_fields as needed
```

**Fix every violation before presenting the code.**

---

## Quick Reference: The 7 Transformations

Each transformation shows the exact delta between first-draft and production-grade.

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

HashMap iteration order is random. Diffs become noisy, snapshot tests flake, serialized output changes between runs. Use BTreeMap whenever the data is serialized, compared in tests, or shown to users.

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

When someone adds `PolicyDecision::RateLimit` next month, the compiler flags every match that needs updating. Wildcards hide this.

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

`result.0` and `result.1` are meaningless at the callsite. Named fields are self-documenting.

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

Config structs without `Default` force callers to specify every field. Derive `Default` and let callers override only what matters. For non-zero defaults, implement `Default` manually.

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

When a function sometimes needs to allocate and sometimes can return a borrow, `Cow<str>` avoids the unconditional allocation.
