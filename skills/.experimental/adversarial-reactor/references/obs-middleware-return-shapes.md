---
title: Return the documented shapes from middleware callbacks — bare values break the chain
tags: obs, middleware, return-contract, callbacks
---

## Return the documented shapes from middleware callbacks — bare values break the chain

Middleware callbacks are links in a chain the reactor threads its state
through, and each has an exact return contract: `init/1`, `complete/2`, and
`halt/1` return `{:ok, value}` or `{:error, reason}`; `error/2` returns `:ok`
or `{:error, reason}`; `event/3` returns `:ok`. The wrong default — carried
over from plug-style `conn -> conn` pipelines — is returning the bare context
or result: `def init(context), do: context`. The chain receives an invalid
return, and the failure lands at reactor startup or completion, far from the
middleware that caused it; a bare return from `error/2` can swallow the very
error being reported.

**Evidence of violation:** a `Reactor.Middleware` callback whose return is
not wrapped per the behaviour spec — `init`/`complete`/`halt` returning the
bare context/result, `event` returning anything but `:ok`. Every exit path of
every clause counts. PASS: all middleware callbacks in the target return
documented shapes. N/A: the target defines no middleware.

```elixir
defmodule MyApp.RunAudit do
  use Reactor.Middleware

  @impl true
  def init(context) do
    {:ok, Map.put(context, :run_started_at, DateTime.utc_now())}
  end

  @impl true
  def complete(result, _context) do
    {:ok, result}
  end
end
```

Reference: [Reactor.Middleware — callback specifications](https://reactor.hexdocs.pm/Reactor.Middleware.html)
