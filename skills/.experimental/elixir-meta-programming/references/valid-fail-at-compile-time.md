---
title: Validate the DSL in the macro body, not in the returned quote
tags: valid, compile-time, validation, errors
---

## Validate the DSL in the macro body, not in the returned quote

The whole point of a compile-time DSL is that mistakes are caught at `mix compile`, before the app boots. That only happens if the check runs in the *macro body* — code that executes during expansion. Put a `raise` inside the returned `quote` instead and it becomes runtime code, so an unknown option or duplicate field surfaces on the first request in production, not in the build. Do the validation where you have the declaration in hand at compile time; for whole-DSL invariants (duplicate names, missing required declaration) validate in `@before_compile`, where the full accumulated list is available.

**Incorrect (raise inside `quote` — deferred to runtime):**

```elixir
defmacro field(name, opts) do
  quote do
    unless unquote(opts)[:type], do: raise "field #{unquote(name)} needs :type"
    @fields {unquote(name), unquote(opts)}
  end
end
```

**Correct (validate in the macro body — fails the compile):**

```elixir
defmacro field(name, opts) do
  unless Keyword.has_key?(opts, :type) do
    raise ArgumentError, "field #{inspect(name)} requires a :type option"
  end

  quote do
    @fields {unquote(name), unquote(opts)}
  end
end
```

Reference: [Elixir — Macros guide](https://elixir.hexdocs.pm/macros.html)
