---
title: Use Consistent Hashing For Sharding That Survives Node Changes
impact: MEDIUM-HIGH
impactDescription: ~(N-1)/N key remap on node add to ~1/N — 80% to 20% reshuffling for N=5
tags: scale, consistent-hashing, sharding, distributed
---

## Use Consistent Hashing For Sharding That Survives Node Changes

Plain `shard_id = hash(key) % N` is fine until N changes — and then almost every key remaps to a different shard, forcing a cache stampede or full data reshuffle. **Consistent hashing** (Karger et al., 1997) places nodes and keys on a circular hash space; each key goes to the next node clockwise. Adding or removing a node only moves the keys "between" that node and its predecessor — on average **k/n keys** instead of n-1/n. **Virtual nodes (vnodes)** smooth out load imbalance.

This is the foundation of distributed caches (Memcached, Redis Cluster sharding policies), DHTs (Chord, Cassandra, DynamoDB), CDN edge selection, and request routing in microservices.

**Incorrect (modulo sharding — resize remaps ~all keys):**

```python
def shard_id(key: str, n_shards: int) -> int:
    # Adding a single shard (n=4 → 5) remaps ~80% of keys to a different shard.
    # Every cache miss, every range rebalance.
    return hash(key) % n_shards
```

**Correct (consistent hashing with vnodes — adding a shard remaps ~1/N of keys):**

```python
from bisect import bisect_right, insort
import hashlib

class ConsistentHashRing:
    def __init__(self, vnodes_per_node: int = 200):
        # vnodes smooth load: more vnodes → tighter distribution, more memory.
        # 100-500 vnodes/node is the production-tested sweet spot.
        self.vnodes_per_node = vnodes_per_node
        self.ring: list[int] = []                  # sorted vnode positions
        self.node_for_position: dict[int, str] = {}

    @staticmethod
    def _hash(s: str) -> int:
        # MurmurHash or xxHash are faster; SHA-1 shown for stdlib only.
        return int(hashlib.sha1(s.encode()).hexdigest()[:16], 16)

    def add_node(self, node: str) -> None:
        for i in range(self.vnodes_per_node):
            pos = self._hash(f"{node}#{i}")
            insort(self.ring, pos)
            self.node_for_position[pos] = node

    def remove_node(self, node: str) -> None:
        for i in range(self.vnodes_per_node):
            pos = self._hash(f"{node}#{i}")
            self.ring.remove(pos)
            del self.node_for_position[pos]

    def shard_for(self, key: str) -> str:
        # Walk clockwise to the first vnode ≥ hash(key); wrap if needed.
        h = self._hash(key)
        idx = bisect_right(self.ring, h)
        if idx == len(self.ring):
            idx = 0
        return self.node_for_position[self.ring[idx]]

# Usage
ring = ConsistentHashRing()
for n in ("cache-1", "cache-2", "cache-3", "cache-4"):
    ring.add_node(n)
target = ring.shard_for("user:42:profile")
```

**Vnode count tradeoff:**

| Vnodes per node | Load imbalance (std dev) | Memory overhead |
|-----------------|--------------------------|-----------------|
| 1 (no vnodes) | ~100% — terrible | minimal |
| 10 | ~30% | small |
| 100 | ~10% | moderate |
| 200-500 | ~3-5% | typical production sweet spot |
| 10000 | <1% | only for very large rings |

**Alternatives:**

- **Rendezvous hashing (HRW)** — assign key to node with max `hash(key, node)`. O(N) per lookup but no ring to maintain; trivially handles node weight changes. Catalyst at Spotify, used by Foursquare.
- **Jump consistent hash (Lamping & Veach, 2014)** — O(log N) lookup, zero memory, but only works when shards are numbered 0..N-1 (can't easily remove an arbitrary shard).
- **Maglev hashing (Google)** — fast lookup, minimal disruption, but rebuild cost is high; designed for load balancers where lookups vastly outnumber topology changes.

**When NOT to use:**

- Fixed shard count that never changes (modulo is simpler and faster)
- Stateless sharding where misses are free (no cache, no replication state to move)
- Strong-consistency systems where deterministic placement matters more than minimal reshuffling

**Production:** Amazon DynamoDB (originally Dynamo, the paper), Cassandra, Riak, Memcached client libraries (ketama), Akamai CDN edge selection, Discord guild sharding.

Reference: [Consistent hashing — Wikipedia](https://en.wikipedia.org/wiki/Consistent_hashing)
