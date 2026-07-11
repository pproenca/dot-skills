---
title: Treat Registry, ETS, and local names as node-local
tags: dist, registry, ets, cluster, uniqueness
---

## Treat Registry, ETS, and local names as node-local

`Registry` unique keys, ETS membership checks, and locally registered names enforce their invariants *per node* — the Registry documentation is explicit that it is a local storage. On one node, "unique key per tenant" means one runner per tenant; start a second node and each enforces its own copy, so the cluster now runs two per tenant. Nothing crashes and nothing logs — the invariant just quietly halves. This is the most treacherous shape in the category because the code is *correct* until the day the deployment scales out, which is precisely the day load makes the duplicate expensive. An invariant phrased as "per cluster" or "per system" must be enforced by something all nodes share: the database (unique index, advisory lock, lease row), unique job execution, or a cluster-aware registry with an explicit netsplit story (judged by the `:global` rule).

**Evidence of violation:** clustering is present in the application (libcluster or an equivalent in deps, `Node.connect`/release clustering config, or `:global`/`:pg`/distributed PubSub used elsewhere) *and* a node-local mechanism — a `Registry` with `keys: :unique`, an ETS presence check, `Process.whereis` on a local name — is the sole enforcement of an invariant whose statement is cluster-wide: one runner per tenant, cross-user dedup, a per-key rate limit shared by all traffic. PASS: the invariant is enforced in shared storage (unique index, lease, advisory lock, unique job) with the local mechanism at most an optimization; or the invariant is genuinely per-node and the reviewer cites why (the process owns a node-local resource — this node's socket, this node's cache shard). N/A: the application demonstrably never clusters (no clustering dep or config, single-node release), which makes this whole category N/A.

```elixir
# The Registry gives a fast local address; the database lease is the
# invariant. A second node's registration succeeds locally but its
# runner stands down when the lease is already held cluster-wide.
def start_runner(tenant_id) do
  with {:ok, _lease} <- MyApp.Leases.acquire({:tenant_runner, tenant_id}, ttl_ms: 30_000) do
    DynamicSupervisor.start_child(
      MyApp.RunnerSupervisor,
      {MyApp.TenantRunner, name: {:via, Registry, {MyApp.Registry, tenant_id}}, tenant: tenant_id}
    )
  end
end
```

Reference: [Elixir `Registry` — "local, decentralized and scalable key-value process storage"](https://hexdocs.pm/elixir/Registry.html)
