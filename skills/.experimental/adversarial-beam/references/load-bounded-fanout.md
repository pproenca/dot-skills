---
title: Bound concurrent fan-out over externally-sized collections
tags: load, task, async-stream, concurrency
---

## Bound concurrent fan-out over externally-sized collections

`Enum.map(&Task.async/1)` over a collection spawns one concurrent task per element — and when the collection's size comes from outside (a query result, a request payload, a file), the *input decides the concurrency*. A thousand-row result becomes a thousand simultaneous HTTP connections or database checkouts, exhausting pools and remote rate limits in one shot. Processes are cheap; the resources each task grabs are not. `Task.async_stream/3` is the same fan-out with a knob: it runs at most `max_concurrency` tasks (defaulting to the number of schedulers) and pulls the next element only as one finishes.

**Evidence of violation:** `Task.async` (or `spawn`) launched per element of a collection whose size is determined by external input — a Repo query result, request params, decoded payload, file or stream contents — with all tasks live concurrently (mapped then awaited) and no concurrency bound. PASS: `Task.async_stream` (its default `max_concurrency` counts as a bound) or an explicit bound (chunking, a pool, a counting semaphore). N/A: no per-element concurrent fan-out in the target. Carve-out (citable): the collection is provably small and fixed — a compile-time list, a bounded enum of variants — cite what fixes its size; "it's usually a handful of rows" is the violation waiting for the big tenant.

```elixir
# Concurrency is a property of the system (pool sizes, rate limits),
# not of the input length. Ten at a time, however many rows arrive.
results =
  invoices
  |> Task.async_stream(&PaymentGateway.settle/1,
    max_concurrency: 10,
    timeout: 15_000,
    on_timeout: :kill_task
  )
  |> Enum.to_list()
```

Reference: [Elixir `Task.async_stream/3` — `max_concurrency`](https://hexdocs.pm/elixir/Task.html#async_stream/3)
