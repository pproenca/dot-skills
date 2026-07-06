---
name: elixir-meta-programming
description: Use this skill when building an Elixir macro or a declarative DSL — a schema/spec/route/workflow language in the shape of Ecto.Schema, Absinthe, Plug.Router, or ExUnit — with quote/unquote, __using__, module attributes, and @before_compile. It corrects the wrong defaults a model makes once it commits to metaprogramming — putting logic inside the quote block, re-evaluating unquoted expressions, forgetting Macro.escape, fighting hygiene with var!, generating code ad hoc instead of accumulating declarations, and validating the DSL at runtime rather than at compile time. Applies to writing or reviewing macro/DSL code. NOT for deciding whether to use a macro at all — that gate belongs to staff-level-elixir and adversarial-elixir, which say prefer plain functions.
---

# Elixir Metaprogramming & DSLs

How to build Elixir macros and declarative DSLs *correctly* — for the case where a macro is genuinely warranted and a plain function won't do. Each rule corrects a specific wrong default a capable model makes once it starts writing `quote`/`unquote`, `__using__`, and `@before_compile`; nothing here restates macro basics the model already knows.

## First: is a macro actually warranted?

The default answer is **no** — reach for a higher-order function, a behaviour, or data-plus-an-interpreter first. That gate is not this skill's job; it lives in the sibling skills and you should apply it before opening this one:

- `staff-level-elixir` → `data-functions-over-macros` (solve it with a function first)
- `adversarial-elixir` → `meta-functions-not-macro-dsl`, `meta-use-is-not-import`, `meta-no-compile-time-coupling`

A macro earns its place only when you need something a function cannot give — new syntax, control over whether/when arguments evaluate, or code that must exist at compile time (compiling a schema, generating clauses from a declaration list). **Once you've crossed that threshold, this skill is how you do it right.**

## When to Apply

- Writing a macro — deciding what goes in the `quote` block versus a runtime function, and how arguments evaluate
- Building a declarative DSL — a `schema`/`spec`/`route`/`workflow` block that collects declarations and generates a module
- Wiring `use MyDSL` — what `__using__` should inject and what belongs in `@before_compile`
- Generating functions or clauses from a list of declarations at compile time
- Making a DSL fail at `mix compile` with an error that points at the user's source
- Reviewing existing macro/DSL code for evaluation, hygiene, escaping, and compile-time-validation bugs

## Rule Categories

| # | Category | Prefix | Covers |
|---|----------|--------|--------|
| 1 | Macro Design | `macro` | The shape of a single macro — thin macro over a runtime function; `defguard` for guard-safe constructs |
| 2 | Quote & Hygiene | `quote` | Compile-time semantics traps — multiple evaluation, `Macro.escape`, hygiene vs `var!` |
| 3 | DSL Construction | `dsl` | Assembling a block DSL — accumulating attributes + `@before_compile`, minimal `__using__`, unquote fragments, introspection |
| 4 | Compile-Time Validation | `valid` | Failing well — validate while compiling, locate errors at the caller's line |

## Quick Reference

### 1. Macro Design

- [`macro-thin-delegate-runtime`](references/macro-thin-delegate-runtime.md) — quote to a single call into a plain function; keep logic testable and out of every call site
- [`macro-defguard-for-guards`](references/macro-defguard-for-guards.md) — `defguard` when the construct must work inside a guard

### 2. Quote & Hygiene

- [`quote-bind-quoted-single-eval`](references/quote-bind-quoted-single-eval.md) — `bind_quoted` so a repeated `unquote` argument evaluates once
- [`quote-escape-runtime-data`](references/quote-escape-runtime-data.md) — `Macro.escape/1` before splicing a computed term into `quote`
- [`quote-rely-on-hygiene`](references/quote-rely-on-hygiene.md) — rely on hygiene; use `var!` only when injecting a name is the documented contract

### 3. DSL Construction

- [`dsl-accumulate-attributes`](references/dsl-accumulate-attributes.md) — record declarations in an `accumulate: true` attribute, generate in `@before_compile`
- [`dsl-using-minimal`](references/dsl-using-minimal.md) — `__using__` does setup only; generation belongs in `@before_compile`
- [`dsl-unquote-fragments`](references/dsl-unquote-fragments.md) — `def unquote(name)(...)` in a comprehension to emit one clause per declaration
- [`dsl-introspection-function`](references/dsl-introspection-function.md) — generate a `__schema__`-style reflection function so callers read data

### 4. Compile-Time Validation

- [`valid-fail-at-compile-time`](references/valid-fail-at-compile-time.md) — validate in the macro body, not the returned `quote`, so errors fire at `mix compile`
- [`valid-locate-errors-at-caller`](references/valid-locate-errors-at-caller.md) — raise from the declaration macro / capture `__CALLER__` so errors cite the user's line

## How to Use

Read a reference file when its decision comes up. Each rule names the wrong default it corrects, then shows the canonical way (with an Incorrect/Correct contrast only where the wrong way is a real trap).

- [Section definitions](references/_sections.md) — category structure and ordering
- [Rule template](assets/templates/_template.md) — for adding new rules
- [AGENTS.md](AGENTS.md) — auto-built table of contents across all rules

## Related Skills

- `staff-level-elixir` — the broader Elixir/OTP/Ecto/Phoenix judgment skill; owns the "prefer a function over a macro" gate
- `adversarial-elixir` — architecture-level review that flattens unnecessary macro DSLs; the diagnostic counterpart to this skill

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for new rules |
| [metadata.json](metadata.json) | Version and source references |
