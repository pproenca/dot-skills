# Sections

This file defines the categories and their order. The prefix in parentheses is
the filename prefix that groups rules. Order categories by **importance** — the
decisions that come up most and cost most when wrong go first.

This skill covers the case where a macro/DSL is *already* justified (see the gate
in SKILL.md). It is a correctness/idiom skill, not a performance skill, so no
impact tiers.

---

## 1. Macro Design (macro)

**Description:** The shape of a single macro before any DSL exists. Corrects the reflex to put logic *inside* the `quote` block — which bloats every call site, breaks stacktraces and `IEx` navigation, and can't be unit-tested — instead of a thin macro that expands to one call into an ordinary function. Also covers the case a macro can't handle at all: a construct that must run inside a guard.

## 2. Quote & Hygiene (quote)

**Description:** The compile-time semantics of `quote`/`unquote` that a model gets subtly wrong: injecting an expression's AST with `unquote` re-evaluates it at every occurrence, splicing a runtime-built term needs `Macro.escape/1`, and quoted variables are hygienic — reaching for `var!` to "share" a variable leaks state into the caller. These are silent correctness bugs, not compile errors.

## 3. DSL Construction (dsl)

**Description:** Assembling a declarative block DSL (schema/spec/route/test style) from many small declarations. Corrects inventing a runtime registry or generating functions ad hoc, when the idiomatic mechanism is an accumulating module attribute drained by `@before_compile` — the pattern behind `Ecto.Schema`, `ExUnit`, and `Plug.Router`. Covers a minimal `__using__`, generating one clause per declaration with unquote fragments, and exposing an introspection function.

## 4. Compile-Time Validation (valid)

**Description:** What separates a production DSL (Ecto, Absinthe) from a toy one: it rejects bad input while compiling, with an error that points at the user's source. Corrects validating the DSL at runtime — where a typo surfaces on first request instead of at `mix compile` — and raising errors whose stacktrace points at library internals instead of the offending DSL line.
