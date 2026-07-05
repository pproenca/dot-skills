---
title: Pipe a data subject through transformations, not to save a variable
tags: data, pipe-operator, readability
---

## Pipe a data subject through transformations, not to save a variable

`|>` reads well when a single logical subject flows through a series of transformations, each taking it as the first argument. Two common misuses break that: starting a pipe with a bare function call (`Repo.all(query) |> ...`) rather than a plain value, which reads awkwardly and complicates debugging; and forcing unrelated one-off calls into a pipe just to avoid an intermediate variable, which obscures that the "subject" changed identity halfway through. A single function call should stay a single call — `String.trim(input)` is clearer than `input |> String.trim()`. Pipe for a genuine pipeline; use a named intermediate when a step's result is conceptually a new thing.

```elixir
# Good: one subject (the params) threaded through cleaning steps.
def normalize_email(params) do
  params
  |> Map.get("email", "")
  |> String.trim()
  |> String.downcase()
end

# Start from a value, not a call: bind the query, then pipe the value.
query = from(o in Order, where: o.status == :paid)
orders = query |> Repo.all() |> Enum.group_by(& &1.user_id)
```

Reference: [Credo — `PipeChainStart` check](https://hexdocs.pm/credo/Credo.Check.Refactor.PipeChainStart.html) · [Elixir — `Kernel.|>/2`](https://hexdocs.pm/elixir/Kernel.html#%7C%3E/2)
