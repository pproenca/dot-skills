---
title: Branch with function clauses and guards, not if/cond on argument shape
tags: data, pattern-matching, guards, function-clauses
---

## Branch with function clauses and guards, not if/cond on argument shape

When behaviour depends on the *shape* of the input — a tuple tag, a struct type, a status field, an empty vs non-empty list — the fluent Elixir move is multiple function heads with pattern matches and guards, not an `if`/`cond`/`case` ladder inside one body. Clauses let the compiler dispatch on structure, make each case independently readable and testable, and warn on non-exhaustive matches. Packing the branches into conditionals hides the structure the code is actually keying on and grows a tangle of nested `if`s. Use `cond` only for genuinely unrelated boolean tests, and a single `case` when you're matching one expression's result inline.

**Correct (clauses dispatch on shape):**

```elixir
# Dispatch on shape via heads + guards.
def describe({:ok, %{count: 0}}), do: "empty result"
def describe({:ok, %{count: n}}) when n > 0, do: "#{n} results"
def describe({:error, reason}), do: "failed: #{inspect(reason)}"

# Recursion reads as base-case + step, not an if inside a loop.
def sum([]), do: 0
def sum([head | tail]), do: head + sum(tail)
```

**Incorrect (conditionals hiding the shape):**

```elixir
def describe(result) do
  if elem(result, 0) == :ok do
    data = elem(result, 1)
    if data.count == 0, do: "empty result", else: "#{data.count} results"
  else
    "failed: #{inspect(elem(result, 1))}"
  end
end
```

Reference: [Elixir — Pattern matching](https://hexdocs.pm/elixir/pattern-matching.html)
