---
title: Build sustained multi-stage processing on demand, not on push
tags: load, genstage, broadway, pipeline, demand
---

## Build sustained multi-stage processing on demand, not on push

A hand-rolled pipeline — a receive loop that `cast`s to a parser that `send`s to a writer — pushes: every stage forwards as fast as it receives, so the slowest stage's mailbox absorbs the whole stream's excess. Backpressure only works end-to-end; one push hop in the middle silently converts the entire upstream into a firehose aimed at that hop. GenStage inverts the flow — consumers *ask* for demand and producers emit at most what was asked — and Broadway packages that inversion with acking, batching, and graceful draining for the common sources (SQS, RabbitMQ, Kafka, PubSub). This rule fails only when the replacement is nameable: the reviewer must be able to say which stages become producer/consumer stages, or which Broadway source adapter applies.

**Evidence of violation:** a continuous external source (queue consumer, TCP/UDP stream, polling loop) whose items traverse two or more process hops connected by `cast`/`send` with no demand signal or bounded buffer between any pair of stages — *and* the reviewer can name the demand-driven shape that replaces it (the GenStage producer/consumer split, or the specific Broadway adapter). If no such shape can be named, the verdict is PASS. PASS otherwise: GenStage/Broadway/Flow pipelines; hand-rolled stages that carry an explicit demand or ack protocol; single-hop consumers (judged by the `cast`-versus-`call` rule instead). N/A: no sustained multi-stage stream processing in the target. Carve-out (citable): the stream is bounded and finite — a one-shot backfill over a known dataset — cite what bounds it.

```elixir
defmodule MyApp.OrderIngest do
  use Broadway
  # Broadway owns the demand loop: RabbitMQ delivers only what the
  # processors have asked for, failures are acked/rejected explicitly,
  # and shutdown drains in flight messages instead of dropping mailboxes.
  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [module: {BroadwayRabbitMQ.Producer, queue: "orders"}],
      processors: [default: [concurrency: 8]]
    )
  end

  def handle_message(_processor, message, _context) do
    MyApp.Orders.apply_event!(message.data)
    message
  end
end
```

Reference: [Broadway — rationale and architecture](https://hexdocs.pm/broadway/introduction.html)
