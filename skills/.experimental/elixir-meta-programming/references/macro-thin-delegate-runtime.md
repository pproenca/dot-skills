---
title: Keep the macro thin; expand to a call into a runtime function
tags: macro, quote, testability, delegation
---

## Keep the macro thin; expand to a call into a runtime function

The reflex once you commit to a macro is to write the real logic *inside* the `quote` block. Don't: quoted code is copied into every call site, so any logic there bloats the compiled module, and it can only be exercised through compilation — you can't call it in `iex` or unit-test it directly, and a crash points at the expansion site, not at readable source. Keep the quoted part to the smallest possible shell — usually a single call — and put the work in an ordinary public function that takes plain arguments. The macro exists only to capture what a function can't (unevaluated forms, compile-time position); everything else is a normal function you can test.

```elixir
defmodule Workflow.DSL do
  # Thin macro: capture the block, hand its result to a runtime function.
  defmacro step(name, do: block) do
    quote do
      Workflow.Engine.register_step(__MODULE__, unquote(name), fn -> unquote(block) end)
    end
  end
end

# All logic lives here — testable with a plain `Workflow.Engine.register_step(...)` call,
# no macro expansion required.
defmodule Workflow.Engine do
  def register_step(module, name, fun) when is_atom(name) and is_function(fun, 0) do
    # validation, storage, ordering — ordinary code
  end
end
```

Reference: [Elixir — Macros guide](https://elixir.hexdocs.pm/macros.html)
