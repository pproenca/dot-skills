---
title: Keep telemetry handlers cheap — they run inline and detach on the first raise
tags: evt, telemetry, observability, handlers
---

## Keep telemetry handlers cheap — they run inline and detach on the first raise

`:telemetry` looks like an async event bus, but it is a synchronous function call: every attached handler runs *in the process that executed the event*, on the hot path it instruments. A handler that writes to the database or calls an HTTP exporter adds that latency to every request, query, or job it observes. And the failure mode is worse than slowness: if a handler raises, `:telemetry` permanently detaches it — metrics and alerts silently stop while the application runs on, which is the observability equivalent of cutting the smoke-detector wires. Handlers must do bounded local work (bump an ETS counter, `send` to a collector process) and treat everything fallible defensively.

**Evidence of violation:** a handler function passed to `:telemetry.attach/4` or `attach_many/4` that performs blocking IO (a `Repo` call, an HTTP request, a `GenServer.call` into a server that takes external traffic) or raise-prone work (unguarded pattern matches on event metadata, `!`-functions) with no `rescue`/`catch`. PASS: handlers that update ETS/counters, emit to a local process via `send`, or hand off to a batching collector — with fallible steps wrapped so a raise cannot reach `:telemetry`'s detach logic. N/A: the target attaches no telemetry handlers (merely *executing* `:telemetry.execute` or emitting spans is not in scope). Carve-out (citable): the handler is attached in a one-off script or test support file where detachment and latency are irrelevant — cite the file's role.

```elixir
def handle_event([:my_app, :repo, :query], measurements, metadata, _config) do
  # Bounded local work only; the caller is a live request. Anything
  # fallible is caught — a metrics bug must never detach the handler.
  try do
    :ets.update_counter(:query_stats, metadata.source, {2, 1}, {metadata.source, 0})
    send(MyApp.MetricsCollector, {:query, metadata.source, measurements.total_time})
  rescue
    _ -> :ok
  end
end
```

Reference: [`:telemetry.attach/4` — handler failure causes detachment](https://hexdocs.pm/telemetry/telemetry.html#attach/4)
