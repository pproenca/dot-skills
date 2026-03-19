---
name: rust-codex
description: Decision frameworks for writing production Rust code in the codex-rs codebase at the level of its top contributors. Use this skill whenever writing, reviewing, or refactoring Rust code in a large async codebase with strict conventions. Triggers on Rust code in codex-rs, sandbox policies, app-server protocol, TUI development, or any task mentioning codex conventions.
---

# Codex-RS Decision Frameworks

This skill teaches you to think like Michael Bolin and jif-oai -- the top contributors to codex-rs. It is not a style guide. It is a set of decision frameworks for the hard choices that separate competent Rust from production-grade Rust in this codebase.

For granular rule details, see the `references/` directory.

---

## Framework 1: Error Design as Debugging Tool

The question is never "did I handle the error?" It is "when this fails at 3am, will the log message tell me exactly which operation broke?"

### The `.context()` discipline

`.context()` strings describe the OPERATION being attempted, not the error that occurred. The upstream error already describes itself. Your job is to say what you were trying to do when it failed.

Pattern: `"failed to [verb] [noun]"` or `"[noun] [constraint]"`.

Real strings from the codebase (`codex-rs/core/src/`):
- `"failed to resolve CODEX_HOME"` -- `network_proxy_loader.rs:44`
- `"failed to load Codex config"` -- `network_proxy_loader.rs:55`
- `"failed to deserialize network tables from config"` -- `network_proxy_loader.rs:177`
- `"config persistence task panicked"` -- `config/edit.rs:752`
- `"failed to serialize MCP elicitation metadata"` -- `mcp_connection_manager.rs:319`
- `"elicitation request channel closed unexpectedly"` -- `mcp_connection_manager.rs:363`
- `"Failed to read auth token for remote skills"` -- `skills/remote.rs:118`

When you write `.context("invalid response")`, stop. That describes the error, not the operation. Write `.context("failed to parse provider response")` instead.

### The `is_retryable()` exhaustive match

Every `CodexErr` variant is explicitly classified. The match is exhaustive -- adding a new variant forces a conscious decision at compile time. From `error.rs:194`:

```rust
pub fn is_retryable(&self) -> bool {
    match self {
        CodexErr::TurnAborted | CodexErr::Fatal(_) | CodexErr::Sandbox(_)
        | CodexErr::ContextWindowExceeded | CodexErr::ServerOverloaded => false,
        CodexErr::Stream(..) | CodexErr::Timeout | CodexErr::ConnectionFailed(_)
        | CodexErr::Io(_) | CodexErr::Json(_) => true,
        #[cfg(target_os = "linux")]
        CodexErr::LandlockRuleset(_) | CodexErr::LandlockPathFd(_) => false,
    }
}
```

No wildcards, no defaults. Platform-specific variants use `#[cfg(target_os = "linux")]` directly on enum arms. Large payloads like `ExecToolCallOutput` are `Box`ed to avoid bloating enum size (see `SandboxErr`).

---

## Framework 2: Incremental Migration Architecture

Large refactors fail when they try to change everything at once. Bolin's approach: introduce the new alongside the old, bridge them with `From`, migrate consumers one PR at a time.

### The From Bridge pattern

Commit `f82678b2` -- splitting `SandboxPolicy` into `FileSystemSandboxPolicy` + `NetworkSandboxPolicy`. The old enum conflated three concerns. Dozens of consumers depended on it. Instead of rewriting them all:

1. Create the new split types alongside the old type
2. Write `From<&SandboxPolicy>` bridges so the new types derive from the old
3. Make the runtime carry both representations simultaneously

From `protocol/src/permissions.rs:702`:

```rust
impl From<&SandboxPolicy> for NetworkSandboxPolicy {
    fn from(value: &SandboxPolicy) -> Self {
        if value.has_full_network_access() {
            NetworkSandboxPolicy::Enabled
        } else {
            NetworkSandboxPolicy::Restricted
        }
    }
}
```

The runtime `Permissions` struct (`config/mod.rs:196`) stores the legacy projection AND the new split types side by side. Existing code keeps working; new code opts into the richer types.

### The stacked PR approach

This was not one commit. It was a 9-PR stack, each independently reviewable and deployable:

1. `#13434` -- config: add new types and From bridges
2. `#13439` -- sandboxing: plumb split policies through runtime
3. `#13440` -- protocol: derive effective file access
4. `#13445` -- safety: honor filesystem policy in apply_patch
5. `#13448` -- seatbelt: honor split policies
6. `#13449` -- linux-sandbox: plumb through helper
7. `#13451` -- sandboxing: preserve denied paths when widening
8. `#13452` -- protocol: keep root carveouts sandboxed
9. `#13453` -- linux-sandbox: honor split policies in bwrap

Every intermediate commit compiles and passes tests. The legacy type is never deleted until every consumer has migrated.

### The refactor-first principle

Bolin's refactors are explicitly "structural rather than behavioral" (commit `0c8a3667`). When extracting code, move the related tests and docs with it. No logic changes in the same commit. Commit `b859a98e` demonstrates the corollary: replace loose parameters threaded through the runtime with a named config type (`UnifiedExecShellMode::ZshFork(ZshForkConfig)`).

---

## Framework 3: Simplification Instinct

jif-oai's defining quality: the ability to look at working code and see unnecessary complexity. Ask three questions.

### "Is this parameter just being forwarded?"

Commit `cf143bf` -- removing `otel: Option<&SessionTelemetry>` from 28 files across 5 crates. This parameter existed purely to be forwarded through `StateRuntime::init`, `state_db::init`, `backfill_sessions`, and more:

```rust
// BEFORE: parameter threaded through every signature
pub(crate) async fn backfill_sessions(
    runtime: &codex_state::StateRuntime, config: &Config,
    otel: Option<&SessionTelemetry>,
) {
    let timer = otel.and_then(|otel| otel.start_timer(...).ok());

// AFTER: ambient access at point of use
pub(crate) async fn backfill_sessions(
    runtime: &codex_state::StateRuntime, config: &Config,
) {
    let metric_client = codex_otel::metrics::global();
    let timer = metric_client.as_ref().and_then(|otel| otel.start_timer(...).ok());
```

Coordinate bottom-up: remove from the lowest layer (`state`), then fix compilation errors upward through `core` -> `app-server`/`cli`/`tui`.

### "Is this feature flag still needed?"

Commit `fa16c26` -- dropping `Feature::Sqlite` after it reached Stable. The variant moves to `Stage::Removed`, the function renames from `init_if_enabled` to `init`. jif-oai's full simplification sequence for the DB layer:

| PR | Action |
|----|--------|
| `#12141` | Land sqlite, move to `Stage::Stable` |
| `#12905` | Split 4363-line file into 6 modules |
| `#13620` | Optimize DB flushing |
| `#13750` | Remove `Feature::Sqlite` flag |
| `#13753` | Remove discrepancy metrics |
| `#13771` | Remove `otel` parameter threading |

Ship -> stabilize -> clean -> optimize -> remove scaffolding. In that order.

### "Is this file doing too many things?"

Commit `79d6f80` -- splitting `runtime.rs` (4363 lines) into 6 domain modules:

| File | Lines | Domain |
|------|-------|--------|
| `runtime/agent_jobs.rs` | 562 | Agent job CRUD |
| `runtime/backfill.rs` | 311 | Backfill state |
| `runtime/logs.rs` | 715 | Log operations |
| `runtime/memories.rs` | 2252 | Memory lifecycle |
| `runtime/threads.rs` | 496 | Thread metadata |
| `runtime/test_support.rs` | 64 | Shared test helpers |

Split by domain (what it operates on), not by layer. Each file becomes an `impl` block extension of the same `StateRuntime` struct. The parent `runtime.rs` shrinks to ~110 lines: just `init()` and the struct definition.

---

## Framework 4: App-Server Protocol Design

When designing a new API endpoint, follow this complete mental model.

### The naming system

- `*Params` -- client-to-server request payload
- `*Response` -- server-to-client response payload
- `*Notification` -- server-pushed event (no request)

RPC methods: `<resource>/<method>`, singular resource. Examples: `thread/read`, `app/list`, `config/write`.

### The wire format rules

Complete example of a v2 endpoint:

```rust
#[derive(Serialize, Deserialize, TS)]
#[serde(rename_all = "camelCase")]
#[ts(export, export_to = "v2/")]
pub struct ThreadReadParams {
    pub thread_id: String,                      // String IDs at boundary
    #[ts(optional = nullable)]
    pub include_history: Option<bool>,           // optional = nullable on Params
}

#[derive(Serialize, Deserialize, TS)]
#[serde(rename_all = "camelCase")]
#[ts(export, export_to = "v2/")]
pub struct ThreadReadResponse {
    pub thread_id: String,
    pub created_at: i64,                        // Unix seconds, *_at naming
    pub updated_at: i64,
}
```

Key rules: never `skip_serializing_if` on v2 fields (exception: parameterless `params: Option<()>`). For experimental surface: `#[experimental("method")]` and `ExperimentalApi` derive for field-level gating.

### Designing a new endpoint

1. Define `FooBarParams` and `FooBarResponse` with the derives above
2. Add the method to `define_api!` in `common.rs`
3. Run `just write-app-server-schema` then `cargo test -p codex-app-server-protocol`

---

## Framework 5: Async Architecture Decisions

### Box::pin: when and why

Commit `7134220f` -- `async fn` compiles into a state machine. When a wrapper awaits an inner future inline, the outer future stores the entire inner future as part of its own state. In a chain of thin wrappers, this silently inflates stack usage:

```rust
// BEFORE: inner future inlined into wrapper's state machine
pub async fn start_thread(&self, config: Config) -> CodexResult<NewThread> {
    self.start_thread_with_tools(config, Vec::new(), false).await
}

// AFTER: child future heap-allocated, wrapper stores only a pointer
pub async fn start_thread(&self, config: Config) -> CodexResult<NewThread> {
    Box::pin(self.start_thread_with_tools(config, Vec::new(), false)).await
}
```

Applied to 14 convenience wrappers in `thread_manager.rs`. Debugging methodology: build the test binary, then re-run with progressively smaller `RUST_MIN_STACK` values to quantify headroom. After the fix, the binary passed at 917504 bytes and overflowed at 786432.

Heuristic: if stack overflow occurs in tests, inspect thin `async fn` wrappers that forward into larger async implementations.

### Shutdown coordination

Never rely on `Drop` for ordered async cleanup. jif-oai's freeze fix (commit `c04a0a7`): a circular `Drop` dependency where the app-server waited for listeners that held references back to itself. The fix: call `clear_all_thread_listeners()` to break circular references BEFORE calling `drain_background_tasks()`. Explicit shutdown methods in correct order, not implicit `Drop`.

### Patterns for async cleanup

- **`let _ = tx.send()`** -- for fire-and-forget sends during cleanup where the receiver may be gone. The `let _ =` documents that failure is expected and non-fatal. Found throughout: `thread_manager.rs:810`, `codex_delegate.rs:732`, `shell_snapshot.rs:106`.
- **Thread-scoped shutdown intent** -- use `Option<ThreadId>` over a global boolean to track intentional shutdown (commit `851fcc3`). Events from other threads still take the normal failover path.

---

## Framework 6: Test Design Methodology

### What to test

Cover these six dimensions for every behavior, drawn from Bolin's test suites:

1. **Positive behavior** -- `sandbox_detection_identifies_keyword_in_stderr`
2. **Boundary rejection** -- `sandbox_detection_respects_quick_reject_exit_codes`
3. **Mode-specific bypass** -- `sandbox_detection_ignores_non_sandbox_mode`
4. **Platform differences** -- `windows_restricted_token_skips_external_sandbox_policies`
5. **Legacy compatibility** -- `legacy_sandbox_mode_config_builds_split_policies_without_drift`
6. **Degenerate input** -- `aggregate_output_rebalances_when_stderr_is_small`

### Test naming

Encode `subject_behavior_edge_case`. Real names from the codebase:
- `config_toml_deserializes_permission_profiles`
- `permissions_profiles_reject_writes_outside_workspace_root`
- `under_development_features_are_disabled_by_default`
- `collab_is_legacy_alias_for_multi_agent`
- `usage_limit_reached_error_formats_free_plan`
- `unexpected_status_cloudflare_html_is_simplified`
- `sandbox_denied_reports_both_streams_when_available`
- `apps_require_feature_flag_and_chatgpt_auth`

### Test data and infrastructure

Construct test data as typed structs with factory helpers (`make_exec_output`, `stdio_mcp`), never JSON strings. Use `pretty_assertions::assert_eq` for struct comparisons. Key infrastructure: `wiremock` + `mount_sse_once` + `ResponseMock` for HTTP, `wait_for_event` for async, `TempDir` for isolation, `insta` + `assert_snapshot!` for TUI (render to `Buffer`, convert to string).

### The sibling `_tests.rs` convention

At the bottom of every production module: `#[cfg(test)] #[path = "foo_tests.rs"] mod tests;`. Test file begins with `use super::*;`. For `mod.rs`, use `mod_tests.rs`. Applied across 70+ files in commit `0c8a3667`.

---

## Framework 7: Module Decomposition

Not "keep files under 500 LoC" -- understand WHY things go together.

### Bolin: structural, not behavioral

When extracting code to a new module, no logic changes in the same commit. Move code, tests, and docs as one unit. Verify with `cargo test -p codex-core --lib && just fix -p codex-core && cargo fmt --check`.

### jif-oai: domain, not layer

Split by what the code operates on (threads, memories, logs, jobs), not by architectural layer. Each file is an `impl` block extension of the parent struct. The parent `mod.rs` holds only the struct definition, `init()`, and re-exports.

### Named types over loose parameters

From commit `b859a98e`: when related values are threaded as separate arguments, bundle them into `UnifiedExecShellMode::ZshFork(ZshForkConfig)` instead of passing two paths independently.

---

## Quick Reference: Surface Conventions

These are the mechanical rules from AGENTS.md. Follow them without thinking.

**Naming**: Crate prefix `codex-`. Inline args in `format!("{x}")`. Exhaustive `match`, no wildcards. `/*param_name*/` before opaque literals. `BTreeMap` for deterministic serialization.

**Clippy**: Always collapse `if` statements. Always inline format args. Use method references over closures.

**Config**: Run `just write-config-schema` after `ConfigToml` changes. Run `just bazel-lock-update` after `Cargo.toml` changes. Update `BUILD.bazel` for `include_str!` / `include_bytes!` / `sqlx::migrate!`.

**TUI**: Use `Stylize` helpers (`.dim()`, `.bold()`, `.cyan()`). Never use `.white()`. Use `textwrap` for wrapping. Mirror changes between `tui` and `tui_app_server`.

**After changes**: Run `just fmt`, then `cargo test -p codex-<crate>`. Before finalizing, run `just fix -p <crate>`. Do not use `--all-features` for routine runs.

**Feature flags**: Lifecycle is `Stage::UnderDevelopment` -> `Stage::Experimental` -> `Stage::Stable` -> `Stage::Removed`. Each feature is a `FeatureSpec` in the `FEATURES` array (`features.rs:523`) with an `id`, `key`, `stage`, and `default_enabled`. Features resolve through layered config: defaults -> base legacy toggles -> `[features]` table -> profile toggles -> profile `[features]` -> CLI overrides -> `normalize_dependencies()`. When a feature reaches Stable and is on for all users, remove the flag and rename conditional functions (`init_if_enabled` -> `init`).
