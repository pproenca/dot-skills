---
title: Maintain Session Vectors in Cache with Write-Through on Every Event
impact: HIGH
impactDescription: <1ms session-vector reads for real-time rerank
tags: pers, session, write-through, real-time, vector
---

## Maintain Session Vectors in Cache with Write-Through on Every Event

Real-time personalisation needs a fast read of "what the user has clicked/viewed in the last 5 minutes." Fetching this on every request from a datastore (DynamoDB, S3, RDS) adds tens of milliseconds per page; computing it on the fly from raw events adds more. The fix: keep the session vector in cache, write through to it on every interaction event. Reads stay under 1ms (single Redis GET); the canonical store gets the durable copy asynchronously. The session vector then drops into the per-request rerank without slowing the response.

**Incorrect (recompute from raw events on every read):**

```typescript
async function getSessionVector(userId: string): Promise<number[]> {
  // Fetch last N events from DynamoDB, compute vector on the fly
  const events = await dynamodb.query({
    TableName: 'user_events',
    KeyConditionExpression: 'userId = :u AND ts > :since',
    ExpressionAttributeValues: { ':u': userId, ':since': Date.now() - 5 * 60 * 1000 },
  });
  // ~15-30ms for the query + ~5ms to compute the embedding average
  return computeAverageEmbedding(events.Items);
}

async function rerank(candidates: Candidate[], userId: string) {
  const sessionVec = await getSessionVector(userId);  // 20-35ms per rerank!
  return rerankWithVector(candidates, sessionVec);
}
```

**Correct (cache holds the vector; write-through on event ingestion):**

```typescript
// Read path: single Redis GET, ~0.8ms
async function getSessionVector(userId: string): Promise<number[]> {
  const cached = await redis.get(`session-vec:${userId}`);
  if (cached) return new Float32Array(Buffer.from(cached, 'base64').buffer);
  // Cold session: empty vector (no signal yet)
  return new Float32Array(EMBEDDING_DIM);
}

// Write path: triggered by event ingestion (Kinesis, EventBridge, Kafka)
async function ingestEvent(event: UserEvent) {
  const itemEmbedding = await getItemEmbedding(event.itemId);  // L1 cached
  const currentVec = await getSessionVector(event.userId);

  // Exponentially weighted moving average — last events dominate, old fade
  const ALPHA = 0.15;
  const newVec = new Float32Array(EMBEDDING_DIM);
  for (let i = 0; i < EMBEDDING_DIM; i++) {
    newVec[i] = (1 - ALPHA) * currentVec[i] + ALPHA * itemEmbedding[i];
  }

  // Write-through to cache (synchronous), then to durable store (async)
  await redis.set(
    `session-vec:${event.userId}`,
    Buffer.from(newVec.buffer).toString('base64'),
    'EX', 30 * 60,  // 30-min TTL — session is "alive" if any event in last 30min
  );

  // Async durable write to DynamoDB or S3 (for offline analysis, retraining)
  durableWriteQueue.push({ userId: event.userId, vec: newVec, ts: Date.now() });
}

// On the read path, the rerank gets the up-to-date vector in <1ms
async function rerank(candidates: Candidate[], userId: string) {
  const sessionVec = await getSessionVector(userId);  // 0.8ms
  return rerankWithVector(candidates, sessionVec);
}
```

**Why write-through, not write-back:** the session vector is read-after-write — the user clicks an item, then loads the next page expecting recommendations influenced by that click. Write-back (lazy flush from cache to durable store) is fine because the durable copy is for offline analysis, not request-time reads. The cache *is* the canonical real-time copy.

**TTL semantics:** the 30-min TTL acts as a session timeout. If the user is idle 30 min, the session vector evicts; on their return, the rerank starts from a cold vector (or pulls a long-term-history vector from durable storage). This matches user-perceived "session" boundaries.

**Compaction:** session vectors are dense floats; a 256-dim Float32 = 1024 bytes. With 1M active users that's 1GB. Fits ElastiCache. For 10M+, partition by userId hash across multiple Redis nodes.

**When Personalize itself does this:** the `PutEvents` API streams events into Personalize, and the model updates its internal user representation in near-real-time. If you're already using PutEvents and the latency from event → recommendation update is acceptable (~2-5 seconds), you don't need a parallel session vector for Personalize. You DO need it if you're doing in-process rerank on top of Personalize candidates, or if you use OpenSearch-only retrieval.

Reference: [Personalize PutEvents real-time updates](https://docs.aws.amazon.com/personalize/latest/dg/recording-item-interaction-events.html) · [Airbnb: Listing Embeddings and Real-Time Personalization](https://medium.com/airbnb-engineering/listing-embeddings-for-similar-listing-recommendations-and-real-time-personalization-in-search-601172f7603e)
