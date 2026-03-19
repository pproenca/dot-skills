---
name: rust-refactor
description: Decision frameworks for Rust refactoring, simplification, module decomposition, and incremental migration. Use this skill when simplifying Rust code, splitting large files, removing dead abstractions, migrating types incrementally, or cleaning up feature flags. Triggers on Rust refactoring, simplification, module splitting, parameter cleanup, or incremental type migration.
---

# Rust Refactoring Frameworks

This skill teaches you to look at working Rust code and see unnecessary complexity. It is not about adding abstractions -- it is about removing them. Every refactoring starts with a diagnostic question, follows a transformation pattern, and ends with a self-review checklist.

---

## The 3 Diagnostic Questions

Run these BEFORE touching any code. They determine WHAT to refactor.

### "Is this parameter just being forwarded?"

A parameter threaded through 5+ signatures, never used locally, only passed to the next call.

**Signal:** The function body only passes the parameter to another function. No local logic depends on it.
**Action:** Remove it. Replace with ambient/global access at the point of actual use. Coordinate bottom-up: remove from lowest layer first, fix compilation errors upward.

### "Is this feature flag still needed?"

A feature that reached Stable and is on for all users. The flag is dead code.

**Signal:** Stage is `Stable` or equivalent, default is enabled, no rollback planned.
**Action:** Remove the flag. Delete the conditional. Rename gated functions (`init_if_enabled` -> `init`). Remove monitoring scaffolding that tracked old/new comparison.

### "Is this file doing too many things?"

A file over ~500 lines with multiple unrelated concerns.

**Signal:** The file contains `impl` blocks or functions operating on different domains (e.g., threads AND logs AND jobs).
**Action:** Split by domain (what it operates on), not by layer. See the Module Decomposition Guide below.

---

## The 4 Refactoring Transformations

Each transformation shows a generalized before/after pattern.

### Transformation 1: Forwarded Parameter -> Ambient Access

A parameter exists only to be forwarded through a call chain until it reaches the one place that uses it.

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
    let metrics = metrics::global();  // accessed where actually needed
    if let Some(m) = metrics.as_ref() { m.counter("items_processed", 1); }
}
```

**Coordination:** Remove from the lowest layer first, fix compilation errors upward. Every intermediate commit must compile.

### Transformation 2: Monolithic File -> Domain-Split Modules

A single file has grown to 900+ lines with multiple unrelated concerns mixed together.

```
// BEFORE: one file, four concerns
src/runtime.rs  (950 lines)
  - struct Runtime + init()         (~80 lines)
  - impl Runtime: thread methods    (~200 lines)
  - impl Runtime: log methods       (~250 lines)
  - impl Runtime: job methods       (~300 lines)
  - impl Runtime: cache methods     (~120 lines)
```

```
// AFTER: domain-split modules
src/runtime/mod.rs       (~30 lines: struct def, init, re-exports)
src/runtime/threads.rs   (~200 lines: impl Runtime thread methods)
src/runtime/logs.rs      (~250 lines: impl Runtime log methods)
src/runtime/jobs.rs      (~300 lines: impl Runtime job methods)
src/runtime/cache.rs     (~120 lines: impl Runtime cache methods)
```

Each file is an `impl` block extension of the same struct. The parent `mod.rs` holds only the struct definition, initialization, and `pub use` re-exports.

**Key rule:** Tests move WITH their code. If `thread_methods` had inline tests, those tests go to `threads.rs`. Shared test helpers go to `test_support.rs`.

### Transformation 3: Big-Bang Type Change -> Incremental From Bridge

A type needs to be split or replaced, but dozens of consumers depend on it.

```rust
// STEP 1: New types alongside the old
pub enum LegacyPolicy { ReadOnly, ReadWrite, FullAccess }
pub enum FilePolicy { ReadOnly, ReadWrite }
pub enum NetworkPolicy { Restricted, Enabled }

// STEP 2: From bridges so new types derive from old
impl From<&LegacyPolicy> for NetworkPolicy {
    fn from(value: &LegacyPolicy) -> Self {
        match value {
            LegacyPolicy::FullAccess => NetworkPolicy::Enabled,
            _ => NetworkPolicy::Restricted,
        }
    }
}

// STEP 3: Runtime carries both representations simultaneously
pub struct Permissions {
    pub legacy: LegacyPolicy,           // existing consumers keep working
    pub file_policy: FilePolicy,        // new consumers use richer types
    pub network_policy: NetworkPolicy,
}
```

**Stacked changes** -- each step is a separate, independently compilable commit:
1. Add new types and `From` bridges
2. Plumb new types through runtime alongside old
3. Migrate consumers one at a time (one commit per subsystem)
4. Remove legacy type only after ALL consumers migrated

### Transformation 4: Dead Feature Flag -> Clean Removal

A feature flag gates functionality that is now unconditionally enabled for all users.

```rust
// BEFORE: gated behind feature flag
pub async fn init_if_enabled(config: &Config) -> Option<Handle> {
    if !config.features.enabled(Feature::MyFeature) {
        return None;
    }
    let handle = setup_resources(config).await?;
    Some(handle)
}

// Callers must handle the Option
if let Some(handle) = init_if_enabled(&config).await {
    handle.run().await;
}
```

```rust
// AFTER: unconditional, renamed
pub async fn init(config: &Config) -> Handle {
    setup_resources(config).await
}

// Callers simplified
let handle = init(&config).await;
handle.run().await;
```

**Full cleanup sequence:** Remove flag check -> rename function -> simplify return type -> update all callers -> mark feature variant as removed -> remove comparison/discrepancy metrics that tracked the old path.

Follow this order: ship -> stabilize -> clean structure -> optimize -> remove flag -> remove monitoring scaffolding.

---

## Module Decomposition Guide

Group code by WHAT it operates on (threads, logs, jobs, cache), not by architectural layer (models, services, controllers). Each domain file contains the `impl` block for that domain's methods on the shared struct.

Wrong: `models.rs` / `services.rs` / `controllers.rs` (layer split).
Right: `runtime/threads.rs` / `runtime/logs.rs` / `runtime/jobs.rs` (domain split, each with its own impl + tests).

### Rules

- **Tests move WITH their code.** Never leave tests behind in the original file.
- **`mod.rs` contains only re-exports.** Target ~30 lines: struct definition, `init()`, and `pub use` statements.
- **Each file under 500 lines.** If a domain file exceeds this, it has sub-domains.
- **Named types over loose parameters.** When 2+ related values are always passed together, bundle them into a struct.
- **No logic changes in extraction commits.** Move code, tests, and docs as one unit. Verify with `cargo test`.

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
```

If any item fails, you are not done. Fix it before declaring the refactoring complete.
