# Gotchas

Append failure points discovered while applying the rules in this skill. Each entry should be specific enough that a future reader can avoid it, not just "be careful with X".

Patterns in this skill were last refreshed against `openai/codex` `main` at commit `8a94430` on 2026-05-25. codex-rs refactors aggressively, so line references — and sometimes whole file paths — drift fast. Cross-check with the live repo before quoting an exact location.

## codex-rs moves fast: verify file *paths*, not just line numbers

In the ~6 weeks between the first extraction (2026-04-12) and the first refresh (2026-05-25) the repo grew from 1,418 to 2,008 Rust files (72 → 119 crates), and only 5 of 60 citations were still byte-for-byte correct. Two structural moves caused most of the churn:

- **`core/src/codex.rs` was deleted and split** into `core/src/session/mod.rs`, `core/src/session/turn.rs`, and `core/src/codex_delegate.rs`. Any rule that cited `core/src/codex.rs` now points at one of those. When re-validating, grep for the *symbol* (a struct/fn name from the Correct block), not the old path.
- **`FunctionCallError` was extracted into a new `codex-tools` crate** (`tools/src/function_call_error.rs`); `core/src/function_tool.rs` is now just a `pub use` re-export. Watch for similar "type lifted into its own crate" moves.

## The repo migrated to Bazel — the `justfile` is gone

Build/policy that used to live in the `justfile` now lives in `BUILD.bazel` + `docs/bazel.md`. Don't cite the `justfile`. Relatedly, the absolute claim "there is not a single `[features]` section in the workspace" is **no longer true**: `code-mode` and `v8-poc` each declare `[features] sandbox = ["v8/v8_enable_sandbox"]` to forward a native-dependency build flag. State conventions as "codex avoids X except where Y," not as absolutes — absolutes rot.

## A few docs were pruned

`docs/tui-chat-composer.md` and `docs/tui-stream-chunking-tuning.md` (and the older `-review.md`) were removed; `docs/` now holds only `bazel.md`, `codex_mcp_interface.md`, and `protocol_v1.md`. Prefer citing source `.rs` files over `docs/*.md`, which are deleted more readily.

## Don't trust "never uses X" claims without grepping

A mining pass proposed a rule that codex "never uses `#[async_trait]`, always spells out `impl Future + Send`." A `git grep` found **78** live `#[async_trait]` uses — both styles coexist. Before encoding an absolute behavioral claim, count occurrences in the live tree.
