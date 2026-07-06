---
title: Generate one clause per declaration with unquote fragments
tags: dsl, unquote-fragments, codegen, comprehension
---

## Generate one clause per declaration with unquote fragments

To emit a function per item — `admin?/0`, `guest?/0` from a list of roles — the wrong default is to build the clause ASTs by hand with `Macro`, or worse `Code.eval_string`. Elixir supports *unquote fragments*: `def unquote(name)(...)` inside a comprehension, where `unquote` in the function head is replaced per iteration. Return the list of quoted `def`s from the macro (a list of quoted forms is spliced as sibling definitions) and the compiler defines each clause as if you'd hand-written it — no string building, full stacktraces, real arity.

```elixir
defmacro defstates(states) do
  for state <- states do
    quote do
      def unquote(:"#{state}?")(status), do: status == unquote(state)
    end
  end
end

defmodule Order do
  require StateDSL
  StateDSL.defstates([:pending, :paid, :shipped])
  # generates: def pending?(status), do: status == :pending  (and paid?/1, shipped?/1)
end
```

Reference: [Elixir — `Kernel.SpecialForms.quote/2` (unquote fragments)](https://elixir.hexdocs.pm/Kernel.SpecialForms.html#quote/2-binding-and-unquote-fragments)
