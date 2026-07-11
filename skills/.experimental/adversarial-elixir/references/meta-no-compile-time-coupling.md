---
title: Read another module's data at runtime, not into a compile-time attribute
tags: meta, compile-time, recompilation, coupling
---

## Read another module's data at runtime, not into a compile-time attribute

Capturing another module's return value into a module attribute — `@statuses MyApp.Config.all_statuses()` — evaluates that call at compile time and creates a compile-time dependency: now every time `MyApp.Config` changes, this module (and everything transitively depending on it) must recompile. On a large project these edges turn a one-line change into a multi-minute rebuild. Keep the reference inside a function body so it runs at runtime and the dependency stays a normal runtime one; `mix xref graph --label compile` reveals the edges you want to cut.

**Evidence of violation:** a module attribute assigned from another application module's function call — `@statuses MyApp.Config.all_statuses()` — creating a compile-time edge between two of the target's own modules; cite the attribute line. PASS: cross-module reads happen inside function bodies at runtime. N/A: no module attributes calling other modules. Carve-outs (not violations): attributes built from literals or the module's own private functions, stdlib/macro-time calls with stable results (`Path.join`, `String.to_atom` on literals), and `Application.compile_env/2,3` where compile-time resolution is the documented intent — cite which carve-out applies.

**Incorrect (compile-time edge — module attribute calls another module):**

```elixir
defmodule MyApp.Orders do
  @statuses MyApp.Config.all_statuses()   # evaluated at compile time
  def valid_status?(s), do: s in @statuses
end
```

**Correct (runtime call — no compile-time coupling):**

```elixir
defmodule MyApp.Orders do
  def valid_status?(s), do: s in MyApp.Config.all_statuses()
end
```

Reference: [Elixir — Meta-programming anti-patterns: "Compile-time dependencies"](https://hexdocs.pm/elixir/macro-anti-patterns.html)
