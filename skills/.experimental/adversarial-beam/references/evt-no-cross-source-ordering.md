---
title: Never assume message ordering across processes, topics, or nodes
tags: evt, ordering, pubsub, sequence
---

## Never assume message ordering across processes, topics, or nodes

The BEAM guarantees signal order between exactly one sender and one receiver: if process A sends M1 then M2 to process B, B sees M1 before M2. Everything beyond that pair is unordered — two producers casting to one consumer interleave arbitrarily, two PubSub topics have no relative order, and distributed PubSub adds network reordering across nodes. Code that applies incoming events as order-dependent deltas — state-machine transitions, "latest write wins" by arrival, positional increments — is betting correctness on an ordering the runtime never promised, and loses it exactly under the concurrency and clustering the design was built for. Order must be carried *in the data* (a sequence number, a version) or manufactured *by topology* (funnel all order-sensitive events through one producer process pair).

**Evidence of violation:** a consumer (`handle_info`, `handle_cast`, PubSub subscriber, channel handler) that receives messages originating from two or more sender processes, topics, or nodes and applies them as order-dependent operations — a state transition table keyed on current state, an overwrite treated as "newest," an append interpreted positionally — with no sequencing guard (no version/sequence comparison, no timestamp fencing, no single-producer funnel). PASS: a monotonic version or sequence check rejects or reorders stale events; or every order-sensitive message provably traverses a single sender-receiver pair, and the reviewer cites that funnel. N/A: no consumer receives order-sensitive messages from multiple sources. Carve-out (citable): the operations are commutative — the result is the same in any arrival order (a set union, a max, a counter of independent facts) — the reviewer must state why they commute, not accept the label.

```elixir
# Order lives in the data: each entity carries a version, and stale
# arrivals are dropped no matter which node or producer they came from.
def handle_info({:price_updated, %{sku: sku, version: v} = quote}, state) do
  case state.quotes[sku] do
    %{version: current} when current >= v -> {:noreply, state}
    _ -> {:noreply, put_in(state.quotes[sku], quote)}
  end
end
```

Reference: [Erlang Reference Manual — Processes, signal delivery ordering](https://www.erlang.org/doc/system/ref_man_processes.html#delivery-of-signals)
