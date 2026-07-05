---
title: Solve it with a function before reaching for a macro
tags: data, macros, metaprogramming
---

## Solve it with a function before reaching for a macro

The temptation — especially after seeing how much libraries pack into their DSLs — is to reach for `defmacro` to remove boilerplate. The staff-level default is the opposite: **write functions; use macros only when you genuinely need what only compile-time code generation can give** — new syntax, control over whether/when arguments evaluate, or code that must exist at compile time (compiling a schema, generating clauses from a data structure). Macros run at compile time and expand at every call site: they bloat compiled code, break `IEx` navigation and stacktraces, force `require`, and are far harder to test and read. Most "I need a macro" cases are solved by a higher-order function, a behaviour, or passing a function as data.

```elixir
# Boilerplate across handlers? A higher-order function removes it — no macro.
defmodule Api.Handler do
  def with_auth(conn, fun) do
    case authenticate(conn) do
      {:ok, user} -> fun.(user)
      :error -> send_resp(conn, 401, "unauthorized")
    end
  end
end

# Legitimately a macro: `assert left == right` must capture the *unevaluated*
# expressions to report both sides on failure — a function can't see them.
# (This is why ExUnit's `assert` is a macro, and your CRUD helper isn't.)
```

Reference: [Elixir — Macro anti-patterns: "Unnecessary macros"](https://hexdocs.pm/elixir/macro-anti-patterns.html#unnecessary-macros)
