---
name: rust-implement
description: "Write production-grade Rust code using a multi-pass approach. Design types first, then implement, then simplify, then verify with automated lint. Use this skill whenever writing new Rust functions, structs, modules, or features. Triggers on Rust implementation, new Rust code, Rust functions, Rust modules, error handling in Rust, async Rust, or type design in Rust."
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
- Does any struct have 2+ `Option<T>` fields where only one combination is valid at a time? Convert to an enum (Transformation 8).
- Does any function take 4+ parameters? Replace with an args struct (Transformation 9).

**Do not proceed to Pass 2 until the types are right. Types are the architecture.**

---

## Pass 2: Implement

Fill in the function bodies. As you write each function, apply these rules:

- Every `?` gets `.context("failed to [verb] [noun]")` -- no exceptions (Transformation 1).
- For library code: use `thiserror` for error enums. For application code: use `anyhow`.
- Use `Cow<str>` when a function sometimes borrows and sometimes allocates (Transformation 7).
- Return named structs, not tuples, from any function with 2+ return values (Transformation 5).
- Exhaustive match arms -- no `_ =>` wildcards (Transformation 4).

### Thread-Through Plumbing

When adding a new field that needs to reach execution sites, trace the full path and explicitly name every intermediate layer before writing code. For each hop, state the module and struct/function that carries the value. If you skip a layer, the field silently disappears at runtime.

### Drop/Teardown Precision

- Drop lock guards before any `.await` -- a held `MutexGuard` across an await blocks the executor.
- Close stdin explicitly in `Drop` impls. Brief wait, then fallback kill.
- Use `kill_on_drop(true)` for child processes that must not outlive their parent.
- Order cleanup deterministically: clear listeners -> drain tasks -> drop resources.

### Defensive Serialization

- `BEGIN IMMEDIATE` not `BEGIN` for SQLite write transactions (prevents `SQLITE_BUSY_SNAPSHOT`).
- Serialize lock acquisition rather than adding retries.
- `ON CONFLICT DO NOTHING` over read-then-write for idempotent inserts.

### Orphan Event Handling

When events arrive for entities that no longer exist (dead agents, closed threads), handle explicitly. Never silently drop -- log a warning and clean up stale state. Panicking on an orphan event is always wrong.

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

Error enum design: user-facing messages tell the user what to do, not what went wrong internally. `Box<T>` large payloads. Classify every variant explicitly in `is_retryable()` -- no wildcards.

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

**"Rewrite, don't rewire" principle:** When the bug is in a function's internal logic, rewrite the body with explicit checks. Don't delegate to an existing API that happens to produce the correct result for now -- the explicit version is more auditable and survives upstream changes.

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
[ ] No struct with 2+ Option<T> fields that should be an enum
[ ] No function with 4+ parameters (use args struct)
[ ] Lock guards dropped before any .await
[ ] Events for dead/missing entities handled explicitly
```

**Fix every violation before presenting the code.**

---

## Quick Reference: The 9 Transformations

Each transformation shows the exact delta between first-draft and production-grade.

### 1. `.context()` on Every `?` Operator

BEFORE:
```rust
let content = std::fs::read_to_string(path)?;
let config: Config = toml::from_str(&content)?;
```
AFTER:
```rust
let content = std::fs::read_to_string(path)
    .context("failed to read config file")?;
let config: Config = toml::from_str(&content)
    .context("failed to parse TOML config")?;
```
Pattern: `"failed to [verb] [noun]"`. The upstream error describes itself -- your job is to name the operation that broke.

### 2. Enums Over Booleans
BEFORE:
```rust
fn create_sandbox(network: bool, writable: bool) -> Sandbox {
```
AFTER:
```rust
fn create_sandbox(network: NetworkMode, access: AccessLevel) -> Sandbox {
```
`foo(true, false)` is meaningless. Replace with enums so callsites read `NetworkMode::Restricted, AccessLevel::ReadOnly`. When you cannot change the API, add `/*param_name*/` comments before opaque literals.

### 3. BTreeMap for Serialized or Compared Data
BEFORE: `HashMap<String, Rule>` -- AFTER: `BTreeMap<String, Rule>`

HashMap iteration order is random -- diffs become noisy, snapshot tests flake. Use BTreeMap whenever data is serialized, compared in tests, or shown to users.

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
When a new variant is added, the compiler flags every match that needs updating. Wildcards hide this.

### 5. Return Structs Over Tuples
BEFORE: `fn build_command() -> (Vec<String>, Vec<OwnedFd>)` -- caller writes `result.0`
AFTER: `fn build_command() -> CommandOutput` -- caller writes `output.args`, `output.preserved_fds`

Named fields are self-documenting. Define a struct for any function returning 2+ values.

### 6. `Default` Derive on Config Structs
```rust
#[derive(Default)]
pub struct ServerConfig {
    pub timeout_secs: u64,
    pub max_retries: u32,
    pub bind_addr: String,
}
let config = ServerConfig { timeout_secs: 30, ..Default::default() };
```
Derive `Default` so callers override only what matters. For non-zero defaults, implement `Default` manually.

### 7. `Cow<str>` for Conditional Ownership
BEFORE:
```rust
fn normalize_path(input: &str) -> String {
    if needs_normalization(input) { input.replace('\\', "/") }
    else { input.to_string() }  // allocates even when unchanged
}
```
AFTER:
```rust
fn normalize_path(input: &str) -> Cow<'_, str> {
    if needs_normalization(input) { Cow::Owned(input.replace('\\', "/")) }
    else { Cow::Borrowed(input) }  // zero-cost when unchanged
}
```
`Cow<str>` avoids the unconditional allocation when only some paths need to allocate.

### 8. Enum-as-Disjoint-Union

BEFORE:
```rust
struct Permissions {
    profile_name: Option<String>,       // only for named profiles
    sandbox_policy: Option<SandboxPolicy>, // only for legacy
    file_paths: Option<Vec<PathBuf>>,   // only when sandbox_policy is set
}
```

AFTER:
```rust
enum Permissions {
    Named { profile_name: String },
    Legacy { sandbox_policy: SandboxPolicy, file_paths: Vec<PathBuf> },
}
```

When a struct has `Option<T>` fields valid only in certain combinations, it permits invalid states at the type level. Convert to an enum where each variant carries only its relevant data. Diagnostic: if you see 2+ `Option<T>` fields with `is_some()`/`is_none()` guards, it should be an enum.

### 9. Struct-for-Long-Parameter-Lists

BEFORE:
```rust
fn spawn_process(
    cmd: &str,
    args: &[String],
    env: &BTreeMap<String, String>,
    cwd: &Path,
    stdin_policy: StdinPolicy,
    sandbox: SandboxPolicy,
    timeout: Duration,
) -> Result<Child> {
```

AFTER:
```rust
struct SpawnArgs<'a> {
    cmd: &'a str,
    args: &'a [String],
    env: &'a BTreeMap<String, String>,
    cwd: &'a Path,
    stdin_policy: StdinPolicy,
    sandbox: SandboxPolicy,
    timeout: Duration,
}

fn spawn_process(args: &SpawnArgs<'_>) -> Result<Child> {
```

At 4+ parameters, callsites become hard to read and easy to misorder. An args struct names each field at the callsite and makes future parameter additions non-breaking.