---
title: Keep __using__ to setup only — its AST is copied into every caller
tags: dsl, using, injection, coupling
---

## Keep __using__ to setup only — its AST is copied into every caller

Whatever `__using__/1` returns is injected *verbatim* into every module that writes `use MyDSL`, and it's invisible at that call site — the reader sees one line and inherits a wall of code. So the cost of anything you put there is paid per user module and hidden. Keep it to setup that must run in the caller: `import` the declaration macros, register the accumulating attributes, and register `@before_compile`. Real function generation belongs in `@before_compile`, where it happens once in the DSL module instead of being stamped into each caller. If the injected block grows past a handful of `import`/`register`/`@before_compile` lines, that's the signal it's doing work that should move out.

```elixir
defmacro __using__(_opts) do
  quote do
    import Workflow, only: [step: 2]
    Module.register_attribute(__MODULE__, :workflow_steps, accumulate: true)
    @before_compile Workflow
  end
end
```

Reference: [Elixir — Macro anti-patterns: "`use` instead of `import`"](https://hexdocs.pm/elixir/macro-anti-patterns.html#use-instead-of-import)
