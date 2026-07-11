---
title: Return fast from init and finish startup in handle_continue
tags: sup, genserver, init, handle-continue
---

## Return fast from init and finish startup in handle_continue

`init/1` runs synchronously inside the supervisor's start sequence: while it blocks, no later sibling starts, and at boot the whole application waits. Worse, a failing external call in `init` crashes the child, the supervisor retries, and a dependency outage at deploy time burns the restart intensity and takes the supervisor down — an unreachable database converts into "the app won't boot." The runtime has a purpose-built escape: return `{:ok, state, {:continue, ...}}` and do the expensive or fallible work in `handle_continue/2`, which runs first in the new process, before any other message, but after the supervisor has moved on.

**Evidence of violation:** an `init/1` (or `mount/3`-style equivalent under a supervisor — `start_link` bodies count) that performs external or unbounded work before returning — a `Repo` call, an HTTP request, a TCP/AMQP connect with retries, reading an unbounded file, `Process.sleep`, or a blocking `receive`. PASS: `init` does only cheap local setup (building state, creating an ETS table, subscribing to PubSub, scheduling a timer) and defers the rest via `{:continue, ...}` or a self-sent message. N/A: no process init code in the target. Carve-out (citable): the process is deliberately a boot gate — the application genuinely must not come up without the resource — cite the comment or supervisor config stating that intent; an accidental blocking `init` with no stated intent is the violation.

```elixir
def init(opts) do
  # Cheap, infallible setup only — the supervisor is waiting on this return.
  {:ok, %{conn: nil, opts: opts}, {:continue, :connect}}
end

def handle_continue(:connect, state) do
  # Fallible work runs in this process; a crash here is isolated and retried
  # by the supervisor without stalling the rest of the tree's startup.
  {:ok, conn} = MyApp.Broker.connect(state.opts)
  {:noreply, %{state | conn: conn}}
end
```

Reference: [Elixir `GenServer` — `handle_continue/2`](https://hexdocs.pm/elixir/GenServer.html#c:handle_continue/2)
