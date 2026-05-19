---
title: Query Through Aliases, Never Direct Index Names
impact: HIGH
impactDescription: enables zero-downtime reindex and rollback
tags: search, opensearch, alias, reindex, blue-green
---

## Query Through Aliases, Never Direct Index Names

When a mapping changes (new field, different analyzer, version of the OpenSearch index) or you reindex from a source-of-truth database, the cleanest path is: build a new index alongside, populate it, then atomically swap traffic. If your application queries `index="products"` directly, you can't do this without downtime — you'd have to delete the old index, create the new one with the same name, populate it, and during that window all searches return empty.

The solution: applications query a *named alias* (`products_live`), which points to whatever index is currently authoritative (`products_v23`). Reindex builds `products_v24`, validates it, atomically repoints the alias, and instantly all queries hit the new index. Rollback is one alias swap.

**Incorrect (direct index name — no swap path):**

```python
# settings.py
OPENSEARCH_INDEX = "products"

# views.py
opensearch.search(index=settings.OPENSEARCH_INDEX, body=query)
# ❌ Can't reindex without downtime or coordinating a code deploy
```

**Correct (alias indirection):**

```python
# settings.py
OPENSEARCH_ALIAS = "products_live"
OPENSEARCH_WRITE_ALIAS = "products_write"  # often same as read; sometimes separate

# views.py — queries the alias, never the underlying index name
opensearch.search(index=settings.OPENSEARCH_ALIAS, body=query)

# At index time, also write through an alias
opensearch.index(index=settings.OPENSEARCH_WRITE_ALIAS, id=doc_id, body=doc)
```

**Reindex / blue-green swap procedure:**

```python
# scripts/reindex.py
def blue_green_reindex():
    old_index = current_target_of_alias("products_live")  # e.g. "products_v23"
    new_index = f"products_v{int(old_index.split('_v')[1]) + 1}"  # "products_v24"

    # 1. Create new index with the new mapping
    opensearch.indices.create(index=new_index, body=NEW_MAPPING)

    # 2. Populate from source of truth (or from old index via _reindex API)
    opensearch.reindex(body={
        "source": {"index": old_index},
        "dest": {"index": new_index},
    }, wait_for_completion=False)
    # Wait for the reindex task to complete, then validate doc counts

    # 3. Validation — sample a few docs, run smoke queries
    if not validate_new_index(new_index):
        raise ReindexFailed(f"validation failed for {new_index}")

    # 4. Atomic alias swap — one API call, no downtime
    opensearch.indices.update_aliases(body={
        "actions": [
            {"remove": {"index": old_index, "alias": "products_live"}},
            {"add":    {"index": new_index, "alias": "products_live"}},
        ]
    })

    # 5. Keep old_index around for 24-48h for fast rollback
    # 6. Eventually delete old_index when confident
```

**Same alias, multiple indices (for time-series writes):**

```python
# Aliases can point to multiple indices simultaneously
# Useful for time-series patterns: latest writes go to "products_2026_q2",
# but reads span "products_*"
opensearch.indices.update_aliases(body={
    "actions": [
        {"add": {"index": "products_2026_q1", "alias": "products_read"}},
        {"add": {"index": "products_2026_q2", "alias": "products_read"}},
        {"add": {
            "index": "products_2026_q2",
            "alias": "products_write",
            "is_write_index": True,    # only this one accepts writes
        }},
    ]
})
```

**Use filtered aliases for tenancy or shard isolation:**

```python
# Per-tenant alias automatically filters the underlying multi-tenant index
opensearch.indices.put_alias(
    index="products_v23",
    name="products_tenant_acme",
    body={
        "filter": {"term": {"tenant_id": "acme"}},
        "routing": "acme",   # ensures queries go to the right shards
    }
)
# Now opensearch.search(index="products_tenant_acme", ...) is automatically scoped.
```

**Rollback (alias swap back to previous index):**

```python
def rollback():
    bad_index = current_target_of_alias("products_live")
    previous = previous_target_from_history()  # tracked in DB or convention
    opensearch.indices.update_aliases(body={
        "actions": [
            {"remove": {"index": bad_index, "alias": "products_live"}},
            {"add":    {"index": previous,  "alias": "products_live"}},
        ]
    })
# Sub-second rollback. No downtime. No code deploy.
```

**When NOT to use aliases:**

- Heavily-write-throughput per-tenant indices where alias resolution overhead matters (rare; alias resolution is microseconds)
- Read paths that need to span dynamic, custom index combinations (you can use date-math index patterns: `<products_{now/d}>`)

**Symptom of missing alias indirection:**
- Reindex schedules require downtime windows
- Mapping changes require code deploys to switch index names
- Rollback after a bad reindex requires re-running the reindex from scratch
- Engineers afraid to reindex because the operational risk is too high

**Index naming convention that helps:**

| Pattern | Use |
|---------|-----|
| `{logical}_v{N}` (e.g., `products_v23`) | Schema-versioned indices, alias swap on change |
| `{logical}_{YYYY-MM-DD}` | Daily indices for time-series data |
| `{logical}_{YYYY}_q{N}` | Quarterly archives |

Reference: [OpenSearch — Index aliases](https://opensearch.org/docs/latest/im-plugin/index-alias/) | [Elasticsearch — Aliases](https://www.elastic.co/guide/en/elasticsearch/reference/current/aliases.html)
