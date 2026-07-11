# Rust

**Version 1.0.0**  
dot-skills  
July 2026

---

## Abstract

Adversarial, architecture-level review and refactoring of Rust code that imported an alien mental model (OO/enterprise ceremony, GC object graphs, exception-style control flow, imperative iteration, borrowed concurrency habits) — names the paradigm the code betrays and prescribes the deep, ceremony-flattening refactor back to idiomatic Rust. Every rule is grounded exclusively in the codex-rs production workspace (openai/codex at commit f1affbac5e, ~125 crates): the prescriptions are what that codebase does, the enforcement evidence is its workspace lint config, and the carve-outs are the real exceptions it keeps. The diagnostic counterpart to the greenfield openai-codex-rust-patterns skill. All examples compile-tested on Rust 1.86.

---

## Table of Contents

1. [Enterprise Ceremony & Fake OO](references/_sections.md#1-enterprise-ceremony-&-fake-oo)
   - 1.1 [Collapse stateless Manager structs into module functions](references/arch-free-functions-over-manager-struct.md)
   - 1.2 [Delete the dependency-injection trait with one implementation](references/arch-drop-di-trait-single-impl.md)
   - 1.3 [Deref is for newtypes and smart pointers, never inheritance](references/arch-no-deref-inheritance.md)
   - 1.4 [Plain data gets pub fields; accessors are for invariants](references/arch-public-fields-over-getter-ceremony.md)
   - 1.5 [Struct literal with Default over a builder for every struct](references/arch-default-literal-over-builder.md)
2. [Ownership Fought, Not Used](references/_sections.md#2-ownership-fought,-not-used)
   - 2.1 [Graphs live in one owning map with ID handles, not references](references/own-id-map-over-self-referential.md)
   - 2.2 [No Rc RefCell object graphs — pick owners, share by Arc field or channel](references/own-no-rc-refcell-object-graph.md)
   - 2.3 [Redesign ownership instead of cloning to compile; keep only designed clones](references/own-restructure-over-clone.md)
3. [Anemic & Stringly Data](references/_sections.md#3-anemic-&-stringly-data)
   - 3.1 [Confine the Option god-struct to the wire; resolve it once into a rich type](references/type-split-option-god-struct.md)
   - 3.2 [One enum whose variants own their data, not bool and String flags](references/type-enum-over-bool-string-state.md)
   - 3.3 [Parallel Option fields are a sum type in denial](references/type-result-over-parallel-options.md)
   - 3.4 [Parse once into a newtype; signatures carry the proof](references/type-newtype-parse-dont-validate.md)
4. [Exception-Style Control Flow](references/_sections.md#4-exception-style-control-flow)
   - 4.1 [Absence needs a type, not a sentinel value](references/flow-option-over-sentinel-values.md)
   - 4.2 [Expected failures travel as Result; unwrap only with a written proof](references/flow-result-over-unwrap-expected.md)
   - 4.3 [Libraries export matchable error enums; anyhow stays at the binary rim](references/flow-thiserror-library-anyhow-application.md)
   - 4.4 [Reserve catch_unwind for isolation boundaries, never try/catch](references/flow-no-catch-unwind-try-catch.md)
5. [Dynamic Dispatch by Habit](references/_sections.md#5-dynamic-dispatch-by-habit)
   - 5.1 [Generic Fn parameters at the API; box only for storage; channels over listeners](references/dyn-generics-over-boxed-callbacks.md)
   - 5.2 [Use an enum for a closed set; reserve dyn for sets others extend](references/dyn-enum-over-box-dyn-closed-set.md)
6. [Imperative Iteration](references/_sections.md#6-imperative-iteration)
   - 6.1 [Name the transformation with a combinator, not an index loop](references/iter-combinator-over-index-loop.md)
   - 6.2 [Stay lazy through the chain; collect once, and into Result for fallible steps](references/iter-stay-lazy-single-collect.md)
7. [Concurrency From Another Runtime](references/_sections.md#7-concurrency-from-another-runtime)
   - 7.1 [Blocking work moves to spawn_blocking; an async fn never blocks its worker](references/conc-spawn-blocking-over-blocking-async.md)
   - 7.2 [Extract or scope the guard before the await — even the tokio guard](references/conc-narrow-locks-before-await.md)
   - 7.3 [Own every spawned task's handle; cancel is graceful-then-abort](references/conc-own-spawned-task-handles.md)
   - 7.4 [Run CPU-bound fan-out on a bounded thread pool behind one spawn_blocking](references/conc-blocking-pool-over-async-cpu-fanout.md)

---

## References

1. [https://github.com/openai/codex/blob/f1affbac5e/codex-rs/Cargo.toml](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/Cargo.toml)
2. [https://github.com/openai/codex/blob/f1affbac5e/codex-rs/clippy.toml](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/clippy.toml)
3. [https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/session/session.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/session/session.rs)
4. [https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/thread_manager.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/thread_manager.rs)
5. [https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/client.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/client.rs)
6. [https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/config/mod.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/config/mod.rs)
7. [https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/tools/registry.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/tools/registry.rs)
8. [https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/tasks/mod.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/tasks/mod.rs)
9. [https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/safety.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/safety.rs)
10. [https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/exec.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/core/src/exec.rs)
11. [https://github.com/openai/codex/blob/f1affbac5e/codex-rs/protocol/src/protocol.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/protocol/src/protocol.rs)
12. [https://github.com/openai/codex/blob/f1affbac5e/codex-rs/protocol/src/error.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/protocol/src/error.rs)
13. [https://github.com/openai/codex/blob/f1affbac5e/codex-rs/protocol/src/thread_id.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/protocol/src/thread_id.rs)
14. [https://github.com/openai/codex/blob/f1affbac5e/codex-rs/protocol/src/agent_path.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/protocol/src/agent_path.rs)
15. [https://github.com/openai/codex/blob/f1affbac5e/codex-rs/login/src/auth/manager.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/login/src/auth/manager.rs)
16. [https://github.com/openai/codex/blob/f1affbac5e/codex-rs/keyring-store/src/lib.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/keyring-store/src/lib.rs)
17. [https://github.com/openai/codex/blob/f1affbac5e/codex-rs/git-utils/src/info.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/git-utils/src/info.rs)
18. [https://github.com/openai/codex/blob/f1affbac5e/codex-rs/message-history/src/lib.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/message-history/src/lib.rs)
19. [https://github.com/openai/codex/blob/f1affbac5e/codex-rs/app-server/src/thread_state.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/app-server/src/thread_state.rs)
20. [https://github.com/openai/codex/blob/f1affbac5e/codex-rs/config/src/config_toml.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/config/src/config_toml.rs)
21. [https://github.com/openai/codex/blob/f1affbac5e/codex-rs/utils/absolute-path/src/lib.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/utils/absolute-path/src/lib.rs)
22. [https://github.com/openai/codex/blob/f1affbac5e/codex-rs/exec-server/src/rpc.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/exec-server/src/rpc.rs)
23. [https://github.com/openai/codex/blob/f1affbac5e/codex-rs/file-search/src/lib.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/file-search/src/lib.rs)
24. [https://github.com/openai/codex/blob/f1affbac5e/codex-rs/code-mode/src/runtime/mod.rs](https://github.com/openai/codex/blob/f1affbac5e/codex-rs/code-mode/src/runtime/mod.rs)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |