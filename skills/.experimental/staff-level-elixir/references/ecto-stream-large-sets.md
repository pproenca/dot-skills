---
title: Stream or batch large result sets instead of Repo.all
tags: ecto, repo-stream, batching, memory
---

## Stream or batch large result sets instead of Repo.all

`Repo.all/1` loads every matching row into memory at once. On a table that has grown to millions of rows — a nightly export, a backfill, re-indexing — that is an out-of-memory waiting to happen, and it works fine in dev where the table is small. Use `Repo.stream/2` inside a `Repo.transaction/1` (the transaction is required to hold the DB cursor open) to pull rows in chunks with constant memory, or paginate explicitly with `limit` + a keyset/offset when you can't hold a transaction open. Combine with `Stream` so the whole pipeline stays lazy end to end.

```elixir
# Constant-memory export: DB cursor + lazy transform, chunked writes.
Repo.transaction(fn ->
  from(o in Order, where: o.status == :completed)
  |> Repo.stream(max_rows: 500)
  |> Stream.map(&serialize_order/1)
  |> Stream.chunk_every(1_000)
  |> Enum.each(&write_batch/1)
end, timeout: :infinity)
```

**When NOT to use this pattern:** small, bounded result sets — a user's own orders, a lookup by id. `Repo.stream`'s transaction and cursor overhead isn't worth it there; `Repo.all` is simpler and fine.

Reference: [Ecto — `Ecto.Repo.stream/2`](https://hexdocs.pm/ecto/Ecto.Repo.html#c:stream/2)
