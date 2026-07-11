---
title: Use call, not cast, where producers can outrun the consumer
tags: load, genserver, cast, backpressure, mailbox
---

## Use call, not cast, where producers can outrun the consumer

`cast` reads as "faster than call, and I don't need the reply," so it becomes the default on ingest paths. But a BEAM mailbox is unbounded and the overflow policy is VM death: when producers are driven by an external rate (web requests, a socket, a queue) and the consumer does real work per message, `cast` decouples arrival from processing and the mailbox absorbs the difference until memory runs out — and mailbox growth also makes the victim *slower* first, accelerating the spiral. `call` is the zero-infrastructure backpressure primitive: the producer blocks until the consumer is ready, so overload propagates back to the edge where it can be rejected, instead of accumulating in the middle where it cannot.

**Evidence of violation:** a `GenServer.cast` or bare `send` on a path whose message rate is set by external input — invoked per web request, per socket/queue message, per streamed element — into a process doing nontrivial per-message work (database or network IO, file writes), with no bounding mechanism anywhere on the path (no demand-driven stage, no `Process.info(pid, :message_queue_len)` shedding, no rate limiter, no bounded buffer). PASS: `call` on the ingest edge; or `cast` with a citable bound in place. N/A: no producer-to-consumer messaging on an externally-driven path. Carve-out (citable): the producer's rate is intrinsically bounded and low — a timer tick, a config reload, a supervisor lifecycle event — cite the bound; "we haven't seen it back up" is the violation's incubation period, not a carve-out.

```elixir
# The controller (producer) blocks until the writer has capacity — under
# overload, requests slow down and time out at the edge, where the load
# balancer and client retries can react. The mailbox stays flat.
def track_event(attrs) do
  GenServer.call(MyApp.EventWriter, {:track, attrs}, 5_000)
end
```

Reference: [Fred Hébert — "Handling Overload"](https://ferd.ca/handling-overload.html)
