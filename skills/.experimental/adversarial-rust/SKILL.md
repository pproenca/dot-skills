---
name: adversarial-rust
description: Use this skill when reviewing or refactoring existing Rust code that carries an alien mental model — OO/enterprise ceremony from Java/C#, garbage-collected object graphs, exception-style control flow, or imperative loops ported onto the borrow checker. It is the adversarial, architecture-level counterpart to greenfield idiom advice — it names the paradigm the code betrays and prescribes the deep refactor that collapses it, up to deleting whole layers (single-impl DI traits, Deref inheritance, Manager/Service structs, Rc<RefCell> webs, clone-until-it-compiles, bool/String state machines, sentinel returns, catch_unwind try/catch, reflexive Box<dyn>, blocking calls inside async). Applies whenever the work is "make this Rust actually Rust", "flatten this architecture", "why does this fight the borrow checker", or a pedantic review of code that fights the language.
---

# Adversarial Rust

An adversarial, architecture-level review-and-refactor pass for Rust. Where a greenfield idiom skill answers "which tool should I reach for now?", this skill takes **code that already exists and imported the wrong mental model** — objects and interfaces from Java/C#, shared-everything graphs from garbage-collected languages, exceptions, C-style loops and sentinels — names the paradigm it betrays, and prescribes the refactor that collapses it back to idiomatic Rust. The refactors are deep and wide by design: they redesign ownership, delete injection layers, and replace runtime machinery (`Rc<RefCell>`, `Box<dyn>`, `catch_unwind`) with compile-time structure (owners, enums, `Result`).

Each rule names one alien pattern and the Rust it flattens to. There is no rule for things a capable model already gets right (syntax, standard idioms, the stdlib).

## When to Apply

- Reviewing or refactoring existing Rust for architecture, not just style — "make this actually idiomatic", "why does this feel like Java in Rust"
- Flattening ported ceremony — dependency-injection traits with one implementation, `Deref`-simulated inheritance, stateless `*Manager`/`*Service` structs, getter/setter boilerplate
- Untangling fought ownership — `.clone()` sprinkled until it compiles, `Rc<RefCell<T>>`/`Arc<Mutex<T>>` object graphs, self-referential struct attempts
- Fixing anemic data — boolean/string state machines, parallel `Option` fields, raw primitives carrying domain meaning, god-structs of `Option`s
- Removing exception-style flow — `unwrap` on expected failures, sentinel returns, `catch_unwind` as try/catch, `anyhow` leaking from library APIs
- Collapsing habitual indirection — `Box<dyn Trait>` for closed sets, boxed callbacks, index loops and per-step `collect()` chains
- Repairing imported concurrency habits — blocking calls inside `async fn`, `MutexGuard` held across `.await`, async task fan-out for CPU-bound work

For greenfield "which pattern, which crate, which discipline" decisions while writing new Rust — async cancellation, error enum design, sandboxing, testing architecture — use `openai-codex-rust-patterns` instead; this skill is its diagnostic, layer-flattening counterpart.

## Rule Categories

| # | Category | Prefix | The alien model it rips out |
|---|----------|--------|------------------------------|
| 1 | Enterprise Ceremony & Fake OO | `arch-` | DI traits, Deref inheritance, Manager structs, getter ceremony → concrete types, delegation, module functions, public fields |
| 2 | Ownership Fought, Not Used | `own-` | clone-to-compile, Rc<RefCell> graphs, self-referential structs → ownership redesign, ID links, arenas |
| 3 | Anemic & Stringly Data | `type-` | bool/String states, parallel Options, raw primitives, Option god-structs → enums, Result, newtypes, typestate |
| 4 | Exception-Style Control Flow | `flow-` | unwrap-as-handling, sentinels, catch_unwind, opaque library errors → Result + ?, Option, thiserror enums |
| 5 | Dynamic Dispatch by Habit | `dyn-` | Box<dyn> for closed sets, boxed callbacks → enums, impl Trait generics |
| 6 | Imperative Iteration | `iter-` | index loops, mut accumulators, collect-per-step → named combinators, one lazy chain |
| 7 | Concurrency From Another Runtime | `conc-` | blocking in async, guards across await, async CPU fan-out → spawn_blocking, narrowed locks, rayon |

## Quick Reference

### 1. Enterprise Ceremony & Fake OO
- [`arch-drop-di-trait-single-impl`](references/arch-drop-di-trait-single-impl.md) — delete the DI trait with one implementation; the concrete type is the seam
- [`arch-no-deref-inheritance`](references/arch-no-deref-inheritance.md) — `Deref` to a "base" type is fake inheritance; delegate or define the trait
- [`arch-free-functions-over-manager-struct`](references/arch-free-functions-over-manager-struct.md) — collapse stateless `*Manager`/`*Service` structs into module functions
- [`arch-public-fields-over-getter-ceremony`](references/arch-public-fields-over-getter-ceremony.md) — plain data gets `pub` fields; accessors are for invariants

### 2. Ownership Fought, Not Used
- [`own-restructure-over-clone`](references/own-restructure-over-clone.md) — a compile-fixing `.clone()` forks data and hides a design diagnostic
- [`own-no-rc-refcell-object-graph`](references/own-no-rc-refcell-object-graph.md) — `Rc<RefCell<T>>` webs panic at runtime and leak cycles; pick owners, link by ID
- [`own-arena-indices-over-self-referential`](references/own-arena-indices-over-self-referential.md) — graphs live in an arena with index handles, not references

### 3. Anemic & Stringly Data
- [`type-enum-over-bool-string-state`](references/type-enum-over-bool-string-state.md) — one enum, not bool/String flags whose combinations lie
- [`type-result-over-parallel-options`](references/type-result-over-parallel-options.md) — `data: Option<T>, error: Option<E>` is a sum type in denial
- [`type-newtype-parse-dont-validate`](references/type-newtype-parse-dont-validate.md) — parse once into a newtype; signatures carry the proof
- [`type-split-option-god-struct`](references/type-split-option-god-struct.md) — a struct of stage-dependent `Option`s is several types flattened into one

### 4. Exception-Style Control Flow
- [`flow-result-over-unwrap-expected`](references/flow-result-over-unwrap-expected.md) — expected failures travel as `Result`; unwrap only where `Err` proves a bug
- [`flow-option-over-sentinel-values`](references/flow-option-over-sentinel-values.md) — `-1`/empty-string sentinels are valid values; absence needs a type
- [`flow-no-catch-unwind-try-catch`](references/flow-no-catch-unwind-try-catch.md) — `catch_unwind` is an isolation boundary, not try/catch
- [`flow-thiserror-library-anyhow-application`](references/flow-thiserror-library-anyhow-application.md) — libraries export matchable enums; `anyhow` stays in `main`'s orbit

### 5. Dynamic Dispatch by Habit
- [`dyn-enum-over-box-dyn-closed-set`](references/dyn-enum-over-box-dyn-closed-set.md) — a closed set of variants is an enum, not a trait-object zoo
- [`dyn-generics-over-boxed-callbacks`](references/dyn-generics-over-boxed-callbacks.md) — `impl Trait` parameters, not reflexive `Box<dyn Fn>`

### 6. Imperative Iteration
- [`iter-combinator-over-index-loop`](references/iter-combinator-over-index-loop.md) — index loops and mut accumulators re-derive named combinators
- [`iter-stay-lazy-single-collect`](references/iter-stay-lazy-single-collect.md) — adapters fuse; collect once at the end, not per step

### 7. Concurrency From Another Runtime
- [`conc-spawn-blocking-over-blocking-async`](references/conc-spawn-blocking-over-blocking-async.md) — a blocking call in async stalls every task on that worker
- [`conc-narrow-locks-before-await`](references/conc-narrow-locks-before-await.md) — drop the `MutexGuard` before `.await`; don't reach for the async mutex first
- [`conc-rayon-over-async-cpu-parallelism`](references/conc-rayon-over-async-cpu-parallelism.md) — async buys concurrent waiting; CPU-bound fan-out belongs on rayon

## How to Use

Read a reference file when its smell shows up in the code under review. Each rule names the alien pattern, explains *why Rust rejects it*, and shows the refactor (with an Incorrect/Correct contrast where the wrong way is a real, common trap). Prefer the deepest refactor the change budget allows — redesigning ownership beats sprinkling `clone`; deleting the DI trait beats mocking through it. Every example compiles on Rust 1.86 (2021 edition).

- [Section definitions](references/_sections.md) — category structure and ordering
- [Rule template](assets/templates/_template.md) — for adding new rules
- [AGENTS.md](AGENTS.md) — auto-built table of contents across all rules

## Related Skills

- `openai-codex-rust-patterns` — the greenfield counterpart: which pattern to reach for while *writing* production Rust (async cancellation, error enum design, sandboxing, testing, workspace layout), distilled from the codex-rs workspace. Use it for authoring decisions; use this skill for adversarial review and ceremony-flattening refactors. Several rules here hand off to it once the flatten is done (`flow-thiserror-library-anyhow-application` → its `errors-` rules, `flow-result-over-unwrap-expected` → `defensive-deny-unwrap-workspace-wide`, `arch-drop-di-trait-single-impl` → its testing seams).

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and source references |
