---
name: adversarial-elixir
description: Use this skill when reviewing or refactoring existing Elixir/OTP/Ecto/Phoenix code that carries an alien mental model — OO/enterprise ceremony, imperative for-loops, or defensive nil-checking ported onto the BEAM. It is the adversarial, architecture-level counterpart to greenfield idiom advice — it names the paradigm the code betrays and prescribes the deep, wide refactor that collapses it, up to deleting whole layers (repository/DAO wrappers over Ecto, service-object tiers, GenServer-per-entity "objects", DI behaviours for a single implementation, anemic maps and boolean-flag state, macro DSLs). Applies whenever the work is "make this Elixir actually Elixir", "flatten this architecture", "why is this non-idiomatic", or a pedantic review of code that fights the runtime.
---

# Adversarial Elixir

An adversarial, architecture-level review-and-refactor pass for Elixir on the BEAM. Where a greenfield idiom skill answers "which tool should I reach for now?", this skill takes **code that already exists and imported the wrong mental model** — objects, service layers, defensive control flow, imperative loops — names the paradigm it betrays, and prescribes the refactor that collapses it back to idiomatic Elixir. The refactors are deep and wide by design: they cross module boundaries and often **delete an entire layer** (a repository over Ecto, a service tier, a per-entity process).

Each rule names one alien pattern and the Elixir it flattens to. There is no rule for things a capable model already gets right (syntax, standard idioms, the stdlib).

## When to Apply

- Reviewing or refactoring existing Elixir for architecture, not just style — "make this actually idiomatic", "why does this feel like Java/Ruby in Elixir"
- Flattening ported layers — repository/DAO wrappers, service/manager objects, DI behaviours for a single implementation, DTO/mapper tiers
- Untangling process misuse — a GenServer per entity, an Agent used as a variable, a global singleton "Manager", scattered `GenServer.call`
- Fixing anemic data — free-form maps as domain objects, boolean-flag or stringly-typed state, god-structs, hand-rolled type dispatch
- Removing defensive scaffolding — `try/rescue` as control flow, nil-guard pyramids, non-assertive access that leaks `nil`
- Replacing imperative iteration and needless metaprogramming — `reduce`/recursion reimplementing `Enum`, macro DSLs, `use`-instead-of-`import`, compile-time coupling

For greenfield "which tool, which convention" judgment calls while writing new code, use `staff-level-elixir` instead — this skill is its diagnostic, layer-deleting counterpart.

## Rule Categories

| # | Category | Prefix | The alien model it rips out |
|---|----------|--------|------------------------------|
| 1 | Enterprise Ceremony & Layering | `arch-` | Repository/DAO, service objects, DI behaviours → contexts + Ecto + pure functions |
| 2 | Processes as Objects | `proc-` | GenServer-per-entity, process-as-variable, singleton manager → DB/ETS + functions |
| 3 | Anemic Data Modeling | `type-` | Bare maps, boolean/stringly-typed state, god-structs → structs, tagged unions, protocols |
| 4 | Defensive Control Flow | `flow-` | rescue-as-control, nil-guards, non-assertive access → assertive matching + tagged tuples |
| 5 | Imperative Iteration | `iter-` | reduce/recursion reimplementing Enum → declarative pipelines |
| 6 | Needless Metaprogramming & Coupling | `meta-` | Macro DSLs, use-not-import, compile-time deps → functions, protocols, runtime config |

## Quick Reference

### 1. Enterprise Ceremony & Layering
- [`arch-delete-repository-over-ecto`](references/arch-delete-repository-over-ecto.md) — Ecto.Repo already is the repository; delete the wrapper
- [`arch-context-over-service-objects`](references/arch-context-over-service-objects.md) — collapse `*Service`/`*Manager` object modules into contexts
- [`arch-drop-di-behaviour-single-impl`](references/arch-drop-di-behaviour-single-impl.md) — no DI seam for one implementation; behaviours only at real boundaries
- [`arch-functional-core-imperative-shell`](references/arch-functional-core-imperative-shell.md) — pull decisions out of callbacks/controllers into a pure core

### 2. Processes as Objects
- [`proc-not-objects`](references/proc-not-objects.md) — don't model each entity as a process; state in the DB, behavior in functions
- [`proc-no-process-as-variable`](references/proc-no-process-as-variable.md) — an Agent holding a value is a slow, racy mutable variable; use ETS/DB
- [`proc-consolidate-interface`](references/proc-consolidate-interface.md) — wrap the process behind named client functions, not scattered `GenServer.call`
- [`proc-no-singleton-manager`](references/proc-no-singleton-manager.md) — one global manager is a bottleneck + SPOF; partition by key or drop it

### 3. Anemic Data Modeling
- [`type-struct-over-bare-map`](references/type-struct-over-bare-map.md) — structs with `@enforce_keys`, not free-form maps as domain objects
- [`type-tagged-state-over-flags`](references/type-tagged-state-over-flags.md) — one atom/tagged tuple, not several booleans or a status string
- [`type-protocol-over-type-dispatch`](references/type-protocol-over-type-dispatch.md) — a protocol, not a hand-rolled `case`/`is_*` type switch
- [`type-split-god-struct`](references/type-split-god-struct.md) — decompose a 30+-field struct into composed structs by cohesion

### 4. Defensive Control Flow
- [`flow-assertive-over-defensive`](references/flow-assertive-over-defensive.md) — assert the shape and let bad input crash; don't nil-guard everything
- [`flow-no-exceptions-for-control`](references/flow-no-exceptions-for-control.md) — tagged tuples for expected outcomes, not raise/rescue as an `if`
- [`flow-normalize-at-boundary`](references/flow-normalize-at-boundary.md) — validate once at the edge, then trust the data in the core

### 5. Imperative Iteration
- [`iter-named-combinator-over-manual-loop`](references/iter-named-combinator-over-manual-loop.md) — replace a transliterated `reduce`/recursion loop with the named `Enum`/`Stream` combinator

### 6. Needless Metaprogramming & Coupling
- [`meta-functions-not-macro-dsl`](references/meta-functions-not-macro-dsl.md) — express config as data + a function, not a macro DSL
- [`meta-use-is-not-import`](references/meta-use-is-not-import.md) — `import`/`alias` for functions; reserve `use` for real code injection
- [`meta-no-compile-time-coupling`](references/meta-no-compile-time-coupling.md) — read another module at runtime, not into a compile-time attribute

## How to Use

Read a reference file when its smell shows up in the code under review. Each rule names the alien pattern, explains *why the paradigm rejects it*, and shows the refactor (with an Incorrect/Correct contrast where the wrong way is a real, common trap). Prefer the deepest refactor the change budget allows — flattening a layer beats patching a symptom inside it.

- [Section definitions](references/_sections.md) — category structure and ordering
- [Rule template](assets/templates/_template.md) — for adding new rules
- [AGENTS.md](AGENTS.md) — auto-built table of contents across all rules

## Related Skills

- `staff-level-elixir` — the greenfield counterpart: which process/convention/idiom to reach for while *writing* new code. Use it for authoring decisions; use this skill for adversarial review and layer-flattening refactors.

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and source references |
