---
title: Generate an introspection function so callers read data, not re-run macros
tags: dsl, introspection, reflection, before-compile
---

## Generate an introspection function so callers read data, not re-run macros

Once `@before_compile` has the full list of declarations, generate a plain function that returns it — `__schema__(:fields)`, `__routes__/0`, `__workflow__(:steps)`. Without it, downstream code that needs the DSL's shape (a serializer walking every field, an admin UI listing routes) has no way in except to re-parse source or duplicate the declarations, so the two drift. A generated reflection function turns the compile-time DSL into queryable runtime data — the reason `Ecto.Schema` exposes `__schema__/1` and Phoenix exposes `__routes__/0`. When the reflected payload is richer than a list of atoms (field metadata maps, for instance), remember to `Macro.escape/1` it before splicing — see [`quote-escape-runtime-data`](quote-escape-runtime-data.md).

```elixir
defmacro __before_compile__(env) do
  names = env.module |> Module.get_attribute(:workflow_steps) |> Enum.reverse()

  quote do
    # a list of atoms is a literal, so no escape needed here
    def __workflow__(:steps), do: unquote(names)
    # SomeReport.__workflow__(:steps) #=> [:fetch, :transform, :load]
  end
end
```

Reference: [Ecto — `Ecto.Schema` reflection (`__schema__/1`)](https://hexdocs.pm/ecto/Ecto.Schema.html#module-reflection)
