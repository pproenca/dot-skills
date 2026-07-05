---
title: Replace transliterated loops with the named Enum/Stream combinator
tags: iter, enum, reduce, recursion
---

## Replace transliterated loops with the named Enum/Stream combinator

Code carried over from an imperative language often arrives as a for-loop in disguise: an `Enum.reduce` that rebuilds a result the standard library already names, or an explicit `[head | tail]` recursion threading an accumulator. Both hide *what* is being computed behind accumulator plumbing, are easy to get subtly wrong (accumulator order, the base case), and don't compose into a pipeline. `reduce` is the universal fallback and recursion is the manual mechanism — reaching for either first is the smell. Scan for the named combinator (`group_by`, `frequencies`, `sum_by`, `map`, `filter`, `max_by`, `into`, `chunk_by`) whose name states intent and whose implementation is correct and optimized.

**Incorrect (a reduce reimplements `group_by`, a recursion reimplements `sum_by`):**

```elixir
Enum.reduce(orders, %{}, fn o, acc ->
  Map.update(acc, o.customer_id, [o], &[o | &1])
end)

def total_price([]), do: 0
def total_price([item | rest]), do: item.price + total_price(rest)
```

**Correct (the intent is in the name):**

```elixir
Enum.group_by(orders, & &1.customer_id)

def total_price(items), do: Enum.sum_by(items, & &1.price)
```

**When recursion IS right:** genuinely non-list-shaped traversal — walking a tree, custom termination, or generating a sequence — where no `Enum`/`Stream` combinator fits. Keep `reduce` for accumulation no named function expresses.

Reference: [Elixir — Enum](https://hexdocs.pm/elixir/Enum.html)
