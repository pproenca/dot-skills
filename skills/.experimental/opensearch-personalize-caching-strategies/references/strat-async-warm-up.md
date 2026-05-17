---
title: Async Warm-Up After Deploy, Restart, or Model Retrain
impact: HIGH
impactDescription: avoids 5-30 min of degraded latency after cold start
tags: strat, warm-up, deploy, retrain, cold-start
---

## Async Warm-Up After Deploy, Restart, or Model Retrain

Every cache restart, every L1 process restart, every Personalize solution version swap creates a cold cache. Without warm-up, the first wave of traffic pays the full origin cost — for a 10k-key working set at 500 req/s, that's 20 seconds of degraded p99 minimum, often longer with stampede effects. Warm-up issues fake reads in parallel before traffic ramps, populating cache with yesterday's top-K keys. Costs one batch of origin calls; saves minutes of user-visible degradation. Apply automatically on every deploy, instance startup, and Personalize retrain.

**Incorrect (deploy, restart, hope for the best):**

```yaml
# Kubernetes deploy: rollout begins, new pods start, immediately receive traffic
# with empty L1 cache. Latency p99 spikes from 50ms → 350ms for 2-5 minutes
# until the cache fills naturally.
apiVersion: apps/v1
kind: Deployment
spec:
  replicas: 20
  template:
    spec:
      containers:
        - name: search-api
          # No warm-up; first traffic hits cold caches.
          readinessProbe:
            httpGet:
              path: /healthz
              port: 8080
            initialDelaySeconds: 5  # too fast — pod marks ready before warm
```

**Correct (warm-up step before marking ready):**

```typescript
// /warmup endpoint — issues read-through calls for the top-N keys
// from yesterday's traffic, then returns 200.
app.get('/warmup', async (req, res) => {
  const topKeys = await loadFromS3('s3://cache-analytics/top-keys-today.json');
  // Top 5000 keys, parallel with bounded concurrency (don't DoS the origin)
  const limit = pLimit(20);
  await Promise.all(topKeys.map(k => limit(() => warmKey(k))));
  res.json({ warmed: topKeys.length });
});

async function warmKey(k: KeyDescriptor) {
  if (k.kind === 'search') {
    // Goes through the cache-aside path; populates L1 + L2
    await search(k.q, k.ctx);
  } else if (k.kind === 'recs') {
    await getRecs(k.cohort, k.surface, k.locale);
  }
}
```

```yaml
# Kubernetes: readiness probe waits for warm-up to complete
spec:
  template:
    spec:
      containers:
        - name: search-api
          startupProbe:
            httpGet:
              path: /warmup
              port: 8080
            timeoutSeconds: 60   # warm-up should finish within a minute
            failureThreshold: 1
          readinessProbe:
            httpGet:
              path: /healthz
              port: 8080
            initialDelaySeconds: 0  # ready immediately after warm-up succeeds
```

**Apply on Personalize retrain too:**

```python
# When Personalize emits the Campaign Update event (via EventBridge),
# trigger a warm-up Lambda that pre-populates the cache for the new model
def on_campaign_updated(event, context):
    campaign_arn = event['detail']['campaignArn']
    new_solution_version = event['detail']['latestSolutionVersionArn']

    cohorts = load_active_cohorts()
    for cohort in cohorts:
        recs = personalize_runtime.get_recommendations(
            campaignArn=campaign_arn,
            userId=cohort['rep_user_id'],
        )
        key = f"recs:{cohort['surface']}:c{cohort['id']}:{cohort['locale']}:v{version_tag(new_solution_version)}"
        redis.set(key, json.dumps(recs), ex=1800)

    # Hit rate for the new model jumps to ~80% within 30 seconds of retrain,
    # versus 5-10 minutes if you wait for organic traffic to populate it.
```

**Warm-up source-of-truth:**
- Yesterday's top-K keys (from cache_hit log analytics) is the simplest and works for most cases
- For Personalize: yesterday's cohort × surface combinations, plus any seeded "always-warm" entries (homepage default, top categories)
- For seasonal events: hand-curated seed list overlay (Black Friday queries, holiday surfaces)

**Don't warm everything.** Warming the long tail wastes origin load with no user benefit. Top 1-5k keys handle the majority of warm-up wins; warming 100k+ keys is usually pointless.

**Bounded concurrency.** A warm-up that fires 5000 requests in parallel can DoS the origin during the warm-up window. Use a concurrency limit (20-50 in flight) so warm-up adds a few seconds to startup rather than triggering an availability event.

Reference: [Netflix: How Netflix Warms Petabytes of Cache Data](https://blog.bytebytego.com/p/how-netflix-warms-petabytes-of-cache) · [Personalize EventBridge events](https://docs.aws.amazon.com/personalize/latest/dg/eventbridge.html)
