---
name: rust-refactor
description: Decision frameworks for Rust refactoring, simplification, module decomposition, and incremental migration. Use this skill when simplifying Rust code, splitting large files, removing dead abstractions, migrating types incrementally, or cleaning up feature flags. Triggers on Rust refactoring, simplification, module splitting, parameter cleanup, or incremental type migration.
---

# Rust Refactoring Frameworks

This skill teaches you to look at working Rust code and see unnecessary complexity. Every refactoring starts with a diagnostic question, follows a transformation pattern, and ends with a self-review checklist.

---

## The Two Refactoring Philosophies

Before touching code, decide which mode you are in.

**Defensive mode:** Add abstraction for safety. Split types. Create From bridges. Audit every consumer. Use when: security-critical code, type evolution, multi-crate dependencies.

**Offensive mode:** Delete indirection. Remove forwarded parameters. Collapse layers. Use when: the abstraction adds complexity without adding safety, the mediator just forwards, the parameter is always None.

Know which mode you are in. Do not add abstraction when you should be deleting, and do not delete safety layers when you should be adding them.

---

## The 4 Diagnostic Questions

Run these BEFORE touching any code. They determine WHAT to refactor.

### 1. "Is this parameter just being forwarded?"

**Signal:** The function body only passes the parameter to another function. No local logic depends on it.
**Action:** Remove it. Replace with ambient/global access at the point of actual use. Remove from the lowest layer first, fix compilation errors upward.

### 2. "Is this feature flag still needed?"

**Signal:** Stage is `Stable` or equivalent, default is enabled, no rollback planned.
**Action:** Remove the flag. Delete the conditional. Rename gated functions (`init_if_enabled` -> `init`). Remove monitoring scaffolding.

### 3. "Is this file doing too many things?"

**Signal:** File over ~500 lines with `impl` blocks operating on different domains (e.g., threads AND logs AND jobs).
**Action:** Split by domain (what it operates on), not by layer. See Module Decomposition Guide below.

### 4. "Does this struct have mutually exclusive optional fields?"

**Signal:** 2+ `Option<T>` fields where only one should be set at a time. Code like `if a.is_some() { assert!(b.is_none()) }` or fields named `x_config` that only apply to one mode.
**Action:** Convert to an enum where each variant carries only its relevant data.

```rust
// BEFORE: invalid states representable
struct Auth { api_key: Option<String>, oauth_token: Option<String>, storage: Option<TokenStore> }
// AFTER: each variant carries only what it needs
enum Auth { ApiKey(String), OAuth { token: String, storage: TokenStore } }
```

---

## The 6 Refactoring Transformations

### Transformation 1: Forwarded Parameter -> Ambient Access

```rust
// BEFORE: metrics threaded through every signature, never used locally
pub async fn process_batch(db: &Database, config: &Config,
    metrics: Option<&MetricsClient>) {           // forwarded
    for item in db.pending_items(config).await? {
        process_item(db, item, metrics).await?;  // forwarded again
    }
}
// AFTER: ambient access at the single point of use
pub async fn process_batch(db: &Database, config: &Config) {
    for item in db.pending_items(config).await? {
        process_item(db, item).await?;
    }
}
pub async fn process_item(db: &Database, item: Item) {
    let result = transform(item)?;
    db.save(result).await?;
    if let Some(m) = metrics::global().as_ref() { m.counter("items_processed", 1); }
}
```

**Coordination:** Remove from the lowest layer first. Every intermediate commit must compile.

### Transformation 2: Monolithic File -> Domain-Split Modules

```
// BEFORE: src/runtime.rs (950 lines, four concerns)
// AFTER:
src/runtime/mod.rs       (~30 lines: struct def, init, re-exports)
src/runtime/threads.rs   (~200 lines)
src/runtime/logs.rs      (~250 lines)
src/runtime/jobs.rs      (~300 lines)
src/runtime/cache.rs     (~120 lines)
```

Each file is an `impl` block extension of the same struct. Tests move WITH their code.

### Transformation 3: Big-Bang Type Change -> Incremental From Bridge

```rust
// STEP 1: New types alongside old, with From bridges
impl From<&LegacyPolicy> for NetworkPolicy {
    fn from(value: &LegacyPolicy) -> Self {
        match value {
            LegacyPolicy::FullAccess => NetworkPolicy::Enabled,
            _ => NetworkPolicy::Restricted,
        }
    }
}
// STEP 2: Runtime carries both representations simultaneously
pub struct Permissions {
    pub legacy: LegacyPolicy,         // existing consumers keep working
    pub network_policy: NetworkPolicy, // new consumers use richer types
}
```

**Stacked changes** -- each step is a separate, independently compilable commit:
1. Add new types and `From` bridges
2. Plumb new types through runtime alongside old
3. Migrate consumers one at a time (one commit per subsystem)
4. Remove legacy type only after ALL consumers migrated

### Transformation 4: Dead Feature Flag -> Clean Removal

```rust
// BEFORE: init_if_enabled(config) -> Option<Handle>
// AFTER:  init(config) -> Handle  (unconditional, renamed)
```

**Full cleanup sequence:**
1. Remove flag check from all call sites
2. Rename gated functions: `init_if_enabled` -> `init`
3. Simplify return types: `Option<Handle>` -> `Handle`
4. Move the flag to `Stage::Removed` in the features registry
5. Remove conditional branches entirely (do not just change the default)
6. Check `#[cfg(feature = "...")]` in Cargo.toml -- make those deps unconditional
7. Remove comparison/discrepancy metrics that tracked old vs new path
8. Delete the feature flag definition

Order: ship -> stabilize -> clean structure -> optimize -> remove flag -> remove scaffolding.

### Transformation 5: Crate Extraction with Measurement

Not just code organization -- this is about build performance.

```
# 1. Measure baseline
cargo build -p parent-crate --timings   # record check + test compile time
# 2. Extract: create new crate, move code, add re-exports for backward compat
# 3. Measure after
cargo build -p parent-crate --timings   # compare
# 4. Report in commit message:
#    cargo check: 57.08s -> 53.54s (~6.2% faster)
#    cargo test --no-run: 2m39.9s -> 2m20s (~12.4% faster)
```

**Extraction sequence:**
1. Identify a domain-coherent boundary with self-contained dependencies
2. Create new crate with minimal Cargo.toml
3. Move code, keeping re-exports in the original crate for backward compat
4. Update workspace manifests and lockfiles
5. Verify: `cargo test -p parent-crate && cargo test -p new-crate`

### Transformation 6: Mutually Exclusive Options -> Enum

```rust
// BEFORE: three options, only one valid at a time
struct ShellMode {
    direct_cmd: Option<String>,
    zsh_fork_config: Option<ZshForkConfig>,
    pty_handle: Option<PtyHandle>,
}
// AFTER: disjoint union, invalid states unrepresentable
enum ShellMode { Direct(String), ZshFork(ZshForkConfig), Pty(PtyHandle) }
```

**Steps:** Audit construction sites for valid combinations -> define enum variants -> replace struct construction -> replace `if x.is_some()` with `match` -> remove defensive assertions.

---

## The "Rewrite, Don't Rewire" Principle

When the bug is in a function's LOGIC (not its wiring), rewrite the body with explicit ordered checks. Do not delegate to an existing API that happens to produce correct results.

```rust
// WRONG: rewire through existing API ("happens to work")
fn resolve_policy(input: &Input) -> Policy {
    default_policy(input).override_with(input.overrides())
}
// RIGHT: explicit ordered checks
fn resolve_policy(input: &Input) -> Policy {
    if input.is_admin() { return Policy::FullAccess; }
    if input.has_restriction("network") { return Policy::NetworkDenied; }
    if input.is_sandbox_mode() { return Policy::ReadOnly; }
    Policy::Standard
}
```

The explicit version is more auditable, more testable, and more robust to future changes in the delegated implementation.

---

## Module Decomposition Guide

Group code by WHAT it operates on, not by architectural layer. Each domain file contains the `impl` block for that domain's methods on the shared struct.

Wrong: `models.rs` / `services.rs` / `controllers.rs` (layer split).
Right: `runtime/threads.rs` / `runtime/logs.rs` / `runtime/jobs.rs` (domain split).

**Rules:**
- Tests move WITH their code. Never leave tests behind in the original file.
- `mod.rs` contains only re-exports. Target ~30 lines.
- Each file under 500 lines. If exceeded, it has sub-domains.
- Named types over loose parameters. 2+ related values always passed together -> struct.
- No logic changes in extraction commits. Move code as one unit. Verify with `cargo test`.

---

## Self-Review Checklist

Run this after every refactoring. Every item must pass.

```
After refactoring, verify:
[ ] Every intermediate state compiles (no big-bang rewrites)
[ ] From bridges exist for any split types
[ ] Tests moved with their code (not left behind)
[ ] No new single-use helper functions introduced
[ ] Removed more code than you added (or justified why not)
[ ] No forwarded parameters remain (each param is used locally)
[ ] Module re-exports are clean (public API in mod.rs)
[ ] Feature flags for stable features removed
[ ] Structs with mutually exclusive options converted to enums
[ ] Build performance measured before/after crate extraction
[ ] Feature flag removal includes function renames and branch deletion
[ ] Chose the right refactoring mode (defensive vs offensive)
[ ] Function logic rewritten, not just rewired through delegation
```

If any item fails, you are not done. Fix it before declaring the refactoring complete.
