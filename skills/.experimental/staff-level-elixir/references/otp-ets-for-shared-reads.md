---
title: Use ETS for read-heavy shared state, not a GenServer
tags: otp, ets, cache, concurrency
---

## Use ETS for read-heavy shared state, not a GenServer

For state that is read by many processes and written rarely — a cache, feature flags, loaded config — the default reflex is a GenServer with a `get/1` call. That funnels every concurrent read through one mailbox, so reads block each other and the server's queue becomes the bottleneck. A public ETS table with `read_concurrency: true` lets callers read directly and in parallel with no message passing; a single owner process (or a supervisor-started table) handles the rare writes. The GenServer stops being on the read path entirely.

```elixir
defmodule FeatureFlags do
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  # Reads hit ETS directly — concurrent, lock-free, no GenServer message.
  def enabled?(flag), do: :ets.lookup_element(:feature_flags, flag, 2, false)

  @impl true
  def init(_) do
    :ets.new(:feature_flags, [:named_table, :public, read_concurrency: true])
    {:ok, nil}
  end

  # Rare writes still go through the owning process.
  def put(flag, value), do: GenServer.call(__MODULE__, {:put, flag, value})

  @impl true
  def handle_call({:put, flag, value}, _from, state) do
    :ets.insert(:feature_flags, {flag, value})
    {:reply, :ok, state}
  end
end
```

The `:ets.lookup_element/4` default-argument form needs OTP 26+; on older OTP use `lookup_element/3` guarded by `:ets.member/2`, or `:ets.lookup/2` and match the result.

Reference: [Erlang — `:ets.lookup_element/4`](https://www.erlang.org/doc/apps/stdlib/ets.html#lookup_element/4)
