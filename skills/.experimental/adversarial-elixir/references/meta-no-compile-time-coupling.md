---
title: Read another module's data at runtime, not into a compile-time attribute
tags: meta, compile-time, recompilation, coupling
---

## Read another module's data at runtime, not into a compile-time attribute

Capturing another module's return value into a module attribute — `@statuses MyApp.Config.all_statuses()` — evaluates that call at compile time and creates a compile-time dependency: now every time `MyApp.Config` changes, this module (and everything transitively depending on it) must recompile. On a large project these edges turn a one-line change into a multi-minute rebuild. Keep the reference inside a function body so it runs at runtime and the dependency stays a normal runtime one; `mix xref graph --label compile` reveals the edges you want to cut.

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
