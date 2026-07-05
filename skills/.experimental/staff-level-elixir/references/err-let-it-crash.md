---
title: Let unexpected failures crash instead of rescuing to mask them
tags: err, let-it-crash, supervisor, rescue
---

## Let unexpected failures crash instead of rescuing to mask them

The defensive habit from other runtimes is to wrap risky code in `try/rescue`, log, and continue. On the BEAM that is usually wrong: a process that hits an unexpected error is in an unknown state, and continuing on corrupt state produces subtler bugs than crashing. Let it crash — the supervisor restarts the process from a known-good initial state, and the failure is isolated to that process rather than the whole system. Rescue only when you can *meaningfully recover* (retry a specific transient error, convert a known exception into a tagged tuple at an API boundary), and rescue the specific exception, never a bare `rescue e`. Blanket rescuing also swallows the stacktrace that would have told you what broke.

```elixir
# Don't guard the whole world; let a genuinely broken message crash the worker.
def handle_info({:process, job}, state) do
  result = ExternalService.charge(job)   # if this raises unexpectedly, crash + restart
  {:noreply, record(state, result)}
end

# Rescue only where you can recover into a value the caller handles.
def parse_config(raw) do
  {:ok, Jason.decode!(raw)}
rescue
  e in Jason.DecodeError -> {:error, {:invalid_config, Exception.message(e)}}
end
```

Reference: [Elixir — `Supervisor` (restart from clean state)](https://hexdocs.pm/elixir/Supervisor.html) · [Elixir — `try/catch/rescue`](https://hexdocs.pm/elixir/try-catch-and-rescue.html)
