---
title: Compose multi-step writes with Ecto.Multi, not nested Repo.transaction
tags: ecto, multi, transactions, atomicity
---

## Compose multi-step writes with Ecto.Multi, not nested Repo.transaction

When an operation must write several rows atomically, the tempting shape is a `Repo.transaction(fn -> ... end)` with nested `case`s and manual `Repo.rollback/1` on each failure. It works but obscures which step failed and forces you to hand-thread rollback through every branch. `Ecto.Multi` builds the sequence as a data structure, runs it in one transaction, and returns `{:error, failed_step_name, failed_value, changes_so_far}` — you get the exact operation that failed and its changeset for free, and later steps can depend on earlier results via a function. It also composes: a Multi can be built up across functions and run once at the boundary.

```elixir
def fulfill_order(order, payment_attrs) do
  Ecto.Multi.new()
  |> Ecto.Multi.insert(:payment, Payment.changeset(%Payment{}, payment_attrs))
  |> Ecto.Multi.update(:order, Order.status_changeset(order, :confirmed))
  |> Ecto.Multi.insert(:shipment, Shipment.for_order(order))
  |> Repo.transaction()
  |> case do
    {:ok, %{order: order}} -> {:ok, order}
    {:error, :payment, changeset, _changes} -> {:error, changeset}   # you know payment failed
  end
end
```

For numeric fields updated concurrently (counters, balances, stock), don't read-modify-write in Elixir inside the Multi — that races. Use SQL-side arithmetic — see [`ecto-atomic-counters`](ecto-atomic-counters.md).

Reference: [Ecto — `Ecto.Multi`](https://hexdocs.pm/ecto/Ecto.Multi.html)
