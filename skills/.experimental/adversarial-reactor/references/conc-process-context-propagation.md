---
title: Propagate process-local state into async steps explicitly — it does not follow
tags: conc, process-context, middleware, logger-metadata
---

## Propagate process-local state into async steps explicitly — it does not follow

An async step runs in a freshly spawned task process. Anything the calling
process kept in process-local storage — `Logger.metadata` (request/trace ids),
the process dictionary, OpenTelemetry span context, Ecto sandbox allowances —
is simply absent there. Nothing crashes: log lines silently lose their trace
id, spans detach, and the bug is invisible until someone tries to follow one
request through the logs. The escape hatches are explicit: mark the step
`async? false` so it runs in the main process, or implement the middleware
pair `get_process_context/0` (captures state before the task spawns) and
`set_process_context/1` (restores it inside the task).

**Evidence of violation:** a step body that depends on caller-process state —
reads `Process.get`, relies on `Logger.metadata` set outside the step, expects
sandbox ownership or span context — on a step without `async? false`, in a
reactor with no middleware implementing `get_process_context`/
`set_process_context`. PASS: process-local dependencies are covered by
`async? false` or a process-context middleware the reviewer can name. N/A: no
step in the target depends on process-local state.

```elixir
defmodule MyApp.ReactorLoggerMetadata do
  use Reactor.Middleware

  @impl true
  def get_process_context, do: Logger.metadata()

  @impl true
  def set_process_context(metadata) do
    Logger.metadata(metadata)
    :ok
  end
end
```

Reference: [Reactor.Middleware — process context callbacks](https://reactor.hexdocs.pm/Reactor.Middleware.html)
