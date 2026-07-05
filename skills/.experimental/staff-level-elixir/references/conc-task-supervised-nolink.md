---
title: Use a supervised, unlinked Task for fire-and-forget work
tags: conc, task, task-supervisor, isolation
---

## Use a supervised, unlinked Task for fire-and-forget work

`Task.async/1` and `Task.start_link/1` **link** the task to the caller: if the task crashes, the caller crashes too. That is correct when you're about to `await` the result, but wrong for side-effect work you spin off and don't wait on — sending a webhook, warming a cache, emitting analytics — where a failure in that side job should not take down the request process or GenServer that launched it. Start those under a `Task.Supervisor` with `async_nolink` (or `start_child`): the task is supervised (so crashes are logged and don't leak) but *not* linked to the caller, isolating the failure. Bare `Task.start/1` is unsupervised and leaks the process on crash; `spawn` is worse.

```elixir
# In your supervision tree:
#   {Task.Supervisor, name: MyApp.TaskSupervisor}

def record_signup(user) do
  # Fire-and-forget: a webhook failure must not crash the caller.
  Task.Supervisor.start_child(MyApp.TaskSupervisor, fn ->
    Webhooks.notify(:user_signed_up, user)
  end)

  :ok
end
```

Reference: [Elixir — `Task.Supervisor`](https://hexdocs.pm/elixir/Task.Supervisor.html)
