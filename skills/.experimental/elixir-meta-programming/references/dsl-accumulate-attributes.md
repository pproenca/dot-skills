---
title: Collect declarations in an accumulating attribute, drain it in @before_compile
tags: dsl, before-compile, module-attributes, accumulate
---

## Collect declarations in an accumulating attribute, drain it in @before_compile

A block DSL (`schema do field ... end`, `router do route ... end`) is many small declarations that together define one module. The wrong default is to build a runtime registry, or to have `@before_compile` reconstruct behaviour from data it doesn't have. The idiomatic mechanism: register a module attribute with `accumulate: true` so each declaration *records its name* (and defines its own function), then hook `@before_compile`, which fires once after the block with every name collected, and generate the aggregate code there. This is how `Ecto.Schema`, `ExUnit`, and `Plug.Router` work. Two things to get right: `accumulate: true` prepends, so `Enum.reverse/1` when order matters; and record only escapable *data* (an atom name), never a closure — anonymous functions can't be `Macro.escape`d, so store the name and `def` a function for it instead.

```elixir
defmodule Workflow do
  defmacro __using__(_opts) do
    quote do
      import Workflow, only: [step: 2]
      Module.register_attribute(__MODULE__, :workflow_steps, accumulate: true)
      @before_compile Workflow
    end
  end

  defmacro step(name, do: block) do
    quote do
      @workflow_steps unquote(name)
      def unquote(:"step_#{name}")(), do: unquote(block)
    end
  end

  defmacro __before_compile__(env) do
    names = env.module |> Module.get_attribute(:workflow_steps) |> Enum.reverse()

    quote do
      def run do
        Enum.reduce(unquote(names), %{}, fn name, acc ->
          Map.put(acc, name, apply(__MODULE__, :"step_#{name}", []))
        end)
      end
    end
  end
end
```

Reference: [Elixir — Domain-specific languages](https://elixir.hexdocs.pm/domain-specific-languages.html) · [`Module` — `register_attribute/3`, `@before_compile`](https://elixir.hexdocs.pm/Module.html#module-compile-callbacks)
