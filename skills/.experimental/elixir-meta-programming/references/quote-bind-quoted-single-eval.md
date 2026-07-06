---
title: Use bind_quoted so an unquoted expression evaluates once
tags: quote, bind_quoted, unquote, evaluation
---

## Use bind_quoted so an unquoted expression evaluates once

`unquote(expr)` splices the *AST* of `expr` into the generated code, so every place it appears is a fresh copy that re-runs at runtime. If the argument has side effects or cost — `next_id()`, `File.read!(path)`, a function call — writing `unquote(x)` twice makes it happen twice, a bug that never shows up on a pure literal and bites the first time someone passes an impure argument. `quote bind_quoted: [x: x]` evaluates each binding exactly once, assigns it to a hygienic variable, and disables further `unquote` inside the block — the correct default whenever an argument is referenced more than once.

**Incorrect (argument spliced twice → evaluated twice):**

```elixir
defmacro log_twice(expr) do
  quote do
    IO.puts("a: #{unquote(expr)}")
    IO.puts("b: #{unquote(expr)}")   # unquote(expr) runs again
  end
end

log_twice(System.unique_integer())   # prints two DIFFERENT integers
```

**Correct (`bind_quoted` — one evaluation):**

```elixir
defmacro log_twice(expr) do
  quote bind_quoted: [value: expr] do
    IO.puts("a: #{value}")
    IO.puts("b: #{value}")
  end
end

log_twice(System.unique_integer())   # both lines print the SAME integer
```

Reference: [Elixir — `Kernel.SpecialForms.quote/2` (`bind_quoted`)](https://elixir.hexdocs.pm/Kernel.SpecialForms.html#quote/2)
