---
title: Aggregate by Region with a Geohash Trie
impact: MEDIUM-HIGH
impactDescription: O(prefix-length) region rollups without rescanning
tags: idx, trie, aggregation, hierarchy, level-of-detail
---

## Aggregate by Region with a Geohash Trie

When you need counts or summaries per region at varying zoom — "how many points in each length-3 cell, then drill into one" — repeatedly scanning and grouping is wasteful. A trie keyed by geohash characters stores aggregates at every prefix length at once: each node holds the rollup for its prefix, so a region total is a single node lookup and drilling down is following children. This is the structure behind level-of-detail rendering ([[nav-level-of-detail-aggregation]]).

**Incorrect (re-scan and group per zoom level):**

```typescript
function countsAt(points: Point[], prefixLen: number): Map<string, number> {
  const m = new Map<string, number>();
  for (const p of points) {                 // a full pass for every zoom level
    const k = p.geohash.slice(0, prefixLen);
    m.set(k, (m.get(k) ?? 0) + 1);
  }
  return m;
}
```

**Correct (one trie holds every level's rollup):**

```typescript
interface Node { count: number; children: Map<string, Node>; }
const newNode = (): Node => ({ count: 0, children: new Map() });

class GeoTrie {
  private root = newNode();
  insert(geohash: string) {
    let node = this.root;
    node.count++;
    for (const ch of geohash) {
      let next = node.children.get(ch);
      if (!next) { next = newNode(); node.children.set(ch, next); }
      next.count++; // every prefix length is aggregated in one pass
      node = next;
    }
  }
  count(prefix: string): number {
    let node: Node | undefined = this.root;
    for (const ch of prefix) { node = node?.children.get(ch); if (!node) return 0; }
    return node.count; // O(prefix length), no rescan
  }
}
```

**When NOT to apply:**
- For a single fixed zoom level a flat `Map<prefix, count>` is simpler. Reach for the trie when you aggregate at multiple precisions or drill interactively.

Reference: [Trie (prefix tree)](https://en.wikipedia.org/wiki/Trie); [Elasticsearch geohash_grid](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-geohashgrid-aggregation.html)
