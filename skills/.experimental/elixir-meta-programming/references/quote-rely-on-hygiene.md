---
title: Rely on macro hygiene; break it with var! only deliberately
tags: quote, hygiene, var, capture
---

## Rely on macro hygiene; break it with var! only deliberately

Elixir macros are hygienic: a variable bound inside a `quote` lives in the macro's own context and cannot clash with or overwrite a variable of the same name in the caller. Engineers coming from Lisp or Ruby macros expect the opposite and reach for `var!` to "share" a variable with the caller — which silently rebinds the user's `conn`, `result`, or `assigns` and creates action-at-a-distance bugs that are invisible at the call site. The correct default is to leave hygiene on: pass data in and out as normal arguments and return values. Use `var!(name)` only when injecting into the caller's scope *is* the documented contract of the macro (as `Plug.Conn`/Phoenix do with `conn`), and say so.

```elixir
# Hygienic: the macro's temporary `entries` cannot stomp the caller's `entries`.
defmacro render_list(items) do
  quote do
    entries = Enum.map(unquote(items), &to_string/1)
    Enum.join(entries, ", ")
  end
end

# Caller keeps its own binding intact:
#   entries = :untouched
#   render_list([1, 2, 3])   #=> "1, 2, 3"
#   entries                  #=> :untouched
```

**When breaking hygiene is legitimate:** a DSL whose whole purpose is to expose a name to the block (e.g. `var!(conn)`). Do it explicitly and document that the name is injected, so the reader isn't surprised.

Reference: [Elixir — Macro hygiene](https://elixir.hexdocs.pm/macros.html#macros-hygiene)
