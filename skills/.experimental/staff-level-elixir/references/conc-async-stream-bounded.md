---
title: Fan out with Task.async_stream, bounded and with an explicit timeout
tags: conc, task, async-stream, backpressure
---

## Fan out with Task.async_stream, bounded and with an explicit timeout

The naive parallel map — `Enum.map(items, &Task.async/1) |> Enum.map(&Task.await/1)` — spawns one process per item with no ceiling, flooding the schedulers on a large list. `Task.async_stream` caps parallelism at `max_concurrency` (defaults to the core count) for natural backpressure and lets you bound each item with `timeout` plus `on_timeout: :kill_task`, so a slow item yields `{:exit, :timeout}` instead of raising. Set the timeout deliberately — the default is 5s and the default `on_timeout: :exit` crashes the caller when it's hit. One nuance to know: `async_stream` **links** its tasks to the caller, so a task that *raises* still takes the caller down; if you need per-item failure isolation (not just timeout handling), use `Task.Supervisor.async_stream_nolink/6`, which surfaces a crashed task as `{:exit, reason}` instead of propagating.

```elixir
# Bounded fan-out where a crash in one item must not sink the batch:
# the *_nolink variant isolates both slow and failing SKUs into {:exit, reason}.
def fetch_all_prices(skus) do
  MyApp.TaskSupervisor
  |> Task.Supervisor.async_stream_nolink(
    skus,
    &PricingApi.fetch/1,
    max_concurrency: 10,
    timeout: 8_000,
    on_timeout: :kill_task
  )
  |> Enum.map(fn
    {:ok, price} -> {:ok, price}
    {:exit, reason} -> {:error, reason}   # slow OR crashed SKU, isolated per item
  end)
end
```

**When plain `Task.async_stream/3` is fine:** the tasks can't raise (or a crash *should* bring the whole operation down), and you only need bounding + timeout. It needs no supervisor in the tree.

Reference: [Elixir — `Task.async_stream/5`](https://hexdocs.pm/elixir/Task.html#async_stream/5)
