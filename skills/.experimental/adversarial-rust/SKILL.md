---
name: adversarial-rust
description: Use this skill when reviewing or refactoring existing Rust code that carries an alien mental model — OO/enterprise ceremony from Java/C#, garbage-collected object graphs, exception-style control flow, or imperative loops ported onto the borrow checker. It is the adversarial, architecture-level counterpart to greenfield idiom advice — it names the paradigm the code betrays and prescribes the deep refactor that collapses it, up to deleting whole layers (single-impl DI traits, Deref inheritance, Manager/Service structs, reflexive builders, Rc<RefCell> webs, clone-until-it-compiles, bool/String state machines, sentinel returns, catch_unwind try/catch, reflexive Box<dyn>, blocking calls inside async, fire-and-forget spawns). Every rule is grounded in the codex-rs production workspace (openai/codex) — the prescriptions are what that codebase actually does and lint-enforces. Applies whenever the work is "make this Rust actually Rust", "flatten this architecture", or a pedantic review of code fighting the language.
---

# Adversarial Rust

An adversarial, architecture-level review-and-refactor pass for Rust. Where a greenfield idiom skill answers "which tool should I reach for now?", this skill takes **code that already exists and imported the wrong mental model** — objects and interfaces from Java/C#, shared-everything graphs from garbage-collected languages, exceptions, C-style loops and sentinels, detached-promise concurrency — names the paradigm it betrays, and prescribes the refactor that collapses it back to idiomatic Rust.

Every rule is grounded in a single production codebase: the **codex-rs workspace** (github.com/openai/codex, `codex-rs/` at commit `f1affbac5e`, ~125 crates / ~2,500 Rust files). The Correct side of each rule is what that codebase actually does, the enforcement evidence is its workspace lint config (`unwrap_used`, `redundant_clone`, `needless_collect`, `await_holding_lock` and ~30 more denied), and the carve-outs are the real exceptions it keeps — so "when NOT to apply" is never hypothetical. There is no rule for things a capable model already gets right.

## When to Apply

- Reviewing or refactoring existing Rust for architecture, not just style — "make this actually idiomatic", "why does this feel like Java in Rust"
- Flattening ported ceremony — dependency-injection traits with one implementation, `Deref`-simulated inheritance, stateless `*Manager`/`*Service` structs, getter/setter boilerplate, a builder for every struct
- Untangling fought ownership — `.clone()` sprinkled until it compiles, `Rc<RefCell<T>>` object graphs, self-referential struct attempts
- Fixing anemic data — boolean/string state machines, parallel `Option` fields, raw primitives carrying domain meaning, god-structs of `Option`s escaping the serde boundary
- Removing exception-style flow — `unwrap` on expected failures, sentinel returns, `catch_unwind` as try/catch, `anyhow` on library API surfaces
- Collapsing habitual indirection — `Box<dyn Trait>` for closed sets, boxed callback parameters, index loops and per-step `collect()` chains
- Repairing imported concurrency habits — blocking calls inside `async fn`, guards held across `.await`, async task fan-out for CPU-bound work, fire-and-forget `tokio::spawn`

For greenfield "which pattern, which crate, which discipline" decisions while writing new Rust — async cancellation, error enum design, sandboxing, testing architecture — use `openai-codex-rust-patterns` instead; this skill is its diagnostic, layer-flattening counterpart drawn from the same codebase.

## Rule Categories

| # | Category | Prefix | The alien model it rips out |
|---|----------|--------|------------------------------|
| 1 | Enterprise Ceremony & Fake OO | `arch-` | DI traits, Deref inheritance, Manager structs, getter ceremony, reflexive builders → concrete types, delegation, module functions, public fields, struct literals |
| 2 | Ownership Fought, Not Used | `own-` | clone-to-compile, Rc<RefCell> graphs, self-referential structs → designed clones, owning ID-keyed maps, single owners |
| 3 | Anemic & Stringly Data | `type-` | bool/String states, parallel Options, raw primitives, escaped god-structs → data-carrying enums, newtypes, one wire-to-domain resolve |
| 4 | Exception-Style Control Flow | `flow-` | unwrap-as-handling, sentinels, catch_unwind, opaque library errors → Result + ?, Option, thiserror enums, anyhow at the rim |
| 5 | Dynamic Dispatch by Habit | `dyn-` | Box<dyn> for closed sets, boxed callback params → tagged enums, generic Fn at the API, channels over listeners |
| 6 | Imperative Iteration | `iter-` | index loops, mut accumulators, collect-per-step → named combinators, one lazy chain, collect into Result |
| 7 | Concurrency From Another Runtime | `conc-` | blocking in async, guards across await, async CPU fan-out, orphan spawns → spawn_blocking, narrowed locks, bounded thread pools, owned handles |

## Quick Reference

### 1. Enterprise Ceremony & Fake OO
- [`arch-drop-di-trait-single-impl`](references/arch-drop-di-trait-single-impl.md) — delete the DI trait with one implementation; codex-rs ships `ModelClient` and `Session` concrete
- [`arch-no-deref-inheritance`](references/arch-no-deref-inheritance.md) — all 18 codex-rs `Deref` impls are newtypes or smart pointers; zero simulate a hierarchy
- [`arch-free-functions-over-manager-struct`](references/arch-free-functions-over-manager-struct.md) — stateless capability = module functions (`git-utils`, `apply-patch`); a `*Manager` earns its name by owning state
- [`arch-public-fields-over-getter-ceremony`](references/arch-public-fields-over-getter-ceremony.md) — `Config` and every protocol type are all-`pub`; accessors exist only where an invariant lives
- [`arch-default-literal-over-builder`](references/arch-default-literal-over-builder.md) — 1,787 struct literals with `..Default::default()` vs 16 builders; a builder needs staged construction to earn itself

### 2. Ownership Fought, Not Used
- [`own-restructure-over-clone`](references/own-restructure-over-clone.md) — surviving clones are designed (Copy IDs, Arc bumps, lock snapshots); a compile-fixing clone forks data
- [`own-no-rc-refcell-object-graph`](references/own-no-rc-refcell-object-graph.md) — zero `Rc<RefCell>` in ~2,500 files; narrow Mutex fields, channels, or ID maps instead
- [`own-id-map-over-self-referential`](references/own-id-map-over-self-referential.md) — graphs live in `HashMap<ThreadId, Arc<CodexThread>>`; cross-references are IDs, never references

### 3. Anemic & Stringly Data
- [`type-enum-over-bool-string-state`](references/type-enum-over-bool-string-state.md) — variants own their fields (`SandboxPolicy`); its external-sandbox variant types even yes/no as `NetworkAccess`, not `bool`
- [`type-result-over-parallel-options`](references/type-result-over-parallel-options.md) — one `Option` per shape is `CodexAuth` in denial; found/missing/failed is `Result<Option<T>, E>`
- [`type-newtype-parse-dont-validate`](references/type-newtype-parse-dont-validate.md) — parse once into `ThreadId`/`AgentPath`; model names stay `String` because no invariant exists
- [`type-split-option-god-struct`](references/type-split-option-god-struct.md) — `ConfigToml` (91 of 97 fields are Options) is fine *on the wire*; resolve it once into rich `Config`

### 4. Exception-Style Control Flow
- [`flow-result-over-unwrap-expected`](references/flow-result-over-unwrap-expected.md) — `unwrap_used`/`expect_used` denied workspace-wide; escapes carry `#[expect]` + a written invariant
- [`flow-option-over-sentinel-values`](references/flow-option-over-sentinel-values.md) — lookups return `Option`; `-1` exists only at the OS exit-code boundary
- [`flow-no-catch-unwind-try-catch`](references/flow-no-catch-unwind-try-catch.md) — every codex-rs production use supervises a foreign fault domain; none catch expected failures
- [`flow-thiserror-library-anyhow-application`](references/flow-thiserror-library-anyhow-application.md) — `CodexErr`/`ApiError`/`TransportError` per layer; `anyhow` at `main()`

### 5. Dynamic Dispatch by Habit
- [`dyn-enum-over-box-dyn-closed-set`](references/dyn-enum-over-box-dyn-closed-set.md) — `Op`/`EventMsg`/`TurnItem` are enums; `dyn` is the tool registry others extend at runtime
- [`dyn-generics-over-boxed-callbacks`](references/dyn-generics-over-boxed-callbacks.md) — generic `F: Fn` at the API, box only for storage, channels instead of listener registration

### 6. Imperative Iteration
- [`iter-combinator-over-index-loop`](references/iter-combinator-over-index-loop.md) — 13 `manual_*` lints denied; `for` survives for awaits, side effects, index-as-data, FFI
- [`iter-stay-lazy-single-collect`](references/iter-stay-lazy-single-collect.md) — one lazy chain; `collect::<Result<Vec<_>, _>>()` is the fallible-pipeline idiom (49 production uses)

### 7. Concurrency From Another Runtime
- [`conc-spawn-blocking-over-blocking-async`](references/conc-spawn-blocking-over-blocking-async.md) — ~50 `spawn_blocking` sites: git, file locks, zstd, OAuth servers
- [`conc-narrow-locks-before-await`](references/conc-narrow-locks-before-await.md) — even tokio guards may not cross `.await`; snapshot out or `#[expect]` with an atomicity reason
- [`conc-blocking-pool-over-async-cpu-fanout`](references/conc-blocking-pool-over-async-cpu-fanout.md) — no rayon; CPU fan-out on bounded OS threads behind one `spawn_blocking`
- [`conc-own-spawned-task-handles`](references/conc-own-spawned-task-handles.md) — `AbortOnDropHandle` + child `CancellationToken`; interrupt is cancel → grace window → abort

## How to Use

Read a reference file when its smell shows up in the code under review. Each rule names the alien pattern, explains *why Rust rejects it*, and shows the refactor with real codex-rs names and a permalink into the codebase at the pinned commit. Prefer the deepest refactor the change budget allows — redesigning ownership beats sprinkling `clone`; deleting the DI trait beats mocking through it. Every example compiles on Rust 1.86 (2021 edition).

- [Section definitions](references/_sections.md) — category structure and ordering
- [Rule template](assets/templates/_template.md) — for adding new rules
- [AGENTS.md](AGENTS.md) — auto-built table of contents across all rules

## Related Skills

- `openai-codex-rust-patterns` — the greenfield counterpart distilled from the same codex-rs workspace: which pattern to reach for while *writing* production Rust (async cancellation, error enum design, sandboxing, testing, workspace layout). Use it for authoring decisions; use this skill for adversarial review and ceremony-flattening refactors. Several rules here hand off to it once the flatten is done (`flow-thiserror-library-anyhow-application` → its `errors-` rules, `flow-result-over-unwrap-expected` → `defensive-deny-unwrap-workspace-wide`, `arch-drop-di-trait-single-impl` → its testing seams).

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and source references |
