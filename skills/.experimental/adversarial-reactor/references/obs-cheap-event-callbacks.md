---
title: Keep middleware event/3 callbacks cheap — they run inline in the executor
tags: obs, middleware, events, blocking
---

## Keep middleware event/3 callbacks cheap — they run inline in the executor

`event/3` fires synchronously for every step event in the reactor — it is a
notification hook, not a worker. An HTTP post to an audit service, a
`Repo.insert` of an event row, or heavy serialization inside `event/3` runs on
the executor's critical path, once per step event, turning observability into
a per-step tax that slows every reactor mounting the middleware. The wrong
default is treating it like an async telemetry handler. Do the cheap capture
inline — build a small term, `send` it to a collector process, increment a
counter — and let another process do the expensive part off the reactor's
path.

**Evidence of violation:** a `def event(...)` in a `Reactor.Middleware` whose
body performs I/O inline — an HTTP call, a `Repo.*` call, file writes,
expensive encoding of large payloads. PASS: `event/3` bodies only build terms
and hand off (`send`, `:telemetry.execute`, ETS insert, GenServer cast) or
no middleware defines `event/3`. N/A: no middleware in the target.

```elixir
@impl true
def event(event, step, _context) do
  # Cheap capture inline; the collector does the expensive persistence.
  send(MyApp.AuditCollector, {:reactor_event, event, step.name})
  :ok
end
```

Reference: [Reactor.Middleware — event/3](https://reactor.hexdocs.pm/Reactor.Middleware.html)
