---
title: Await every Task.async and supervise every fire-and-forget
tags: sup, task, spawn, link, monitor
---

## Await every Task.async and supervise every fire-and-forget

`Task.async` looks like a background job API, so it gets used for fire-and-forget — but it *links* the task to the caller and its contract requires a matching `Task.await`/`Task.yield`: an unawaited async task that crashes takes the caller down with it, and one that succeeds leaves its reply rotting in the caller's mailbox. The inverse mistake is bare `spawn`/`spawn_link` for work that matters: the process is invisible to the supervision tree, dies silently, and outlives shutdown ungracefully. Intent maps to exactly one primitive — need the result: `Task.async` + `await` (or `Task.Supervisor.async_nolink` when the caller must survive the task's crash); don't need the result: `Task.Supervisor.start_child`, so the task is owned, visible, and shut down with the tree.

**Evidence of violation:** a `Task.async` call whose returned task is never passed to `await`/`yield`/`yield_many` on any path; or a bare `spawn`/`spawn_link`/unsupervised `Task.start` launching work whose completion the system's behavior depends on (a write, a notification, a cleanup). PASS: async/await pairs; `async_nolink` under a `Task.Supervisor` with the `{:DOWN, ...}`/result handling present; fire-and-forget through `Task.Supervisor.start_child`. N/A: no task or process spawning in the target. Carve-out (citable): the spawned work is genuinely disposable — its silent loss changes nothing observable (a debug trace, a best-effort cache warm) — cite why loss is invisible; "it usually completes" is the violation, not the carve-out.

```elixir
# Caller needs the results: async + await, linked deliberately.
quote_task = Task.async(fn -> Quotes.fetch(ticker) end)
fx_task = Task.async(fn -> Fx.rate(currency) end)
[quote, fx] = Task.await_many([quote_task, fx_task])

# Caller must not die with the side effect: supervised fire-and-forget.
Task.Supervisor.start_child(MyApp.TaskSupervisor, fn ->
  Notifications.send_receipt(order.id)
end)
```

Reference: [Elixir `Task` — async/await contract and supervised tasks](https://hexdocs.pm/elixir/Task.html)
