---
title: Size L2 ElastiCache to the Cross-Instance Working Set
impact: MEDIUM-HIGH
impactDescription: prevents L2 eviction churn while not over-provisioning
tags: tier, l2, elasticache, redis, sizing
---

## Size L2 ElastiCache to the Cross-Instance Working Set

L2 (shared ElastiCache) is the cross-instance reuse layer: entries written by one instance are read by all others. L2 size should match the working set across the fleet, not the full keyspace and not the per-instance working set. Under-size and you get eviction churn — keys popular this hour evict keys popular last hour, hit rate plateaus far below the achievable ceiling. Over-size and you pay for capacity that's never used. The right number comes from the [decide-hot-key-distribution](decide-hot-key-distribution.md) curve: pick the cache size at the knee of the hit-rate-vs-size curve.

**Incorrect (size by feeling, not data):**

```text
Engineer 1: "Let's start with cache.r7g.large, 13 GB. Sounds good."
Six months later, Redis is at 95% memory; eviction rate is high; hit rate is 65%
when it should be 85%.

Engineer 2: "Bump to cache.r7g.4xlarge, 100 GB. Way more than we need."
Six months later, Redis is at 12% memory; ElastiCache bill is $1.6k/month for capacity
that holds entries no one will ever read again.
```

**Correct (size from the hit-rate curve):**

```bash
# Step 1: profile traffic as in decide-hot-key-distribution.md
python scripts/profile_traffic.py s3://cache-logs/7d/ > sizing.csv

# Step 2: read the hit-rate curve, pick the knee
# Output:
#   cache_size_gb,hit_rate
#   1.0,0.51
#   2.0,0.63
#   4.0,0.72
#   8.0,0.79     <-- knee
#   16.0,0.84
#   32.0,0.87    <-- diminishing returns from here
#   64.0,0.89

# Step 3: pick the cluster size that comfortably exceeds the knee
#   Knee at 8 GB working set; want headroom for growth and replication.
#   cache.r7g.large (13 GB usable) × 2 replicas for HA = $240/month
```

**ElastiCache replica considerations:**
- Reader replicas spread read load across nodes; useful when L2 ops/sec is the bottleneck
- Two replicas minimum for HA in production
- Replicas hold the same data; sizing per replica = working set, not working set / N

**Cluster mode (sharding) vs single-shard:**
- Single-shard simplest; works up to ~50-100GB working set with a large node type
- Cluster mode shards keys across nodes; pick when working set exceeds single-shard capacity
- Cluster mode adds complexity: client library must support routing; multi-key ops (MGET) only work within a shard or with hash tags

**Hash tags for co-location:** if you use MGET across related keys (one per recommender on a page), use Redis hash tags to co-locate them on the same shard:

```typescript
// Without hash tags — each key may live on a different shard:
const keys = ['recs:trending:c1', 'recs:popular:c1', 'recs:similar:c1'];

// With hash tags — all keys with {c1} live on the same shard, MGET works:
const keys = ['recs:trending:{c1}', 'recs:popular:{c1}', 'recs:similar:{c1}'];
```

**Eviction policy:**
- `allkeys-lru` for typical caches (evict least-recently-used regardless of TTL)
- `volatile-lru` if you have a mix of TTL'd cache entries and persistent data (evict only TTL'd)
- `noeviction` only if memory should never overflow (you'll get write failures instead)

**Memory pressure alerts:**
- Memory usage > 85% → consider upsizing or shorter TTLs
- Evicted keys per second > expected new keys per second → working set has grown beyond capacity
- HitRate dropping while traffic stable → likely eviction churn from undersized cache

**Don't use ElastiCache for very-large per-key values.** Redis values >100KB suffer from networking overhead and block other operations on the node. For large payloads (rendered HTML, large recommendations), consider S3 with CloudFront ([tier-cdn-for-anonymous](tier-cdn-for-anonymous.md)) instead of Redis.

Reference: [AWS ElastiCache best practices](https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/BestPractices.html) · [Redis cluster docs](https://redis.io/docs/latest/operate/oss_and_stack/management/scaling/) · [Redis eviction policies](https://redis.io/docs/latest/develop/reference/eviction/)
