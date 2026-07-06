---
title: Escape a computed term with Macro.escape before splicing it into quote
tags: quote, macro-escape, ast, data
---

## Escape a computed term with Macro.escape before splicing it into quote

A macro often computes a plain Elixir term — a map of defaults, a struct, a parsed config — and wants to inject it into the generated code. `unquote` expects a *quoted form* (AST), not a value. Some values happen to double as valid AST (integers, atoms, and lists/2-tuples of them — which is why a keyword list slips through), but a runtime-built map or struct does not: `unquote(a_map)` fails at compile time with `tried to unquote invalid AST: %{…} — Did you forget to escape term using Macro.escape/1?`. `Macro.escape/1` converts any value into the AST that reconstructs it. The rule: `unquote` a value directly only when it's already a literal or a quoted form; escape anything you built that isn't.

```elixir
defmacro defaults(opts) do
  # a runtime-built map — NOT valid AST on its own
  normalized = opts |> Keyword.put_new(:timeout, 5_000) |> Map.new()

  quote do
    def config, do: unquote(Macro.escape(normalized))
  end
end
```

Reference: [Elixir — `Macro.escape/1`](https://elixir.hexdocs.pm/Macro.html#escape/1)
