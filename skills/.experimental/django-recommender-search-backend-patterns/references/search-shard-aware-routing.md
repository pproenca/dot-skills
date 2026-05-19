---
title: Use Routing to Limit Shards Per Query
impact: HIGH
impactDescription: 10× faster queries when partition key known
tags: search, opensearch, routing, shards, multi-tenancy
---

## Use Routing to Limit Shards Per Query

By default, OpenSearch broadcasts every query to all shards of an index and merges results. For a 20-shard index, that's 20 shard executions and 20 result merges for *every* query. When you can narrow the search to a single tenant, user, region, or category, custom routing pins documents to a specific shard — and queries with the same routing key visit only that one shard. 20× less compute per query.

This requires the partition key to be known at both index and query time. Common cases: per-tenant data, per-user feeds, geographic regions.

**Incorrect (broadcast to all shards every query):**

```python
# Indexing without routing
opensearch.index(index="products_live", id=doc["id"], body=doc)

# Querying with no routing
opensearch.search(
    index="products_live",
    body={"query": {"bool": {"must": [{"match": {"title": "headphones"}}],
                              "filter": [{"term": {"tenant_id": "acme"}}]}}}
)
# OpenSearch hits all 20 shards even though only the shard for acme has data
```

**Correct (routing pins documents to a shard, queries skip the rest):**

```python
# Indexing with routing — all of acme's docs land on one shard
opensearch.index(
    index="products_live",
    id=doc["id"],
    body=doc,
    routing=doc["tenant_id"],   # ✅ routing key
)

# Querying with the same routing — visits only that shard
opensearch.search(
    index="products_live",
    body={"query": {"bool": {"must": [{"match": {"title": "headphones"}}]}}},
    routing="acme",              # ✅ visits ONLY acme's shard
)
# Same result, but one shard execution instead of 20
```

**Combine with filtered alias for transparent tenant isolation:**

```python
# Create a per-tenant alias that bakes in routing and filter
opensearch.indices.put_alias(
    index="products_live",
    name="products_acme",
    body={
        "filter": {"term": {"tenant_id": "acme"}},
        "routing": "acme",
        "search_routing": "acme",
        "index_routing": "acme",
    }
)

# Application code is clean:
opensearch.search(index="products_acme", body={"query": {...}})
# Internally: scoped to one shard + filtered to acme — no routing/filter in app code
```

**Routing values to choose:**

| Domain | Routing key | Why |
|--------|-------------|-----|
| Multi-tenant SaaS | `tenant_id` | All tenant data colocated; queries scoped per tenant |
| Per-user feeds | `user_id` (hashed if high cardinality) | User's data on one shard |
| Regional content | `region_code` | Geo-bounded queries hit one shard |
| Time-series with hot recent partitions | Don't route — use time-indexed sub-indices instead |

**Beware skew — uneven routing causes hot shards:**

If 80% of your traffic is one tenant ("acme"), routing concentrates all that traffic on one shard. The other 19 shards sit idle while one is overloaded. Mitigations:

```python
# Option A: Don't route for whale tenants
def should_route(tenant_id: str) -> bool:
    return tenant_id not in WHALE_TENANTS  # special-case heavy tenants

# Option B: Composite routing for whales — split across N shards by additional key
routing = f"{tenant_id}:{user_id_hash % 4}"  # whale split across 4 shards

# Option C: Per-tenant dedicated indices for whales
# - whale_tenants: their own index with default routing
# - small_tenants: shared multi-tenant index with tenant_id routing
```

**Aggregations with routing — be careful with cardinality estimates:**

Some aggregations (`cardinality`, `terms` with size) return per-shard estimates. With routing limiting to one shard, the estimates become *exact* (better!), but if a query has no routing and visits all shards, the estimates can be wrong. Always measure.

**Don't change routing after indexing without reindexing:**

Routing is a property of *where the document is stored*. If you index with `routing=A` then query with `routing=B`, you won't find the document. To change routing keys requires reindexing.

**Symptom of poor routing strategy:**
- Query latency dominated by shard fan-out (visible in `took` profile if you enable `profile=true`)
- Cluster CPU pegged on shards that should be idle
- Slow queries even on small filtered subsets

**Profile a query to see shard utilization:**

```python
response = opensearch.search(
    index="products_live",
    body={"query": {...}, "profile": True},
)
# response["profile"]["shards"] shows per-shard timings
# Look for: how many shards were queried, time per shard
```

Reference: [OpenSearch — Routing](https://opensearch.org/docs/latest/api-reference/document-apis/index-document/#optional-query-parameters) | [Elastic — Customizing routing](https://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-routing-field.html)
